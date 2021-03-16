//
//  PromotionDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/20.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class PromotionDto:Codable {
    
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
    
    enum ApplyMethod {
        case auto
        case manual
        case unKnown
        
        var text:String {
            switch self {
            case .auto:
                return "自动参与"
            case .manual:
                return "自助参与"
            case .unKnown:
                return ""
            }
        }
        
        var color: UIColor {
            switch self {
            case .auto:
                return Themes.grayBase
            case .manual:
                return Themes.secondaryOrange
            default:
                return Themes.grayBase
            }
        }
        
        var image: UIImage? {
            switch self {
            case .auto:
                return UIImage(named: "icon-promotionAuto")
            case .manual:
                return UIImage(named: "icon-promotionManual")
            default:
                return UIImage(named: "icon-promotionAuto")
            }
        }
    }
    enum ApplyPeriod {
        case single
        case cycle
        case unKnown
    }
    
    let id:Int
    let promotionGroupId:ValueStringDto
    let promotionType:ValueIntDto
    let promotionTitle:String
    let promotionSubTitle:String?
    let promotionContent:String
    let promotionDevice:ValueStringDto
    let promotionImagePc:String
    let promotionImageMobile:String
    let promotionLinkPc:String?
    let promotionLinkMobile:String?
    let promotionTimeStart:String
    let promotionTimeEnd:String
    let promotionRuleTimeStart:String
    let promotionRuleTimeEnd:String
    let promotionLinkMethod:ValueIntDto
    let promotionNote:String?
    let promotionSort:Int
    let promotionStatus:ValueIntDto
    let promotionApplyMethod:ValueIntDto
    let promotionCreatedAt:String
    let promotionUpdatedAt:String
    let promotionApplyMode:[PromotionApplyModeDto]
    // 0單次 1日 2週
    let promotionCycle:ValueIntDto
    let promotionTimes:Int
    
    
    var applyStatus:[ApplyStatus] {
        return promotionApplyMode.map({ (promotionApplyModeDto) -> ApplyStatus in
            return ApplyStatus(rawValue: promotionApplyModeDto.value) ?? ApplyStatus.unKnown
        })
    }
    
    var during:String {
        return DateHelper.share.transDateFormat(date: promotionRuleTimeStart) + "~" + DateHelper.share.transDateFormat(date: promotionRuleTimeEnd)
    }
    
    var applyMethod:ApplyMethod {
        switch promotionApplyMethod.value {
        case 1:
            return .auto
        case 2:
            return .manual
        default:
            return .unKnown
        }
    }
    
    var applyPeriod:ApplyPeriod {
        switch promotionCycle.value {
        case 0:
            return .single
        case 1,2:
            return .cycle
        default:
            return .unKnown
        }
    }
    
    var shownBtnText:String {
        switch applyPeriod {
        case .cycle:
            if let notJoinedMode = promotionApplyMode.filter({$0.value == ApplyStatus.notJoined.rawValue}).first {
                return notJoinedMode.display
            }
            if let giveupMode = promotionApplyMode.filter({$0.value == ApplyStatus.giveup.rawValue}).first {
                return giveupMode.display
            }
            if let finishMode = promotionApplyMode.filter({$0.value == ApplyStatus.finished.rawValue}).first {
                return finishMode.display
            }
            if let failedMode = promotionApplyMode.filter({$0.value == ApplyStatus.failed.rawValue}).first {
                return failedMode.display
            }
            let waitReviewCount = applyStatus.filter({$0 == .waitReview}).count
            let waitReceiveCount = applyStatus.filter({$0 == .waitReceive}).count
            return "待領取(\(waitReceiveCount)）|  待審核(\(waitReviewCount))"
        case .single:
            return promotionApplyMode.first?.display ?? ""
        case .unKnown:
            return "unKnownStatus"
        }
    }
    var shownBtnColor:UIColor {
        switch applyPeriod {
        case .cycle:
            if let _ = promotionApplyMode.filter({$0.value == ApplyStatus.giveup.rawValue}).first {
                return Themes.grayBase
            }
            return Themes.primaryBase
        case .single:
            guard let applyStatus = applyStatus.first else {return Themes.grayBase}
            switch applyStatus {
            case .giveup, .joined, .failed:
                return  Themes.grayBase
            case .waitReview:
                return Themes.secondaryYellow
            default:
                return Themes.primaryBase
            }
        case .unKnown:
            return Themes.grayBase
        }
    }
    var shownBtnEnable:Bool {
        switch applyPeriod {
        case .cycle:
            if let _ = promotionApplyMode.filter({$0.value == ApplyStatus.giveup.rawValue}).first {
                return false
            }
            return true
        case .single:
            guard let applyStatus = applyStatus.first else {return false}
            switch applyStatus {
            case .giveup :
                return  false
            default:
                return true
            }
        case .unKnown:
            return false
        }
    }
    var shownOnceColor:UIColor {
            guard let applyStatus = applyStatus.first else {return Themes.grayBase}
            switch applyStatus {
            case .waitReview :
                return  Themes.secondaryYellow
            case .waitReceive:
                return Themes.secondaryGreen
            case .joined:
                return Themes.mediumPurple
            default:
                return Themes.grayBase
            }
        
    }
    
    
}

class PromotionApplyModeDto:Codable {
    let display:String
    let statusCnt:Int
    let value:Int
}
