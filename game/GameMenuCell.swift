//
//  GameMenuCell.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/25.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import Parchment
class GameMenuCell:PagingCell{
    
    
    private var options: PagingOptions?
    
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    private let icon:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        
    }
    
    private func setupViews(){
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        
        icon.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(12)
            maker.centerX.equalToSuperview()
            maker.size.equalTo(CGSize(width: 24, height: 24))
        }
        titleLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(icon.snp.bottom).offset(10)
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
        self.options = options
        guard let options = self.options ,
              let pageItem = (pagingItem as? GameMenuCellPagingItem) else { return }
        titleLabel.text = pageItem.title
        titleLabel.textColor = selected ? options.selectedTextColor : options.textColor
        icon.image = UIImage(named: pageItem.icon)?.blendedByColor(selected ? options.selectedTextColor : options.textColor)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let options = options else { return }
        
        if let attributes = layoutAttributes as? PagingCellLayoutAttributes {
            titleLabel.textColor = UIColor.interpolate(
                from: options.textColor,
                to: options.selectedTextColor,
                with: attributes.progress)
            
            icon.tintColor = UIColor.interpolate(
                from: options.textColor,
                to: options.selectedTextColor,
                with: attributes.progress)

        }
    }
}

class GameMenuCellPagingItem:PagingItem , Comparable , Hashable {
    static func < (lhs: GameMenuCellPagingItem, rhs: GameMenuCellPagingItem) -> Bool {
        return lhs.index < rhs.index
    }
    
    static func == (lhs: GameMenuCellPagingItem, rhs: GameMenuCellPagingItem) -> Bool {
        return lhs.title == rhs.title && lhs.icon == rhs.icon
    }
    
    var hashValue: Int {
        return index.hashValue &+ title.hashValue
    }
    let index:Int
    let icon:String
    let title:String 
    
    init(index:Int, title:String , icon:String){
        self.index = index
        self.title = title
        self.icon = icon
    }
    
}
