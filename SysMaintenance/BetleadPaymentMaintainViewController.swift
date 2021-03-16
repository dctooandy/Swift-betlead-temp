//
//  BetleadPaymentMaintainViewController.swift
//  BetLead-Sport
//
//  Created by Andy Chen on 2019/9/26.
//  Copyright © 2019 lismart. All rights reserved.
//

import Foundation


class BetleadPaymentMaintainViewController:BetleadSportDialog {
    
    override func setupViews() {
        super.setupViews()
        okLabel.isHidden = true
        cancelLabel.snp.remakeConstraints { (maker) in
            maker.top.equalTo(contentLabel.snp.bottom).offset(14)
            maker.size.equalTo(CGSize(width: 114, height: 28))
            maker.centerX.equalToSuperview()
            maker.bottom.equalTo(-14)
        }
    }
    
}
