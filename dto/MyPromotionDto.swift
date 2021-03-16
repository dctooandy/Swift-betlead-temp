//
//  MyPromotionDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/7/10.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class MyPromotionDto:Codable {
    let id:Int
    let MemberId:Int
    let MemberAcoount:String?
    let promotionId:Int
    let promotionApplyMode:[PromotionApplyModeDto]
    let promotionMainCreatedAt:String
    let promotionMainUpdatedAt:String
    let promotion:ResponseDto<PromotionDto,[String:String]?>
    
    var promotionDto:PromotionDto {
        return promotion.data[0]
    }
    
}


