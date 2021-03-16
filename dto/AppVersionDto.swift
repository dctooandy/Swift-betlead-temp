//
//  AppVersionDto.swift
//  betlead
//
//  Created by Victor on 2019/9/17.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class AppVersionDto: Codable, Equatable {
    static var didFetch: Bool = false
    static var share: AppVersionDto? = nil
    let appVersionVersion: String
    let appVersionForceUpdate: ValueOptionBoolDto?
    let appVersionFileLocation: String
    let appVersionTitle: String
    let appVersionContent: String
    static func == (lhs: AppVersionDto, rhs: AppVersionDto) -> Bool {
        return lhs.appVersionVersion == rhs.appVersionVersion
    }
}
