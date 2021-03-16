//
//  ValueDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/5/31.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class ValueIntDto:Codable {
    let value:Int
    let display:String?
}

class ValueStringDto:Codable {
    let value:String
    let display:String?
}

class ValueOptionIntDto:Codable {
    let value:Int?
    let display:String?
}

class ValueOptionStringDto:Codable {
    let value:String?
    let display:String?
}

class ValueOptionBoolDto:Codable {
    let value:Bool?
    let display:String?
}
