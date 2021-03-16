//
//  BetRecordViewController.swift
//  betlead
//
//  Created by Victor on 2019/7/1.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import Parchment
import RxSwift
import RxCocoa

class BetRecordViewController: RefreshViewController {
    
    var dateType: DateType = .today {
        didSet {
            DispatchQueue.main.async {
                self.dateTypeDidChange()
                self.fetchRecord()
            }
        }
    }
    private let selectionView = BetRecordSelectionView()
    
    let clockImv: UIImageView = {
        let imv = UIImageView(image: UIImage(named: "icon-clock"))
        return imv
    }()
    
    let dateTimeLb: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(15)
        lb.textColor = Themes.grayBase
        lb.adjustsFontSizeToFitWidth = true
        let range = DateType.today.dateRange()
        let d1 = "\(range.start.toString(format: "YYYY/MM/dd"))"
        let d2 = "\(range.end.toString(format: "YYYY/MM/dd"))"
        lb.text = "\(d1) 00:00 ~ \(d2) 23:59"
        return lb
    }()
    
    private var gameTypeDtos: [GameTypeDto]? = nil {
        didSet {
            selectionView.gameTypes = gameTypeDtos ?? []
        }
    }
    
    private lazy var mainTableView: UITableView = {
        let tb = UITableView()
        tb.registerCell(type: BetRecordCell.self)
        tb.showsVerticalScrollIndicator = false
        tb.showsHorizontalScrollIndicator = false
        tb.backgroundColor = .clear
        tb.separatorStyle = .none
        tb.backgroundView = NoDataView(image: UIImage(named: "icon-nodata"), title: "暂无投注记录")
        tb.backgroundView?.isHidden = true
        self.tableView = tb
        return tb
    }()
    
    private var selectedGameType: (type: Int, tag: String)? = nil {
        didSet {
            fetchRecord()
        }
    }
    
    private var selectedDate:(d1: String, d2: String) = {
        let range = DateType.today.dateRange()
        let d1 = "\(range.start.toString(format: "YYYY-MM-dd"))"
        let d2 = "\(range.end.toString(format: "YYYY-MM-dd"))"
        return ("\(d1) 00:00:00", "\(d2) 23:59:59")
    }()
    
    private let format = "YYYY/MM/dd HH:mm"
    
    var memberCreateDate: Date? = nil
    
    private var data: [BetRecordDto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Themes.grayLightest
        title = "投注记录"
        fetchPersonalInfo()
        fetchGameType()
        addDateSelectedButton()
        setup()
        bind()
        if #available(iOS 11, *) {
            //self.recordCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }
    }
    
    override func refreshing() {
        fetchRecord()
    }
    
    private func setup() {
        
        view.addSubview(selectionView)
        view.addSubview(dateTimeLb)
        view.addSubview(clockImv)
        view.addSubview(mainTableView)
        
        selectionView.gameTypes = self.gameTypeDtos ?? []
        selectionView.snp.makeConstraints { (make) in
            let top = topOffset(20/812) //+ Views.navigationBarHeight + Views.statusBarHeight
            make.top.equalToSuperview().offset(top)
            make.width.equalToSuperview().multipliedBy(0.872)
            make.centerX.equalToSuperview()
            make.height.equalTo(height(40/812))
        }
        let dateView = UIView()
        view.addSubview(dateView)
        dateView.addSubview(dateTimeLb)
        dateView.addSubview(clockImv)
        dateView.snp.makeConstraints { (make) in
            make.top.equalTo(selectionView.snp.bottom).offset(topOffset(20/812))
            make.width.equalToSuperview().multipliedBy(0.76)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
        }
        
        dateTimeLb.snp.makeConstraints { (make) in
            make.left.equalTo(clockImv.snp.right).offset(leftRightOffset(9/375))
            make.top.right.bottom.equalToSuperview()
        }
        
        clockImv.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.size.equalTo(20)
        }
        
        mainTableView.snp.makeConstraints { (make) in
            make.top.equalTo(dateView.snp.bottom).offset(topOffset(20/812))
            make.bottom.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.872)
        }

    }
    
    func bind() {
        selectionView.didSelected().subscribeSuccess { [weak self] (betRecordType) in
            let categoryID = betRecordType.categoryID
            let companyTag = betRecordType.companyTag
            print("selected categoryID: \(categoryID), selected companyTag: \(companyTag)")
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                self?.selectedGameType = (categoryID, companyTag)
            })
            
            }.disposed(by: disposeBag)
    }
    
    private func addDateSelectedButton() {
        let rightBtn = UIButton()
        rightBtn.setImage(UIImage(named: "icon-calendar"), for: .normal)
        rightBtn.addTarget(self, action: #selector(showCalendar), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    @objc func showCalendar() {
        let calendarVC = CalendarViewController()
        let days = Date.daysBetweenDate(from: memberCreateDate ?? Date(), to: Date())
        calendarVC.recordDays = days > 89 ? 89 : days
        calendarVC.show(navigationController ?? self)
        calendarVC.rxDoneBtnPressed()
            .subscribeSuccess({ [weak self] (dates) in
                self?.dateConstruct(dates)
            }).disposed(by:disposeBag)
    }
    
    func dateTypeDidChange() {
        let range = dateType.dateRange()
        selectedDate = ("\(range.start.toString(format: "YYYY-MM-dd")) 00:00:00", "\(range.end.toString(format: "YYYY-MM-dd")) 23:59:59")
        let d1 = "\(range.start.toString(format: "YYYY/MM/dd"))"
        let d2 = "\(range.end.toString(format: "YYYY/MM/dd"))"
        dateTimeLb.text = "\(d1) 00:00 ~ \(d2) 23:59"
    }
    
    func dateConstruct(_ dates: [Date]) {
        let finaleDates = dates.sorted(by: <)
        dateType = .custom(start: finaleDates[0], end: finaleDates[1])
    }
    
    //MARK: API
    private func fetchPersonalInfo() { // 顯示日期需要知道會員的註冊時間
        MemberDto.rxShare
            .subscribeSuccess {[weak self] (memberDto) in
                self?.memberCreateDate = memberDto?.memberCreatedAt.toDate(format: "YYYY-MM-dd HH:mm:ss")?.toString(format: "YYYY-MM-dd").toDate(format: "YYYY-MM-dd")
            }.disposed(by: disposeBag)
    }
    
    private func fetchGameType() {
        Beans.gameServer
            .getGameType()
            .subscribeSuccess { [weak self] (gameTypes) in
                self?.gameTypeDtos = gameTypes
                if self?.selectedGameType == nil {
                    let id = gameTypes[0].gameCategory
                    let tag = gameTypes[0].gameGroups.data[0].gameCompanyTag
                    print("id: \(id), tag: \(tag ?? "no tag")")
                    self?.selectedGameType = (id, tag ?? "")
                }
            }.disposed(by: disposeBag)
    }
    
    private func fetchRecord() {
        
        guard let gameType = selectedGameType else { return }
        let sDate = selectedDate.d1
        let eDate = selectedDate.d2
        DispatchQueue.main.async {
            LoadingViewController.show()
        }
        
        Beans.memberServer
            .getBetRecord(gameType: gameType.type, tag: gameType.tag, sDate: sDate, eDate: eDate)
            .do(onSuccess:{ _ in
                    self.refreshControl.endRefreshing() }
                ,onError:  { _ in
                    self.refreshControl.endRefreshing()})
            .subscribe(onSuccess: { [weak self] (dto) in
                _ = LoadingViewController.dismiss()
                self?.data = dto
                DispatchQueue.main.async {
                    self?.mainTableView.backgroundView?.isHidden = !dto.isEmpty
                    self?.mainTableView.reloadData()
                }
            }) { (error) in
                _ = LoadingViewController.dismiss()
                ErrorHandler.show(error: error)
        }.disposed(by: disposeBag)
    }
}

