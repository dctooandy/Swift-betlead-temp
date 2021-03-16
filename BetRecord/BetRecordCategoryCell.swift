//
//  BetRecordCategoryCell.swift
//  betlead
//
//  Created by Victor on 2019/7/30.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit

class BetRecordCategoryCell: UITableViewCell {
   
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.applyCornerRadius(radius: 12)
        v.layer.borderColor = Themes.grayLighter.cgColor
        v.layer.borderWidth = 1.0
        return v
    }()
    
    private let titleIconImv: UIImageView = {
        let imv = UIImageView(image: UIImage(named: "icon-right-arrow"))
        imv.contentMode = .scaleAspectFit
        return imv
    }()
    
    let titleLb: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCSemibold(20)
        lb.textColor = Themes.grayDarkest
        lb.textAlignment = .left
        return lb
    }()
    
    let ticketAmountTitleLb: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(16)
        lb.textColor = Themes.grayLight
        lb.text = "注单"
        return lb
    }()
    
    let ticketAmountLb: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(16)
        lb.textColor = Themes.grayDarkest
        return lb
    }()
    
    let winLoseAmountTitleLb: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(16)
        lb.textColor = Themes.grayLight
        lb.text = "输赢金额"
        return lb
    }()
    
    let winLoseAmountLb: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(16)
        lb.textColor = Themes.grayDarkest
        return lb
    }()
    
    let betAmountTitleLb: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(16)
        lb.textColor = Themes.grayLight
        lb.text = "投注金额"
        return lb
    }()
    
    let betAmountLb: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(16)
        lb.textColor = Themes.grayDarkest
        return lb
    }()
    
    func setData(title: String, ticket: String, winLoseAmount: String, betAmount: String) {
        titleLb.text = title
        ticketAmountLb.text = ticket
        winLoseAmountLb.text = winLoseAmount.numberFormatter(.currency, 2)
        betAmountLb.text = betAmount.numberFormatter(.currency, 2)
    }
    
    func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()//.offset(5)
            make.left.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-5)
        }
        
        containerView.addSubview(titleLb)
        containerView.addSubview(titleIconImv)
        titleLb.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topOffset(24/812))
            make.left.equalToSuperview().offset(leftRightOffset(20/375))
        }
        
        titleIconImv.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftRightOffset(20/375))
            make.centerY.equalTo(titleLb)
            make.size.equalTo(20)
        }
        
        // stack view setup
        let ticketStackView = UIStackView(arrangedSubviews: [ticketAmountTitleLb, ticketAmountLb])
        let wlStackView = UIStackView(arrangedSubviews: [winLoseAmountTitleLb, winLoseAmountLb])
        let betStackView = UIStackView(arrangedSubviews: [betAmountTitleLb, betAmountLb])
        betStackViewStyle([ticketStackView, wlStackView, betStackView])
        
        let infoStackView = UIStackView(arrangedSubviews: [ticketStackView, wlStackView, betStackView])
        infoStackView.axis = .horizontal
        infoStackView.alignment = .top
        infoStackView.distribution = .fillProportionally
        infoStackView.spacing = 20
        
        containerView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLb.snp.bottom).offset(topOffset(20/812))
            make.left.equalToSuperview().offset(leftRightOffset(20/375))
            make.right.equalToSuperview().offset(-leftRightOffset(20/375))
            make.bottom.equalToSuperview().offset(-leftRightOffset(24/812))
        }
    }
    
    func betStackViewStyle(_ views: [UIStackView]) {
        views.forEach { (s) in
            s.alignment = .leading
            s.distribution = .fill
            s.axis = .vertical
            s.spacing = 12
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
