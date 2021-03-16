//
//  PromotionContentBottomSheet.swift
//  betlead
//
//  Created by Andy Chen on 2019/7/5.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import WebKit
import Toaster
class PromotionContentBottomSheet:BaseBottomSheet {
    enum Action {
        case fetchAndReload
        case pushMyPomotionCycleVC(id:Int)
    }
    
    private let contentWebView = WKWebView()
    private let promotTitleLabel:UILabel = {
        let label = UILabel()
        label.textColor = Themes.primaryBase
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    private var promotionDto:PromotionDto?
    
    
    private func bindBtn(){
        guard let promotionDto = promotionDto else {return}
        
        switch promotionDto.applyPeriod {
        case .single:
            guard let promotionStatus = promotionDto.applyStatus.first else {return}
            switch promotionStatus {
            case .notJoined:
                submitBtn.rx.tap.subscribeSuccess({[weak self] _ in
                    guard UserStatus.share.isLogin else {
                        self?.present(LoginAlert(), animated: true, completion: nil)
                        return
                    }
                    self?.applyPromotion(check_apply:0)})
                    .disposed(by: disposeBag)
            default:
                submitBtn.rx.tap.subscribeSuccess({[weak self] _ in
                    guard let weakSelf = self else { return }
                    LoadingViewController.show()
                    Beans.promotionServer.getMyPromotionDetail(promotion_id: promotionDto.id).subscribeSuccess { [weak self](promotionDtos) in
                        guard let weakSelf = self,
                            let promotionDetailDto = promotionDtos.first else {return}
                        LoadingViewController.dismiss().subscribeSuccess({ (_) in
                            let nextVC = PromotionDetailBottomSheet(promotionDetailDto.id)
                            weakSelf.dismissVC(nextSheet: nextVC)
                        }).disposed(by: weakSelf.disposeBag)
                        }.disposed(by: weakSelf.disposeBag)
                }).disposed(by: disposeBag)
            }
        case .cycle:
            if promotionDto.applyStatus.contains(.notJoined){
                submitBtn.rx.tap.subscribeSuccess({[weak self] _ in
                    guard UserStatus.share.isLogin else {
                        self?.present(LoginAlert(), animated: true, completion: nil)
                        return
                    }
                    self?.applyPromotion(check_apply:0)})
                    .disposed(by: disposeBag)
            } else {
                submitBtn.rx.tap.subscribeSuccess({[weak self] _ in
                    self?.value = Action.pushMyPomotionCycleVC(id: promotionDto.id)
                    self?.dismiss(animated: true)
                }).disposed(by: disposeBag)
            }
        default:
            break
        }
        serviceBtn.rx.tap.subscribeSuccess {
            print("promotion service btn pressed.")
            LiveChatService.share.betLeadServicePresent()
        }.disposed(by: disposeBag)
    }
    
    private func applyPromotion(check_apply:Int){
        guard let promotionDto = promotionDto else {return}
        LoadingViewController.show()
        Beans.promotionServer.apply(promotion_id: promotionDto.id, check_apply: check_apply).subscribe(onSuccess: { (isSuccess) in
            if isSuccess {
                LoadingViewController.action(mode: .success, title: "已参加活动")
                    .subscribeSuccess({ (_) in
                        self.value = Action.fetchAndReload
                        self.dismissVC()
                    }).disposed(by: self.disposeBag)
            }
        }) { (error) in
            LoadingViewController.dismiss()
            if let error = error as? ApiServiceError {
                switch error {
                case .domainError(let code, let message):
                    switch code {
                    case ErrorCode.PROMOTION_CONFLICT:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 , execute: {
                            self.showAlert(message:message)
                        })
                    default:
                        ErrorHandler.show(error: error)
                    }
                default:
                    ErrorHandler.show(error: error)
                }
            }
            }.disposed(by: disposeBag)
        
    }
    
    private func showAlert(message:String){
        let alert = UIAlertController(title: "优惠提醒", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: {(action) in
            self.applyPromotion(check_apply: 1)
        })
        let cancelAction = UIAlertAction(title: "再想想", style: .default, handler: {(action) in
            
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func configure(promotionDto:PromotionDto){
        self.promotionDto = promotionDto
        titleLabel.text = "优惠内容"
        promotTitleLabel.text = promotionDto.promotionTitle
        let renderContent = JSStyleRender.share.renderFitContentCss(content:promotionDto.promotionContent)
        contentWebView.loadHTMLString(renderContent, baseURL: nil)
        submitBtn.setTitle(promotionDto.shownBtnText, for: .normal)
        submitBtn.setBackgroundImage(UIImage(color: promotionDto.shownBtnColor) , for: .normal)
        submitBtn.isEnabled = promotionDto.shownBtnEnable
        bindBtn()
    }
    
    override func setupViews() {
        super.setupViews()
        defaultContainer.addSubview(promotTitleLabel)
        defaultContainer.addSubview(contentWebView)
        
        promotTitleLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(separator.snp.bottom).offset(28)
            maker.leading.equalTo(24)
            maker.trailing.equalTo(-24)
            maker.height.equalTo(50)
        }
        contentWebView.snp.makeConstraints { (maker) in
            maker.top.equalTo(promotTitleLabel.snp.bottom)
            maker.leading.trailing.equalTo(promotTitleLabel)
            maker.bottom.equalTo(submitBtn.snp.top)
        }
        
    }
}