// MARK: - TableView delegate datasoruce
extension BetRecordViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: BetRecordCell.self, indexPath: indexPath)
        cell.setData(data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let d = data[indexPath.row]
        DispatchQueue.main.async {
            BetRecordDetailBottomSheet(d).start(viewController: self)
        }
    }
}
//MARK: - Date construct
extension BetRecordViewController {
    enum DateType {
        case today
        case yesterday
        case thisWeek
        case lastWeek
        case thisMonth
        case custom(start: Date, end: Date)
        
        init(row: Int, start: Date = Date(), end: Date = Date()) {
            switch row {
            case 0: self = .today
            case 1: self = .yesterday
            case 2: self = .thisWeek
            case 3: self = .lastWeek
            case 4: self = .thisMonth
            case 5: self = .custom(start: start, end: end)
            default: self = .today
            }
        }
        
        func selected(for row: Int) -> Bool{
            return self.row == row
        }
        
        var row: Int {
            switch self {
            case .today: return 0
            case .yesterday: return 1
            case .thisWeek: return 2
            case .lastWeek: return 3
            case .thisMonth: return 4
            case .custom: return 5
            }
        }
        
        func dateRange() -> (start: Date, end: Date) {
            switch self {
            case .today:
                let today = Date.today
                let todayEnd = today.addDay(day: 0)
                return (today, todayEnd)
            case .yesterday:
                let yesterday = Date.today.addDay(day: -1)
                let yesterdayEnd = Date.today.addDay(day: -1)
                return (yesterday, yesterdayEnd)
            case .thisWeek:
                let weekStart = Date.today.startOfWeek()
                let weekEnd = Date.today.endOfWeek()
                return (weekStart, weekEnd)
            case .lastWeek:
                let lastWkStart = Date.today.startOfWeek().addDay(day: -7)
                let lastWkEnd = Date.today.endOfWeek().addDay(day: -7)
                return (lastWkStart, lastWkEnd)
            case .thisMonth:
                let mStart = Date.today.getThisMonthStart()
                let mEnd = Date.today.getThisMonthEnd()
                return (mStart, mEnd)
            case .custom(let start,let end):
                print("custom date range: \(start) ~ \(end)")
                return (start, end)
            }
        }
    }
}
