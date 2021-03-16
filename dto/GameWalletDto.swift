//
//  GameWalletDto.swift
//  betlead
//
//  Created by Victor on 2019/8/13.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class GameWalletDto: Codable {
    let gameGroup: ValueStringDto
    let gameAmount: Float
    let gameStatus: ValueIntDto
    
}
