//
//  TxRecordDetailDto.swift
//  betlead
//
//  Created by Victor on 2019/6/21.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
/// 單筆交易詳細紀錄
class TxRecordDetailDto: Codable {
    let orderId: String
    let type: TxRecordSubDto
    let payChannelServiceId: TxRecordSubDto
    let amount: Int
    let newCash: Int
    let oldCash: Int
    let remark: String?
    let status: TxRecordSubDto
    let orderFinishTime: String
    let createdAt: String
}
