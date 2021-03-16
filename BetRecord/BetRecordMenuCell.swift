//
//  BetRecordMenuCell.swift
//  betlead
//
//  Created by Victor on 2019/7/23.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit

class BetRecordMenuCell: UICollectionViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isSelected = false
        setup()
    }
    
    let titleLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.font = Fonts.pingFangTCRegular(16)
        lb.layer.cornerRadius = height(40/812) / 2
        lb.clipsToBounds = true
        return lb
    }()
    
    override var isSelected: Bool {
       
        didSet {
            if self.isSelected {
                titleLabel.textColor = .white
                titleLabel.backgroundColor = Themes.primaryBase
            } else {
                titleLabel.textColor = Themes.grayDark
                titleLabel.backgroundColor = Themes.grayLighter
            }
        }
    }
    
    func setup() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(height(40/812))
        }
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func selected(_ selected: Bool) {
        isSelected = selected
    }
    
}
