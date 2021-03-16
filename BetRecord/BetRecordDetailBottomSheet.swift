//
//  BetRecordDetailBottomSheet.swift
//  betlead
//
//  Created by Victor on 2019/7/26.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class BetRecordDetailBottomSheet: BaseBottomSheet {
    
    let dateTitleLabel: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCSemibold(20)
        return lb
    }()
    
    let imageView = UIImageView()
    
    let betStatusLabel: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCSemibold(16)
        lb.textColor = Themes.grayBase
        return lb
    }()
    
    let betDetailView = BetDetailView.loadNib()
    
    let lastUpdateLb: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(16)
        lb.textColor = Themes.grayBase
        return lb
    }()
    
    init(_ data: BetRecordDto) {
        super.init()
        submitBtn.isHidden = true
        bindServiceBtn()
        titleLabel.text = "投注明細"
        dateTitleLabel.text = data.betTime
        imageView.image = data.statusImage
        betStatusLabel.text = data.betLogSatus.display ?? "--"
        betDetailView.setData(data)
        lastUpdateLb.text = "资料最後更新：" + data.betMaxUpdateAt
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(_ parameters: Any? = nil) {
        super.init()
    }
    
    func bindServiceBtn() {
        serviceBtn.rx.tap
            .subscribeSuccess {
                print("bet record detail service btn pressed.")
                LiveChatService.share.betLeadServicePresent()
            }.disposed(by: disposeBag)
    }
    
    override func setupViews() {
        super.setupViews()
        defaultContainer.addSubview(dateTitleLabel)
        defaultContainer.addSubview(imageView)
        defaultContainer.addSubview(betStatusLabel)
        defaultContainer.addSubview(betDetailView)
        defaultContainer.addSubview(lastUpdateLb)
        
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
        }
        
        dateTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(separator.snp.bottom).offset(topOffset(32/812))
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(dateTitleLabel.snp.bottom).offset(topOffset(23/812))
            make.size.equalTo(sizeFrom(scale: 75/375))
            make.centerX.equalToSuperview()
        }
        
        betStatusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(topOffset(18/812))
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        betDetailView.snp.makeConstraints { (make) in
            make.top.equalTo(betStatusLabel.snp.bottom).offset(topOffset(28/812))
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.885)
        }
        
        lastUpdateLb.snp.makeConstraints { (make) in
            make.top.equalTo(betDetailView.snp.bottom).offset(topOffset(20/812))
            make.bottom.equalToSuperview().offset(-(Views.bottomOffset + 5))
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
    }
}
