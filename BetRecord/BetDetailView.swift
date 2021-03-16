//
//  BetDetailView.swift
//  betlead
//
//  Created by Victor on 2019/7/26.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit

class BetDetailView: UIView {

    @IBOutlet weak var betNumberLb: UILabel!
    @IBOutlet weak var betTypeLb: UILabel!
    @IBOutlet weak var winLoseAmountLb: UILabel!
    @IBOutlet weak var waterAmountLb: UILabel!
    @IBOutlet weak var betStatusLb: UILabel!
    @IBOutlet weak var remarkLb: VerticalTopAlignLabel!
    
    func setData(_ data: BetRecordDto) {
        betNumberLb.text = data.betId
        betTypeLb.text = data.betContent ?? ""
        winLoseAmountLb.text = "¥" + data.betWinAmount
        waterAmountLb.text = "¥" + data.betAmount
        betStatusLb.text = data.betLogSatus.display ?? "--"
        remarkLb.text = data.betNote ?? "无"
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = rect.height * 0.02
        clipsToBounds = true
    }
    

}
