//
//  LoginDto.swift
//  betlead
//
//  Created by Victor on 2019/5/30.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

struct LoginPostDto {
    let account: String
    let password: String
    let loginMode: LoginMode
    let timestamp = Date.timestamp()
    let finger = KeychainManager.share.getFingerID()
    init(account: String, password: String, loginMode: LoginMode) {
        self.account = account
        self.password = password
        self.loginMode = loginMode
    }
}

class LoginDto: Codable {
    let account: String?
    let accountChanged: Bool?
    let email: String?
    let lastLoginAt: String?
    let lastLoginIn: LastLoginInDto?
    let phone: String?
}

class LastLoginInDto: Codable {
    let area: String?
    let city: String?
    let country: String?
    let province: String?
    let telecom: String?
}

class MemberAccount {
    static var share: MemberAccount?
    
    init(account: String, password: String, loginMode: LoginMode, phone: String? = nil) {
        self.account = account
        self.password = password
        self.loginMode = loginMode
        self.phone = phone
    }
    
    let account: String
    var password: String
    let loginMode: LoginMode
    var phone: String?
}
