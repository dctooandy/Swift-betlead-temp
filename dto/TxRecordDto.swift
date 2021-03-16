//
//  TransactionRecordDto.swift
//  betlead
//
//  Created by Victor on 2019/6/21.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
/// 交易紀錄
class TxRecordDto: Codable {
    let orderId: String
    let type: TxRecordSubDto
    let payChannelServiceId: TxRecordSubDto
    let amount: Float
    let newCash: Float
    let oldCash: Float
    let remark: String?
    let status: TxRecordSubDto
    let orderFinishTime: String
    let createdAt: String
    
    var statusColor: UIColor {
        if status.value == 3 {
            return Themes.secondaryGreen
        } else if status.value == 1 {
            return Themes.secondaryYellow
        }
        return Themes.secondaryRed
    }
    
    var statusImage: UIImage? {
        if status.value == 3 {
            return UIImage(named: "check-circle")
        } else if status.value == 1 {
            return UIImage(named: "icon-processing")
        }
        return UIImage(named: "icon-failure")
    }
    
    var typeColor: UIColor {
        switch type.value {
        case 1:
            return Themes.secondaryGreen
        case 2:
            return Themes.secondaryRed
        case 8:
            return Themes.secondaryOrange
        default:
            return Themes.primaryBase
        }
    }
}

class TxRecordSubDto: Codable {
    let display: String
    let value: Int
}

