//
//  AddressDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/10.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class ProvinceDto:Codable {
    let memberProvinceId:Int
    let memberProvinceName:String
}

class CityDto:Codable {
    let memberCityId:Int
    let memberCityName:String
}

class StateDto:Codable {
    let memberStateId:Int
    let memberStateName:String
}
