//
//  NewsDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/5/31.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class NewsDto:Codable {
    let id:Int
    let newsGroupId:ValueIntDto
    let newsTitle:String
    let newsContent:String
    let newsDevice:ValueStringDto?
    let newsTimeStart:String
    let newsTimeEnd:String
    let newsTop:ValueIntDto
    let newsStatus:ValueIntDto
    let newsCreatedUser:ValueIntDto?
    let newsUpdatedUser:ValueIntDto?
    let userCreatedAt:String?
    let userUpdatedAt:String?
    let newsCreatedAt:String
    let newsUpdatedAt:String
    
}
