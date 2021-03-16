//
//  GameDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/27.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class GameDto : Codable{
    let id:Int
    let gameGroupId:Int
    let images:String?
    let gameName:String
    let gameTag:[String]
    let gameLikeId:Int
    
    var isLiked:Bool {
        return gameLikeId != 0
    }
}
