//
//  ResponseDto.swift
//  Pre18tg
//
//  Created by Andy Chen on 2019/4/9.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation


class ResponseDto<T:Codable ,U:Codable>:Codable
{
    let status:Int
    let data :[T]
    let meta :U?
    init(status : Int ,data : [T] ,meta:U){
        self.status = status
        self.data = data
        self.meta = meta
    }
}

class ResponseRequestErrorDto: Codable {
    let status:Int
    let message:String
    let code:Int
    
    init(status:Int,message:String,code:Int) {
        self.status = status
        self.message = message
        self.code = code
    }
}

class ResponseVertifyErrorDto: Codable {

    let status: Int
    let message: String
    let errors: [String:[String]]?
    let code:Int
    
    init(status: Int, message: String, errors: [String:[String]]?,code:Int) {

        self.status = status
        self.message = message
        self.errors = errors
        self.code = code
    }
}
