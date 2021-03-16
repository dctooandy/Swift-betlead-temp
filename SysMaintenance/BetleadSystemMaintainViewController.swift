//
//  BetleadSystemMaintenanceViewController.swift
//  BetLead-Sport
//
//  Created by Andy Chen on 2019/9/12.
//  Copyright © 2019 lismart. All rights reserved.
//

import Foundation


class BetleadSystemMaintainViewController:BaseViewController {
    
    private let bgIamgeView = UIImageView(image: UIImage(named: "system-maintain"))
    private let titleLabel = UILabel.customLabel(font: UIFont.systemFont(ofSize: 24, weight: .light), alignment: .center, textColor: .white, text: "抱歉！系统维护中…")
    private let dateLabel = UILabel.customLabel(font: UIFont.systemFont(ofSize: 16, weight: .light), alignment: .center, textColor: UIColor(rgb: 0xc2aaf2), text: "維護時間：2019/6/28 10:30～16:30")
    private let serviceIcon = UIImageView(image: UIImage(named: "icon-service"))
    private let serviceLabel = UILabel.customLabel(font: UIFont.systemFont(ofSize: 14), alignment: .center, textColor: .white, text: "客服")
    
    init(message:String) {
        dateLabel.text = message
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        BetleadAssistiveTouch.share.isHidden = true
    }
    private func setupViews(){
        bgIamgeView.contentMode = .scaleAspectFill
        view.addSubview(bgIamgeView)
        view.addSubview(titleLabel)
        view.addSubview(dateLabel)
        view.addSubview(serviceIcon)
        view.addSubview(serviceLabel)
        
        bgIamgeView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        serviceIcon.snp.makeConstraints { (maker) in
            maker.size.equalTo(CGSize(width: 42, height: 42))
            maker.top.equalTo(Views.topOffset + 13)
            maker.trailing.equalTo(-25)
        }
        serviceLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(serviceIcon.snp.bottom).offset(8)
            maker.centerX.equalTo(serviceIcon)
        }
        dateLabel.snp.makeConstraints { (maker) in
            maker.bottom.equalToSuperview().offset(-Views.bottomOffset - 28)
            maker.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(dateLabel.snp.top).offset(-20)
            maker.centerX.equalToSuperview()
        }
    }
}
