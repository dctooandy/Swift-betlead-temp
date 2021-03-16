//
//  CalendarViewController.swift
//  betlead
//
//  Created by Victor on 2019/7/25.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import FSCalendar
import Toaster
import RxSwift

class CalendarViewController: BaseViewController {
    
    private lazy var mainCalendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.locale = Locale(identifier: "zh_Hans_CN")
        calendar.scrollDirection = .horizontal
        calendar.allowsMultipleSelection = true
        calendar.appearance.borderSelectionColor = Themes.primaryBase
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.selectionColor = .clear
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.titleFont = Fonts.pingFangTCRegular(16)
        calendar.register(SelectedCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.placeholderType = .none
        calendar.dataSource = self
        calendar.delegate = self
        return calendar
    }()
    
    var recordDays: Int = 89
    
    private lazy var doneButton: OKButton = {
        let btn = OKButton()
        btn.setTitle("完成", for: .normal)
        btn.backgroundColor = Themes.primaryBase
        btn.titleColor = .white
        return btn
    }()
    
    private lazy var contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        return v
    }()
   
    var selectedDate: [Date] = []
    
    private let arrowImv = UIImageView(image: UIImage(named: "icon-arrow-up"))
    
    private lazy var onClick = PublishSubject<[Date]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
        setupCalendar()
    }
    
//    private var upArrowImv = UIImageView(image: UIImage(named: "icon-up-arrow"))
//
//    private var downArrowImv = UIImageView(image: UIImage(named: "icon-down-arrow"))
    
    func setup() {
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, a: 0.5)
        view.addSubview(arrowImv)
        view.addSubview(contentView)
        contentView.addSubview(mainCalendar)
        contentView.addSubview(doneButton)
//        contentView.addSubview(upArrowImv)
//        contentView.addSubview(downArrowImv)
        
        contentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(Int((Views.screenWidth * 0.9) / 7) * 7)
            make.height.equalTo(height(510/812))
        }
        
        arrowImv.snp.makeConstraints { (make) in
            make.size.equalTo(20)
            make.bottom.equalTo(contentView.snp.top)
            make.right.equalTo(contentView).offset(-20)
        }
        
        doneButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topOffset(25/812))
            make.right.equalToSuperview().offset(-(leftRightOffset(20/375)))
            make.width.equalTo(width(70/375))
            make.height.equalTo(height(30/812))
        }
//        upArrowImv.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(topOffset(25/812))
//            make.size.equalTo(30)
//        }
//
        mainCalendar.snp.makeConstraints { (make) in
            make.top.equalTo(doneButton.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
//
//        downArrowImv.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(topOffset(25/812))
//            make.size.equalTo(30)
//        }
    }
    
    func bind() {
        doneButton.rx.tap
            .subscribeSuccess {  [weak self] in
                guard let strongSelf = self else { return }
                if strongSelf.selectedDate.count == 0 {
                    Toast.show(msg: "请选择日期区间")
                    return
                }
                if strongSelf.selectedDate.count == 1 {
                    let d1 = strongSelf.selectedDate[0]
                    strongSelf.selectedDate.append(d1)
                }
                strongSelf.onClick.onNext(strongSelf.selectedDate)
                DispatchQueue.main.async {
                    strongSelf.dismissVC()
                }
            }.disposed(by: disposeBag)
    }
    
    func dismissVC() {
        removeFromParent()
        view.removeFromSuperview()
    }
    
    func rxDoneBtnPressed() -> Observable<[Date]> {
        return onClick.asObserver()
    }
    
    func show(_ viewController: UIViewController) {
        viewController.addChild(self)
        viewController.view.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func setupCalendar() {
        if selectedDate.count == 0 { return }
        selectedDate.forEach{ mainCalendar.select($0)}
        let lastDate = selectedDate.last ?? selectedDate.first
        selectedDate.removeLast()
        caculatorContainDates(lastDate!)
    }
}

extension CalendarViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissVC()
    }
    
}
// MARK: - calendar delegate datasource
extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        print(Calendar.current.date(byAdding: .day, value: -recordDays, to: Date())!)
        return Calendar.current.date(byAdding: .day, value: -recordDays, to: Date())!
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: position)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if selectedDate.count >= 2 {
            // remove selected
            reselectedDate(date)
        } else {
            caculatorContainDates(date)
        }
        configureVisibleCells()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if selectedDate.count >= 2 {
            reselectedDate(date)
        } else {
            guard let index = selectedDate.firstIndex(of: date) else { return }
            selectedDate.remove(at: Int(index))
        }
        
        configureVisibleCells()
    }
    
    private func reselectedDate(_ date: Date) {
        mainCalendar.selectedDates.forEach{ mainCalendar.deselect($0)}
        selectedDate.removeAll()
        selectedDate.append(date)
        mainCalendar.select(date)
    }
    
    private func caculatorContainDates(_ date: Date) {
        if selectedDate.count == 1 {
            
            let firstDate = selectedDate[0]
            var secondDate = date
            while secondDate > firstDate || secondDate < firstDate {
                if let d = Calendar.current.date(byAdding: .day,
                                                 value: secondDate > firstDate ? -1 : 1,
                                                 to: secondDate) {
                    mainCalendar.select(d)
                    secondDate = d
                }
            }
        }
        
        selectedDate.append(date)
    }
    
    
    
    private func configureVisibleCells() {
        mainCalendar.visibleCells().forEach { (cell) in
            let date = mainCalendar.date(for: cell)
            let position = mainCalendar.monthPosition(for: cell)
            configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        
        let cell = (cell as! SelectedCalendarCell)
        
        if position == .current {
            
            var selectionType = SelectionType.none
            
            if mainCalendar.selectedDates.contains(date) {
                let gregorian = Calendar(identifier: .gregorian)
                let previousDate = gregorian.date(byAdding: .day, value: -1, to: date)!
                let nextDate = gregorian.date(byAdding: .day, value: 1, to: date)!
                if mainCalendar.selectedDates.contains(date) {
                    if mainCalendar.selectedDates.contains(previousDate) && mainCalendar.selectedDates.contains(nextDate) {
                        selectionType = .middle
                    } else if mainCalendar.selectedDates.contains(previousDate) && mainCalendar.selectedDates.contains(date) {
                        selectionType = .rightBorder
                    } else if mainCalendar.selectedDates.contains(nextDate) {
                        selectionType = .leftBorder
                    } else {
                        selectionType = .single
                    }
                }
            } else {
                selectionType = .none
                
            }
            cell.selectionType = selectionType
        } else {
            cell.selectionType = .none
        }
    }
}
