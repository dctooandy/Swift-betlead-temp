//
//  NoticeDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/14.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class NoticeDto:Codable {
    let id:Int
    let memberAccount:String
    let memberId:Int
    let noticeCreatedAt:String
    let noticeUpdatedAt:String
    let noticeDepositSms:ValueIntDto
    let noticeDepositEmail:ValueIntDto
    let noticeDepositBroadcast:ValueIntDto
    let noticeDepositInbox:ValueIntDto
    let noticeWithdrawSms:ValueIntDto
    let noticeWithdrawEmail:ValueIntDto
    let noticeWithdrawBroadcast:ValueIntDto
    let noticeWithdrawInbox:ValueIntDto
    let noticePromotionSms:ValueIntDto
    let noticePromotionEmail:ValueIntDto
    let noticePromotionBroadcast:ValueIntDto
    let noticePromotionInbox:ValueIntDto
    
}
