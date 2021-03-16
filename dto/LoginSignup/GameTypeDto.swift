//
//  GameTypeDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/7/2.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
class GameTypeDto: Codable {
    let id:Int
    let gameTypeName_Pc:String
    let gameTypeName_Mobile:String
    var gameTypeBackGroundUnactive:String?
    
    let gameCategory:Int
    let gameGroups:ResponseDto<GameGroupDto,[String:String]?>

    
}

class GameGroupDto: Codable {
    let id:Int
    // 新增 遊戲狀態
    // 1:正常,前台顯示，可進入遊戲
    // 2:維護,前台顯示，但點擊時跳出訊息提示玩家遊戲正在維護中
    let gameGroupStatus:Int?
    
    let gameGroupName:String
    let gameCompanyTag: String?
    let gameLogo_Mobile:String
    let gameLogo_Pc:String
    let gameLogo_Recommend:String
    var gameVi_Before: String
    let gameVi_After:String
    //1:大廳,2:遊戲列表
    let gamePlayMode:Int?
    var isEnterGameList:Bool {
        return gamePlayMode ?? 1 == 2
    }
    var isAvailable:Bool {
        return gamePlayMode ?? 1 == 1 || gamePlayMode ?? 1 == 2
    }
    
    lazy var icon: UIImage? = {
        return nil
    }()
    
    func fetchGameIcon() {
        SDWebImageManager.shared.loadImage(with: URL(string: gameVi_Before), options: [], progress: nil) { [weak self] (img, _, _, _, _, _) in
            self?.icon = img
        }
    }
}
