//
//  WalletCollectionViewCell.swift
//  betlead
//
//  Created by Victor on 2019/8/6.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit

class GameWalletCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(16)
        lb.textColor = Themes.grayDark
        lb.textAlignment = .center
        return lb
    }()
    
    private let amountLb: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(14)
        lb.textColor = Themes.grayBase
        lb.textAlignment = .center
        return lb
    }()
    
    private let recycleImv: UIImageView = {
        let imv = UIImageView(image: UIImage(named: "icon-recycle"))
        return imv
    }()
    
    private let activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.style = .gray
        activity.isHidden = true
        return activity
    }()
    private var dto: GameWalletDto?
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 8
        layer.borderColor = Themes.grayLighter.cgColor
        layer.borderWidth = 1.0
        contentView.addSubview(titleLabel)
        contentView.addSubview(amountLb)
        contentView.addSubview(activity)
        contentView.addSubview(recycleImv)
        
        recycleImv.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.size.equalTo(12)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topOffset(16/812))
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
        }
        
        amountLb.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(topOffset(8/812))
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-topOffset(16/812))
            make.height.equalTo(20)
        }
        
        activity.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(30)
        }
        
    }
    
    func setData(_ dto: GameWalletDto) {
        self.dto = dto
        titleLabel.text = dto.gameGroup.display ?? "no name"
        if  dto.gameStatus.value == 1 {
            
            amountLb.text = dto.gameAmount.description.numberFormatter(.currency, 2)
            amountLb.textColor = Themes.grayBase
        } else {
            amountLb.text = dto.gameStatus.display ?? "未知状态"
            amountLb.textColor = Themes.secondaryRed
        }
    }
    
    func startActivity() {
        if activity.isAnimating || dto!.gameStatus.value != 1 { return }
        isUserInteractionEnabled = false
        DispatchQueue.main.async { [weak self] in
            self?.activity.startAnimating()
        }
    }
    
    func stopActivity() {
        if !activity.isAnimating { return }
        isUserInteractionEnabled = true
        DispatchQueue.main.async { [weak self] in
            self?.activity.stopAnimating()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
