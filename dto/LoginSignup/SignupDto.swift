//
//  SignupDto.swift
//  betlead
//
//  Created by Victor on 2019/5/30.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

struct SignupPostDto {
    
    let account: String
    let password: String
    let signupMode: LoginMode
    let timestamp = Date.timestamp()
    let finger = KeychainManager.share.getFingerID()
    
    init(account: String, password: String, signupMode: LoginMode) {
        self.account = account
        self.password = password
        self.signupMode = signupMode
    }
}

class SignupDto: Codable {
    let account: String?
    let password: String?
}

