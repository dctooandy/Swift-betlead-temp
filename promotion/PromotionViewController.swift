//
//  PromotionViewController.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/20.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit
import Parchment

enum PromotionType:Int ,CaseIterable{
    case all = 0, festival,sport,human,chess,video,lottery,vip
    var title:String {
        switch self {
        case .all:
            return "全部"
        case .festival:
            return "节日"
        case .sport:
            return "体育"
        case .human:
            return "真人"
        case .chess:
            return "棋牌"
        case .video:
            return "电子"
        case .lottery:
            return "彩票"
        case .vip:
            return "VIP"
        }
    }
}

class PromotionViewController:BaseViewController {
    private var pageViewcontroller = PagingViewController<PagingIndexItem>()
    private let topBgView = UIImageView(image: UIImage(named: "navigation-bg") )
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "优惠活动"
        return label
    }()
    private var viewcontrollers = [DivisionPromotionViewController]()
    private let titles = ["節日","體育","真人","棋牌","电子","彩票","VIP"]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopview()
        view.backgroundColor = .white
        addDivisionPromotionViewController()
        setupPageingVC()
    }
   
    private func setupTopview(){
        view.addSubview(topBgView)
        view.addSubview(titleLabel)
        topBgView.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.equalToSuperview()
            maker.height.equalTo(Views.topOffset)
        }
        titleLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.bottom.equalTo(topBgView.snp.bottom).offset(-12)
        }
    }

    private func addDivisionPromotionViewController(){
        for promotionType in PromotionType.allCases {
            let vc = DivisionPromotionViewController(promotionType: promotionType)
            vc.title = promotionType.title
            viewcontrollers.append(vc)
        }
    }
    
    private func setupPageingVC(){
        self.pageViewcontroller.delegate = self
        self.pageViewcontroller.dataSource = self
        
        // menu item
        self.pageViewcontroller.menuItemSize = PagingMenuItemSize.fixed(width: 36, height: 60)
        self.pageViewcontroller.menuItemSpacing = 36
        self.pageViewcontroller.menuInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)
        self.pageViewcontroller.menuBackgroundColor = .clear
        
        // menu text
        self.pageViewcontroller.selectedFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.pageViewcontroller.font =  UIFont.systemFont(ofSize: 16)
        self.pageViewcontroller.textColor = Themes.grayDarker
        self.pageViewcontroller.selectedTextColor = Themes.grayDarker
        
        // menu indicator
        self.pageViewcontroller.indicatorColor = Themes.primaryBase
        self.pageViewcontroller.indicatorClass = RoundedIndicatorView.self
        self.pageViewcontroller.indicatorOptions = .visible(height: 3, zIndex: Int.max, spacing: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), insets: .zero)
        
        addChild(pageViewcontroller)
        view.addSubview(pageViewcontroller.view)
        pageViewcontroller.view.snp.makeConstraints({ (make) in
            make.top.equalTo(topBgView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        })
        
    }
    
}
extension PromotionViewController: PagingViewControllerDataSource, PagingViewControllerDelegate {
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T where T : PagingItem, T : Comparable, T : Hashable {
        
            return PagingIndexItem(index: index, title: viewcontrollers[index].title ?? "") as! T
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController where T : PagingItem, T : Comparable, T : Hashable {
        
        return viewcontrollers[index]
    }
    
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int where T : PagingItem, T : Comparable, T : Hashable {
        
        return viewcontrollers.count
    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, willScrollToItem pagingItem: T, startingViewController: UIViewController, destinationViewController: UIViewController) where T : PagingItem, T : Comparable, T : Hashable {
        LoadingViewController.show()
    }
}

