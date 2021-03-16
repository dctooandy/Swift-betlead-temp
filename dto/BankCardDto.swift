//
//  BankCardDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/13.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import RxSwift
class BankCardDto:Codable {
    static var share:[BankCardDto]?
    {
        didSet {
            guard let bankCardDtos = share else { return }
            share = bankCardDtos.sorted(by: { (previousDto, nextDto) -> Bool in
                    previousDto.isDefault
            })
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<[BankCardDto]?> = subject
        .do(onNext: { value in
            if share == nil {
                _ = update()
            }
        })
    static let disposeBag = DisposeBag()
    static private let subject = BehaviorSubject<[BankCardDto]?>(value: nil)
    static func update() -> Observable<Void>{
        let subject = PublishSubject<Void>()
        Beans.memberServer.getBankCard().subscribe(onSuccess:{ (bankCardDtos) in
            share = bankCardDtos
            _ = AccountVerifyDto.update()
            subject.onNext(())
        }).disposed(by: disposeBag)
     return subject.asObservable()
    }
    
    let id:Int
    let memberId:Int
    let memberAccount:String
    let memberBankAccount:String
    let memberBankCode:String
    let memberBankNo:String
    let memberProvince:String
    let memberCity:String
    let memberBranch:String
    let memberFullAddress:String
    let memberDefaultCard:ValueIntDto
    let memberStatus:ValueOptionIntDto
    let memberCreatedAt:String
    let memberUpdatedAt:String
    
    var bankName :String {
        return Beans.banks.filter({$0.bankCode == memberBankCode}).first?.bankName ?? ""
    }
    
    var isEnable :Bool {
        return (memberStatus.value ?? 0) == 1
    }
    static var shownBankText:String {
        guard let dtos = share ,
        dtos.count != 0 ,
            let defaultBank = dtos.filter({$0.memberDefaultCard.value == 1 }).first  else { return "未綁定"}
            return "\(defaultBank.bankName) \(defaultBank.memberBankNo.toBankNo())"
    }
    
    var isDefault:Bool {
        return memberDefaultCard.value == 1
    }
    
}


class TBankCardDto:Codable {
   
    let id:Int
    let memberId:Int
    let memberAccount:String
    let memberBankAccount:String
    let memberBankCode:String
    let memberBankNo:String
    let memberProvince:String
    let memberCity:String
    let memberBranch:String
    let memberFullAddress:String
    let memberDefaultCard:ValueOptionStringDto
    let memberStatus:ValueOptionIntDto
    let memberCreatedAt:String
    let memberUpdatedAt:String
    
}
