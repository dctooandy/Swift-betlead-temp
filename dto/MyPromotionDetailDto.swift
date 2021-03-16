//
//  MyPromotionDetailDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/7/10.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class MyPromotionDetailDto:Codable {
    
    enum ApplyStatus:Int {
        case notJoined
        case joined
        case waitReview
        case waitReceive
        case finished
        case failed
        case giveup
        case unKnown
    }
    
    let id:Int
    let memberId:Int
    let MemberAcoount:String?
    let promotionId:Int
    let promotionSuccessOrderId:Int
    let promotionDetailStatus:ValueIntDto
    let promotionBonus:String?
    let promotionWalletBefore:String
    let promotionWalletAfter:String
    let promotionNote:String?
    let promotionGameGroupId:Int
    let promotionSystemMode:String?
    let promotionDetailCreatedAt:String
    let promotionDetailUpdatedAt:String
    let promotion:ResponseDto<PromotionDto,[String:String]?>
    
    var promotionDto:PromotionDto {
        return promotion.data[0]
    }
    var detailBtnColor:UIColor {
        guard let status = PromotionDto.ApplyStatus(rawValue: promotionDetailStatus.value) else {return Themes.grayBase}
        switch status {
        case .waitReview:
            return Themes.secondaryYellow
        case .waitReceive:
            return Themes.primaryBase
        default:
            return Themes.grayBase
        }
    }
    var cycleBtnColor:UIColor {
        guard let status = PromotionDto.ApplyStatus(rawValue: promotionDetailStatus.value) else {return Themes.grayBase}
        switch status {
        case .waitReview:
            return Themes.secondaryYellow
        case .waitReceive:
            return Themes.secondaryGreen
        default:
            return Themes.grayBase
        }
    }
    
    var showText:String {
        guard let status = PromotionDto.ApplyStatus(rawValue: promotionDetailStatus.value) else {return ""}
        switch status {
        case .waitReceive:
            return "领取奖励"
        default:
            return promotionDetailStatus.display ?? ""
        }
    }
    
    var bonusText:String {
        let type = promotion.data[0].promotionType.display ?? ""
        return "\(type) \(promotionBonus ?? "0") 元"
    }
}
