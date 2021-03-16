//
//  DivisionPromotionViewController.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/20.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit

class DivisionPromotionViewController:RefreshViewController {
    
    private var promotionDtos = [PromotionDto]()
    
    private lazy var promotionTableView:UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = nil
        tableView.registerXibCell(type: PromotionTableViewCell.self)
        tableView.separatorStyle = .none
        self.tableView = tableView
        return tableView
    }()
    
    private let promotionType:PromotionType
    
    init(promotionType:PromotionType) {
        self.promotionType = promotionType
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
        fetchPromotion()
    }
    override func refreshing() {
        fetchPromotion()
    }
    
    func fetchPromotion(){
        Beans.promotionServer.getAllPromotion(promotion_group_id: promotionType.rawValue)
            .do(onSuccess:{ _ in
                self.refreshControl.endRefreshing() } , onError:  { _ in
                    self.refreshControl.endRefreshing()})
            .subscribe(onSuccess: { [weak self] (promotionDtos) in
                _ = LoadingViewController.dismiss()
                guard let weakSelf = self else { return }
                weakSelf.promotionDtos = promotionDtos
                weakSelf.promotionTableView.reloadData()
            }) { (error) in
                _ = LoadingViewController.dismiss()
                ErrorHandler.show(error: error)
            }.disposed(by: disposeBag)
    }
    
    private func setupViews(){
        view.addSubview(promotionTableView)
        promotionTableView.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-Views.betleadTabbarHeight)
        }
    }
    
}

extension DivisionPromotionViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return promotionDtos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: PromotionTableViewCell.self, indexPath: indexPath)
        let dto = promotionDtos[indexPath.row]
        cell.configureCell(promotionDto: dto)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 206
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let promotionContentSheet = PromotionContentBottomSheet()
        let dto = promotionDtos[indexPath.row]
        promotionContentSheet.configure(promotionDto: dto)
        promotionContentSheet.start(viewController: self).subscribeSuccess { (value) in
            if let action = value as? PromotionContentBottomSheet.Action {
                switch action {
                case .fetchAndReload:
                     self.fetchPromotion()
                case .pushMyPomotionCycleVC(let id):
                    let newVC = MyPromotionCycleViewController(promotionId: id)
                    newVC.setTitle(title: dto.promotionTitle, subtitle: dto.promotionSubTitle ?? "")
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            }
        }.disposed(by: disposeBag)
    }
}
