//
//  BetRecordSelectionView.swift
//  betlead
//
//  Created by Victor on 2019/8/6.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import RxSwift

class BetRecordSelectionView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    private var categoryBtn: ImagetTextButton!
    private var groupTypeBtn: ImagetTextButton!
    private let dpg = DisposeBag()
    private let onSelected = PublishSubject<BetRecordType>()
    private var selectedCategoryRow = 0 {
        didSet {
            setTitleLabel()
        }
    }
    
    private var selectedGroupRow = 0 {
        didSet {
            setTitleLabel()
        }
    }
    
    var gameTypes: [GameTypeDto] = [] {
        didSet {
            if gameTypes.count == 0 { return }
            setTitleLabel()
        }
    }
    
    private func setTitleLabel() {
        let categoryTitle = gameTypes[selectedCategoryRow].gameTypeName_Mobile
        let groupTitle = gameTypes[selectedCategoryRow].gameGroups.data[selectedGroupRow].gameGroupName
        categoryBtn.setTitle(text: categoryTitle)
        groupTypeBtn.setTitle(text: groupTitle)
    }
    
    func bind() {
        categoryBtn.rx.tap
            .subscribeSuccess { [weak self] in
                guard let strongSelf = self else { return }
                let pickerVC = PickerSheet()
                let titles = strongSelf.gameTypes.map({$0.gameTypeName_Mobile})
                pickerVC.setCatgory(titles, selected: strongSelf.selectedCategoryRow)
                pickerVC.start(viewController: UIApplication.topViewController()!)
                pickerVC.pickerOnSelected()
                    .subscribeSuccess({ (selectedCategoryRow) in
                        if selectedCategoryRow == strongSelf.selectedCategoryRow { return }
                        strongSelf.selectedCategoryRow = selectedCategoryRow
                        let categoryID = strongSelf.gameTypes[selectedCategoryRow].id
                        let companyTag = strongSelf.gameTypes[selectedCategoryRow].gameGroups.data.first?.gameCompanyTag ?? ""
                        let type = BetRecordType(categoryID: categoryID, companyTag: companyTag)
                        strongSelf.onSelected.onNext(type)
                    }).disposed(by: strongSelf.dpg)
            }.disposed(by: dpg)
        
        groupTypeBtn.rx.tap
            .subscribeSuccess { [weak self] in
                guard let strongSelf = self else { return }
                if strongSelf.gameTypes.count == 0 { return }
                let pickerVC = PickerSheet()
                let titles = strongSelf.gameTypes[strongSelf.selectedCategoryRow]
                                       .gameGroups.data.map({$0.gameGroupName})
                pickerVC.setCatgory(titles, selected: strongSelf.selectedGroupRow, barTitle: "平台")
                pickerVC.start(viewController: UIApplication.topViewController()!)
                pickerVC.pickerOnSelected().subscribeSuccess({ (selectedGroupRow) in
                    strongSelf.selectedGroupRow = selectedGroupRow
                    let categoryID = strongSelf.gameTypes[strongSelf.selectedCategoryRow].id
                    let companyTag = strongSelf.gameTypes[strongSelf.selectedCategoryRow].gameGroups.data[selectedGroupRow].gameCompanyTag
                    let type = BetRecordType(categoryID: categoryID, companyTag: companyTag ?? "")
                    strongSelf.onSelected.onNext(type)
                }).disposed(by: strongSelf.dpg)
            }.disposed(by: dpg)
    }
    
    private func setup() {
        categoryBtn = ImagetTextButton(title: "", titleColor: Themes.grayDark, image: UIImage(named: "icon-down-arrow"), imageColor: Themes.grayDark, space: 11, borderColor: Themes.grayBase)
        groupTypeBtn = ImagetTextButton(title: "", titleColor: Themes.grayDark, image: UIImage(named: "icon-down-arrow"), imageColor: Themes.grayDark, space: 11, borderColor: Themes.grayBase)
        
        addSubview(categoryBtn)
        addSubview(groupTypeBtn)
        
        categoryBtn.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.36)
        }
        
        groupTypeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(categoryBtn.snp.right).offset(Views.screenWidth * 0.021)
            make.top.right.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.60)
        }
        
    }
    
    func didSelected() -> Observable<BetRecordType> {
        return onSelected.asObserver()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct BetRecordType {
        let categoryID: Int
        let companyTag: String
    }
}
