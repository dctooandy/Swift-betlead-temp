//
//  MarqueeDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/5/31.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class MarqueeDto:Codable {
//    let id:Int
//    let newsGroupId:ValueIntDto
//    let newsDevice:ValueStringDto?
//    let newsTimeStart:String
//    let newsTimeEnd:String
//    let newsTop:ValueIntDto
//    let newsStatus:ValueIntDto
//    let userCreatedUser:ValueIntDto?
//    let userUpdatedUser:ValueIntDto?
//    let userCreatedAt:String?
//    let userUpdatedAt:String?
//    let newsUpdatedAt:String
    
    let newsTitle:String
    let newsContent:String
    let newsCreatedAt:String
}
