//
//  WalletBottomSheet.swift
//  betlead
//
//  Created by Victor on 2019/8/6.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import RxSwift

class GameWalletBottomSheet: BaseBottomSheet {
    private var gameWallets = [GameWalletDto]()
    private let remindLb: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(16)
        lb.text = "提醒：仅显示游戏钱包内有余额的项目"
        lb.textColor = Themes.grayDark
        return lb
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.registerCell(type: GameWalletCollectionViewCell.self)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundView = NoDataView(image: UIImage(named: "icon-nodata"), title: "暂无钱包明细")
        return cv
    }()
    
    private let retrieveMoneyBtn: UIButton = {
        let btn = UIButton()
        return btn
    }()
    
    func fetchGameWallet() {
        Beans.memberServer.getMemberGameWallet()
            .subscribeSuccess { [weak self] (dto) in
                self?.gameWallets = dto
                DispatchQueue.main.async {
                    self?.collectionView.backgroundView?.isHidden = !dto.isEmpty
                    self?.collectionView.reloadData()
                }
            }.disposed(by: disposeBag)
    }
    
    func bind() {
        submitBtn.rx.tap.flatMap { (_) -> Single<Bool> in
            LoadingViewController.show()
            return Beans.gameServer.retrieveAllGameMoney()
            }.subscribeSuccess { [weak self](isScuuess) in
                if isScuuess {
                    _ = LoadingViewController.action(mode: .success, title: "錢包收回成功")
                    WalletDto.update()
                    self?.fetchGameWallet()
                } else {
                    _ = LoadingViewController.action(mode: .fail, title: "未知原因失敗")
                }
            }.disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchGameWallet()
    }
    
    override func setupViews() {
        super.setupViews()
        titleLabel.text = "钱包明细"
        submitBtn.setTitle("一键收回", for: .normal)
        setup()
        bind()
        bindServiceBtn()
    }
    
    private func setup() {
        defaultContainer.addSubview(collectionView)
        defaultContainer.addSubview(remindLb)
        defaultContainer.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(600 + Views.bottomOffset)
        }
        
        remindLb.snp.makeConstraints { (make) in
            make.top.equalTo(separator.snp.bottom).offset(topOffset(28/812))
            make.width.equalTo(Views.screenWidth * (319/375))
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(remindLb.snp.bottom).offset(topOffset(24/812))
            make.bottom.equalTo(submitBtn.snp.top).offset(-topOffset(24/812))
            make.width.equalTo(Views.screenWidth * (319/375))
            make.centerX.equalToSuperview()
        }
    }
    
    func bindServiceBtn() {
        serviceBtn.rx.tap.subscribeSuccess {
            print("game wallet service btn pressed.")
            LiveChatService.share.betLeadServicePresent()
        }.disposed(by: disposeBag)
    }
}

// MARK: - collection view delegate & datasource
extension GameWalletBottomSheet: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameWallets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: GameWalletCollectionViewCell.self, indexPath: indexPath)
        cell.setData(gameWallets[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 10) / 2, height: Views.screenHeight * (80/812))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GameWalletCollectionViewCell else { return }
        cell.startActivity()
        let tag = gameWallets[indexPath.item].gameGroup.value
        print("refresh game wallet: \(tag)")
        refreshGameWalletFor(comanyTag: tag) { [weak self](dtos, error) in
            cell.stopActivity()
            guard let strongSelf = self else { return }
            if error != nil { return }
            guard let dto = dtos?.first else { return }
            cell.setData(dto)
            strongSelf.gameWallets[indexPath.item] = dto
        }
    }
    
    func refreshGameWalletFor(comanyTag: String, doneHandle: @escaping ( _ dto: [GameWalletDto]?, _ error: Error?) -> ()) {
        Beans.memberServer.refreshGameWallet(companyTag: comanyTag).subscribe(onSuccess: { (dto) in
            doneHandle(dto, nil)
        }, onError: { (error) in
            doneHandle(nil, error)
            ErrorHandler.show(error: error)
        }).disposed(by: disposeBag)
    }
}
