//
//  gameTitleView.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/27.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class GameTitleView:UIView {
    
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.text = "PG电子"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    private let icon = UIImageView(image: UIImage(named: "icon-down-arrow")?.blendedByColor(.white))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        addSubview(titleLabel)
        addSubview(icon)
        titleLabel.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
        }
        icon.snp.makeConstraints { (maker) in
            maker.leading.equalTo(titleLabel.snp.trailing).offset(10)
            maker.centerY.equalTo(titleLabel)
            maker.size.equalTo(CGSize(width: 16, height: 16))
        }
    }
    
    func setTitle(_ title:String) {
        titleLabel.text = title
    }
    
    override var intrinsicContentSize:CGSize {
        let size = UIView.layoutFittingExpandedSize
        return CGSize(width: Views.screenWidth - 100, height: size.height)
    }
    
}
