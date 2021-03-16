//
//  GameBaseViewController.swift
//  betlead
//
//  Created by Andy Chen on 2019/7/2.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import Toaster
class GameBaseViewController:BaseViewController {
    
    var groupId:String? {
        didSet {
            fetchGameList()
        }
    }
    
    init(groupId:String , isNavBarTransparent:Bool) {
        self.groupId = groupId
        super.init(isNavBarTransparent: isNavBarTransparent)
        NotificationCenter.default.addObserver(self, selector: #selector(groupIdUpdate), name: NotifyConstant.betleadGameGroupIdUpdated, object: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(groupIdUpdate), name: NotifyConstant.betleadGameGroupIdUpdated, object: nil)
    }
    
    func fetchGameList(){
        
    }
    @objc func groupIdUpdate(_ notification: Notification) {
        if let groupId = notification.object as? Int {
            self.groupId = "\(groupId)"
        }
    }
    
    func handleLike(dto:GameDto){
        guard  UserStatus.share.isLogin else {
            self.present(LoginAlert(), animated: true, completion: nil)
            return
        }
        if dto.isLiked {
            Beans.gameServer.deleteGameLikeRecord(id: dto.id)
                .subscribeSuccess { [weak self] (isSuccess) in
                    if isSuccess {
                        Toast.show(msg: "移除最爱成功")
                        self?.fetchGameList()
                    } else {
                        Toast.show(msg: "移除最爱失败")
                    }
                }.disposed(by: disposeBag)
        } else {
            Beans.gameServer.addGameLikeRecord(id: dto.id)
                .subscribeSuccess { [weak self] (isSuccess) in
                    if isSuccess {
                        Toast.show(msg: "新增最爱成功")
                        self?.fetchGameList()
                    } else {
                        Toast.show(msg: "新增最爱失败")
                    }
                }.disposed(by: disposeBag)
        }
    }
}
