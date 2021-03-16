//
//  GameTestViewController.swift
//  betlead
//
//  Created by Andy Chen on 2019/7/4.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import DropDown
class GameViewController : GameBaseViewController {
    
    enum GameType:Int,CaseIterable {
        case newest
        case hot
        case played
        case favorite
        case filter
        
        var title:String {
            switch self {
            case .newest:
                return "最新"
            case .hot:
                return "热门"
            case .played:
                return "曾经"
            case .favorite:
                return "最爱"
            case .filter:
                return "进阶"
            }
        }
        var icon:UIImage? {
            switch self {
            case .newest:
                return UIImage(named: "icon-newst")
            case .hot:
                return UIImage(named: "icon-hot")
            case .played:
                return UIImage(named: "icon-played")
            case .favorite:
                return UIImage(named: "icon-favorite")
            case .filter:
                return UIImage(named: "icon-filter")
            }
        }
    }
    private var gameDtos = [String:[GameDto]]()
    private var btns = [UIButton]()
    private var gameType = GameType.newest {
        didSet {
            selectedMenu(old: oldValue, new:gameType )
        }
    }
    private var lastGameType: GameType? = nil
    private let gameGroupDtos:[GameGroupDto]
    private let scrollView = UIScrollView()
    private var collectionViews = [UICollectionView]()
    private var menuTopConstraint:Constraint?
    private var coverTopConstraint:Constraint?
    private let gameBgView = UIImageView()
    private let coverView = UIView(color: .white)
    private let pupleBgView = UIView(color: Themes.primaryDark)
    private lazy var maxOffsetY:CGFloat =  gameBgViewHeight - Views.topOffset
    private let menuHeight:CGFloat = 80
    private let gameBgViewHeight = Views.screenHeight*0.39
    private let titleView = GameTitleView()
    private let searBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "search"), for: .normal)
        return btn
    }()
    private lazy var gameTypeDropDown:DropDown = {
        let dropDown = DropDown()
        dropDown.anchorView = titleView
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)! + 12)
        DropDown.appearance().backgroundColor = .white
        DropDown.appearance().selectionBackgroundColor = .white
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let selectedDto = self.gameGroupDtos[index]
            if !selectedDto.isEnterGameList {
                if selectedDto.gameGroupStatus ?? 1 == 2 {
                    DispatchQueue.main.async {
                        self.showAlert(title: "贴心小提示", message: "游戏维护中，请稍后再进入")
                    }
                } else {
                    self.enterGame(game_group_id: selectedDto.id, game_id: 0)
                }
                return
            }
            self.titleView.setTitle(item)
            self.groupId = "\(self.gameGroupDtos[index].id)"
        }
        dropDown.dataSource = self.gameGroupDtos.map({$0.gameGroupName})
        return dropDown
    }()
    init(isNavBarTransparent: Bool = false , gameGroupDtos:[GameGroupDto] ,groupId:Int) {
        self.gameGroupDtos = gameGroupDtos
        super.init(groupId: "\(groupId)", isNavBarTransparent:isNavBarTransparent)
        let selectedGroup = gameGroupDtos.filter { $0.id == groupId}.first
        self.titleView.setTitle(selectedGroup?.gameGroupName ?? "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameBgView.image = UIImage(named: "beach")
        setupNavigationBar()
        bindNavigationRightBtn()
        setupViews()
        setupMenuView()
        setupCollectionView()
        bindCollectionView()
        fetchGameList()
        selectedMenu(old: .newest, new: .newest)
        if #available(iOS 11, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
            self.collectionViews.forEach({$0.contentInsetAdjustmentBehavior = .never})
        } else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btns.forEach({$0.centerVertically()})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear")
        if lastGameType != nil {
            gameType = lastGameType!
            lastGameType = nil
        }
    }
    
    private func setupNavigationBar(){
        navigationItem.titleView = titleView
        titleView.rx.click.subscribeSuccess { (_) in
            self.gameTypeDropDown.show()
            }.disposed(by: disposeBag)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: searBtn)]
    }
    
    private func bindNavigationRightBtn() {
        searBtn.rx.tap.subscribeSuccess {[weak self] (_) in
            guard let weakSelf = self ,
                let groupId = weakSelf.groupId
                else { return }
            weakSelf.present(GameSearchingViewController.loadViewFromNib(groupId: groupId), animated: true, completion: nil)
            }.disposed(by: disposeBag)
    }
    private func setupViews(){
        view.addSubview(gameBgView)
        view.addSubview(coverView)
        view.addSubview(scrollView)
        view.addSubview(pupleBgView)
        pupleBgView.alpha = 0
        scrollView.backgroundColor = .clear
        gameBgView.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.equalToSuperview()
            maker.height.equalTo(gameBgViewHeight)
        }
        coverView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            coverTopConstraint = maker.top.equalTo(gameBgViewHeight + menuHeight).constraint
            maker.height.equalTo(Views.screenHeight)
        }
        
        pupleBgView.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.equalToSuperview()
            maker.height.equalTo(Views.topOffset)
        }
        scrollView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(UIEdgeInsets.zero)
        }
        scrollView.isScrollEnabled = false
    }
    private func setupMenuView(){
        let menuView = UIView(color: .white)
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        view.addSubview(menuView)
        menuView.addSubview(stackView)
        view.addSubview(menuView)
        menuView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            menuTopConstraint = maker.top.equalTo(gameBgViewHeight).constraint
            maker.height.equalTo(menuHeight)
        }
        stackView.snp.makeConstraints { (maker) in
            maker.leading.equalTo(24)
            maker.trailing.equalTo(-24)
            maker.centerY.equalToSuperview()
            
        }
        for gameType in GameType.allCases {
            let btn = UIButton()
            btn.setTitle(gameType.title, for: .normal)
            btn.setImage(gameType.icon?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn.tintColor = Themes.grayBase
            btn.setTitleColor(Themes.grayBase, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            stackView.addArrangedSubview(btn)
            btns.append(btn)
            btn.rx.tap.subscribeSuccess { (_) in
                self.gameType = gameType
                }.disposed(by: disposeBag)
        }
        
    }
    private func selectedMenu(old:GameType, new:GameType) {
        if (new == .played ||  new == .favorite) && !UserStatus.share.isLogin {
            self.present(LoginAlert(), animated: true, completion: nil)
            return
        }
        if new == .filter {
            guard let groupId = groupId else {return}
            lastGameType = old
            let newVC = GameFilterViewController.loadViewFromNib(groupId: groupId)
            self.present(newVC, animated: true, completion:nil)
            return
        }
        
        
        for btn in btns
        {
            btn.setTitleColor(Themes.grayBase, for: .normal)
            btn.tintColor = Themes.grayBase
        }
        btns[new.rawValue].setTitleColor(Themes.primaryBase, for: .normal)
        btns[new.rawValue].tintColor = Themes.primaryBase
        
        let oldOffsetY = collectionViews[old.rawValue].contentOffset.y
        let newOffsetY = collectionViews[new.rawValue].contentOffset.y
        self.collectionViews[new.rawValue].reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if oldOffsetY >= self.maxOffsetY && newOffsetY <= self.maxOffsetY {
                self.collectionViews[new.rawValue].contentOffset.y = self.maxOffsetY
            } else if oldOffsetY >= 0 && oldOffsetY <= self.maxOffsetY {
                self.collectionViews[new.rawValue].contentOffset.y = oldOffsetY
            }
        }
        scrollView.setContentOffset(CGPoint(x: Views.screenWidth * CGFloat(new.rawValue), y: 0), animated: true)
        
    }
    
    private func setupCollectionView(){
        for index in 0..<GameType.allCases.count {
            let flowLayout = UICollectionViewFlowLayout()
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
            let itemWidth = ((Views.screenWidth - 24*2 - 16)/2)
            flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth  * 0.63 + 20) // + 20 lable height
            flowLayout.minimumLineSpacing = 8
            flowLayout.minimumInteritemSpacing = 16
            flowLayout.sectionInset = UIEdgeInsets(top: gameBgViewHeight + menuHeight, left: 24, bottom: Views.bottomOffset, right: 24)
            collectionView.backgroundColor = .clear
            scrollView.addSubview(collectionView)
            collectionView.frame = CGRect(x: CGFloat(index) * Views.screenWidth, y: 0, width: Views.screenWidth, height: Views.screenHeight)
            collectionView.registerXibCell(type: GameCell.self)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.showsVerticalScrollIndicator = false
            collectionViews.append(collectionView)
        }
        scrollView.contentSize = CGSize(width: CGFloat(GameType.allCases.count) * Views.screenWidth, height: Views.screenHeight)
    }
    
    private func bindCollectionView(){
        Observable.merge(collectionViews.map { (view) -> Observable<CGFloat> in
            return view.rx.contentOffset.map({$0.y})
        }).map { (offset) -> CGFloat in
            if offset < 0 { return 0}
            if offset > self.maxOffsetY {return self.maxOffsetY}
            return offset
            }.subscribeSuccess {[weak self] (offsetY) in
                guard let weakSelf = self else { return }
                weakSelf.menuTopConstraint?.update(offset: weakSelf.gameBgViewHeight - offsetY)
                weakSelf.coverTopConstraint?.update(offset: weakSelf.gameBgViewHeight + weakSelf.menuHeight - offsetY)
                let ratio = abs(offsetY/weakSelf.maxOffsetY)
                weakSelf.pupleBgView.alpha = ratio
            }.disposed(by: disposeBag)
        
    }
    
    override func fetchGameList() {
        guard let groupId = groupId else {return}
        if UserStatus.share.isLogin {
            Observable.zip(Beans.gameServer.fetchGameList(gameType: .newest, game_group_id: groupId).asObservable(),
                           Beans.gameServer.fetchGameList(gameType: .hot, game_group_id: groupId).asObservable(),
                           Beans.gameServer.fetchGameList(gameType: .played, game_group_id: groupId).asObservable(),
                           Beans.gameServer.fetchGameList(gameType: .favorite, game_group_id: groupId).asObservable(),
                           resultSelector:{[weak self] (new, hot, played, favorite) -> Observable<Void> in
                            guard let weakSelf = self else { return Observable.just(())}
                            weakSelf.gameDtos[GameType.newest.title] = new
                            weakSelf.gameDtos[GameType.hot.title] = hot
                            weakSelf.gameDtos[GameType.played.title] = played
                            weakSelf.gameDtos[GameType.favorite.title] = favorite
                            return Observable.just(())
            }).subscribeSuccess {[weak self] (_) in
                guard let weakSelf = self else { return }
                weakSelf.collectionViews.forEach({$0.reloadData()})
                }.disposed(by: disposeBag)
        } else {
            Observable.zip(Beans.gameServer.fetchGameList(gameType: .newest, game_group_id: groupId).asObservable(),
                           Beans.gameServer.fetchGameList(gameType: .hot, game_group_id: groupId).asObservable(),
                           resultSelector:{[weak self] (new, hot) -> Observable<Void> in
                            guard let weakSelf = self else { return Observable.just(())}
                            weakSelf.gameDtos[GameType.newest.title] = new
                            weakSelf.gameDtos[GameType.hot.title] = hot
                            return Observable.just(())
            }).subscribeSuccess {[weak self] (_) in
                guard let weakSelf = self else { return }
                weakSelf.collectionViews.forEach({$0.reloadData()})
                }.disposed(by: disposeBag)
            
        }
    }
}

extension GameViewController: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout ,Gamingable{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let gameDtos = gameDtos[gameType.title] {
            return gameDtos.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: GameCell.self, indexPath: indexPath)
        
        if let dtos = gameDtos[gameType.title], dtos.count >= indexPath.row {
            let dto = dtos[indexPath.row]
            cell.configureCell(gameDto: dto)
            cell.rxLike().subscribeSuccess {[weak self] (_) in
                self?.handleLike(dto: dto)
                }.disposed(by: disposeBag)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         guard let gameDtos = gameDtos[gameType.title] ,
               let groupId = groupId,
               let groupIdInt = Int(groupId)
               else { return }
        let dto = gameDtos[indexPath.row]
        enterGame(game_group_id: groupIdInt, game_id: dto.id)
    }
    
    
}

