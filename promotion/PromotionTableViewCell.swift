//
//  PromotionTableViewCell.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/20.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit

class PromotionTableViewCell:UITableViewCell {
    
    @IBOutlet weak var banner:UIImageView!
    @IBOutlet weak var hintIcon:UIImageView!
    @IBOutlet weak var hintLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var contentLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configureCell(promotionDto:PromotionDto){
        banner.sdLoad(with: URL(string: promotionDto.promotionImageMobile))
        titleLabel.text = promotionDto.promotionTitle
//        contentLabel.text = promotionDto.promotionContent
        contentLabel.text = promotionDto.promotionSubTitle
        hintLabel.text = promotionDto.applyMethod.text
        hintLabel.backgroundColor = promotionDto.applyMethod ==  PromotionDto.ApplyMethod.auto ? Themes.grayBase : Themes.secondaryOrange
    }
}
