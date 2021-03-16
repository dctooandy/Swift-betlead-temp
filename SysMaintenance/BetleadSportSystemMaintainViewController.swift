//
//  BetleadSportSystemMaintainViewController.swift
//  BetLead-Sport
//
//  Created by Andy Chen on 2019/9/26.
//  Copyright © 2019 lismart. All rights reserved.
//

import Foundation
import RxSwift
class BetleadSportSystemMaintainViewController:BaseViewController {

    private let bgIamgeView = UIImageView(image: UIImage(named: "system-maintain"))
    private let titleLabel = UILabel.customLabel(font: UIFont.systemFont(ofSize: 24, weight: .light), alignment: .center, textColor: .white, text: "抱歉！系统维护中…")
    private let dateLabel = UILabel.customLabel(font: UIFont.systemFont(ofSize: 16, weight: .light), alignment: .center, textColor: UIColor(rgb: 0xc2aaf2), text: "維護時間：2019/6/28 10:30～16:30")
    private let serviceIcon = UIImageView(image: UIImage(named: "icon-service"))
    private let serviceLabel = UILabel.customLabel(font: UIFont.systemFont(ofSize: 14), alignment: .center, textColor: .white, text: "客服")
    private let hintLabel = UILabel.customLabel(font: UIFont.systemFont(ofSize: 18, weight: .light), alignment: .center, textColor: .white)
    private let tabbar = BetleadTabbar.loadNib()
    lazy var memberVC: MemberViewController = {
        let vc = MemberViewController.loadNib()
        return vc
    }()
    init(message:String) {
        dateLabel.text = message
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        BetleadAssistiveTouch.share.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        settingViewController()
        bindViews()
//        BetleadAssistiveTouch.share.isHidden = true
        let attr = NSMutableAttributedString(string: "如需查看个人资讯请前往", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .light)])
        attr.append(NSAttributedString(string: "「我的」", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .semibold)]))
        hintLabel.attributedText = attr
    }
    
    private func setupViews(){
        bgIamgeView.contentMode = .scaleAspectFill
        view.addSubview(bgIamgeView)
        view.addSubview(titleLabel)
        view.addSubview(dateLabel)
        view.addSubview(serviceIcon)
        view.addSubview(serviceLabel)
        view.addSubview(hintLabel)
        view.addSubview(tabbar)
        
        bgIamgeView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        serviceIcon.snp.makeConstraints { (maker) in
            maker.size.equalTo(CGSize(width: 42, height: 42))
            maker.top.equalTo(Views.topOffset + 13)
            maker.trailing.equalTo(-25)
        }
        serviceLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(serviceIcon.snp.bottom).offset(8)
            maker.centerX.equalTo(serviceIcon)
        }
        hintLabel.snp.makeConstraints { (maker) in
            maker.bottom.equalToSuperview().offset(-Views.betleadTabbarHeight - 34)
            maker.width.equalTo(150)
            maker.centerX.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(hintLabel.snp.top).offset(-16)
            maker.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(dateLabel.snp.top).offset(-20)
            maker.centerX.equalToSuperview()
        }
        tabbar.snp.makeConstraints { (maker) in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.height.equalTo(Views.betleadTabbarHeight)
        }
        hintLabel.numberOfLines = 2
        tabbar.setupFanMenu()
    }
    
    private func settingViewController(){
        addChild(memberVC)
        view.insertSubview(memberVC.view, at: 0)
    }
    private func bindViews(){
        tabbar.rxItemClick.subscribeSuccess { [weak self](index) in
            guard let weakSelf = self else { return }
            switch index {
            case 3:
                weakSelf.view.bringSubviewToFront(weakSelf.memberVC.view)
            default:
                weakSelf.view.sendSubviewToBack(weakSelf.memberVC.view)
            }
            weakSelf.tabbar.bringToFront()
        }.disposed(by: disposeBag)
    }
}
