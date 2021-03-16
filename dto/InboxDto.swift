//
//  MessageDto.swift
//  betlead
//
//  Created by Victor on 2019/7/1.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

struct InboxDto: Codable {
    
    let id: Int
    let memberId: Int
    let memberAccount: String
    let inboxTitle: String
    let inboxContent: String
    let inboxStatus:ValueIntDto
    let inboxCreatedAt: String
    let inboxUpdatedAt: String

}

struct InboxResDto: Codable {
    let id: Int
    let member_id: Int
    let status: Int
    let title: String
    let content: String
    let created_at: String
    let updated_at: String
}
