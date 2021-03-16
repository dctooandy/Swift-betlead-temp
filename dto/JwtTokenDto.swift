//
//  JwtTokenDto.swift
//  Pre18tg
//
//  Created by Andy Chen on 2019/4/9.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class JwtTokenDto:Codable {
    let jwt_token:String
    init(jwt_token:String){
        self.jwt_token = jwt_token
    }
}

