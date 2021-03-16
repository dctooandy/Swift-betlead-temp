//
//  PaginiationDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/5/31.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class PaginiationDto:Codable {
    let pagination:paginationInfo
    
}

class paginationInfo:Codable{
    let total:Int
    let count:Int
    let per_page:Int
    let current_page:Int
    let total_pages:Int
    //let links:[String]
}
