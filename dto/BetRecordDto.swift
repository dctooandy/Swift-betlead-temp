//
//  BetRecordDto.swift
//  betlead
//
//  Created by Victor on 2019/8/19.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class BetRecordDto: Codable {
    let betAmount: String
    let betContent: String?
    let betId: String
    let betLogSatus: ValueIntDto
    let betMaxUpdateAt: String
    let betNote: String?
    let betTime: String
    let betWinAmount: String
    let id: Int
    
    var statusColor: UIColor {
        switch betLogSatus.value {
        case 0:
            return Themes.secondaryYellow
        case 1:
            return Themes.secondaryGreen
        default:
            return Themes.secondaryRed
        }
    }
    
    var statusImage: UIImage? {
        
        switch betLogSatus.value {
        case 0:
            return UIImage(named: "icon-processing")
        case 1:
            return UIImage(named: "check-circle")
        default:
            return UIImage(named: "icon-failure")
        }
    }
}
