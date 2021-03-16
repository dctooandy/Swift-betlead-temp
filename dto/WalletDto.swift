//
//  WalletDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/18.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import RxSwift
class WalletDto:Codable {
    static var share:WalletDto?
    {
        didSet {
            guard let share = share else { return }
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<WalletDto?> = subject
            .do(onNext: { value in
            if share == nil {
                update()
            }
        })
    static let disposeBag = DisposeBag()
    static private let subject = BehaviorSubject<WalletDto?>(value: nil)
    static func update(){
        Beans.memberServer.getWallet().subscribeSuccess({ (walletDto) in
            share = walletDto
        }).disposed(by: disposeBag)
    }
    let cash:Double
    let gameCash:Double
    let lockCash:Double
    
    var amount:String {
//        return String(cash + gameCash + lockCash).numberFormatter(.currency, 2)
        return String(cash + gameCash).numberFormatter(.currency, 2)
    }
    var center:String {
      return  "\(cash)".numberFormatter(.currency, 2)
    }
    var game:String {
        return  "\(gameCash)".numberFormatter(.currency, 2)
    }
    
}
