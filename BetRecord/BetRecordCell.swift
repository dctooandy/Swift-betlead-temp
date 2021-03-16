//
//  BetRecordCell.swift
//  betlead
//
//  Created by Victor on 2019/7/2.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit

class BetRecordCell: UITableViewCell {

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.applyCornerRadius(radius: 12)
        v.layer.borderColor = Themes.grayLighter.cgColor
        v.layer.borderWidth = 1.0
        return v
    }()
    
    private let dateTimeLb: UILabel = {
        let lb = UILabel()
        lb.textColor = Themes.grayBase
        lb.textAlignment = .left
        lb.font = Fonts.pingFangTCRegular(14)
        return lb
    }()
    
    private let statusLb: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(14)
        return lb
    }()
    private let betTitleLb: UILabel = {
        let lb = UILabel()
        lb.textColor = Themes.grayDarkest
        lb.text = "投注內容"
        lb.textAlignment = .left
        lb.font = Fonts.pingFangTCSemibold(16)
        lb.alpha = 0.0
        return lb
    }()
    private let waterTitleLb: UILabel = {
        let lb = UILabel()
        lb.text = "流水金额"
        lb.textColor = Themes.grayBase
        lb.textAlignment = .left
        lb.font = Fonts.pingFangTCSemibold(14)
        return lb
    }()
    private let waterAmountLb: UILabel = {
        let lb = UILabel()
        lb.textColor = Themes.grayDarkest
        lb.textAlignment = .left
        lb.font = Fonts.pingFangTCSemibold(16)
        return lb
    }()
    
    private let wlTitleLb: UILabel = {
        let lb = UILabel()
        lb.text = "输赢金额"
        lb.textColor = Themes.grayBase
        lb.textAlignment = .left
        lb.font = Fonts.pingFangTCSemibold(14)
        return lb
    }()
    private let wlAmountLb: UILabel = {
        let lb = UILabel()
        lb.textColor = Themes.grayDarkest
        lb.textAlignment = .left
        lb.font = Fonts.pingFangTCSemibold(16)
        return lb
    }()
    
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
        
        containerView.addSubview(dateTimeLb)
        containerView.addSubview(statusLb)
        containerView.addSubview(betTitleLb)
        
        let stack = createStackView(views: [createStackView(views: [waterTitleLb, waterAmountLb],
                                                            axis: .vertical),
                                            createStackView(views: [wlTitleLb, wlAmountLb],
                                                            axis: .vertical)],
                                    axis: .horizontal,
                                    spacing: 11)
        
        containerView.addSubview(stack)
        dateTimeLb.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topOffset(24/812))
            make.left.equalToSuperview().offset(leftRightOffset(20/375))
            make.height.equalTo(20)
        }
        
        statusLb.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftRightOffset(20/375))
            make.height.equalTo(20)
            make.centerY.equalTo(dateTimeLb)
        }
        
        betTitleLb.snp.makeConstraints { (make) in
            make.top.equalTo(dateTimeLb.snp.bottom).offset(topOffset(12/812))
            make.left.equalTo(dateTimeLb)
            make.height.equalTo(20)
        }
        
        stack.snp.makeConstraints { (make) in
            make.top.equalTo(betTitleLb.snp.bottom).offset(topOffset(13/812))
            make.left.equalToSuperview().offset(leftRightOffset(20/375))
            make.right.equalToSuperview().offset(-leftRightOffset(20/375))
            make.bottom.equalToSuperview().offset(-topOffset(20/812))
        }
        
    }
    func createStackView(views: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0) -> UIStackView {
        let st = UIStackView(arrangedSubviews: views)
        st.axis = axis
        st.alignment = .fill
        st.distribution = .fillEqually
        st.spacing = spacing
        return st
    }
    
    func setData(_ data: BetRecordDto) {
        statusLb.text = data.betLogSatus.display ?? "--"
        statusLb.textColor = data.statusColor
        dateTimeLb.text = data.betTime
        waterAmountLb.text = "¥" + data.betAmount
        wlAmountLb.text = "¥" + data.betWinAmount
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

