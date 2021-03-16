//
//  AccountDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/18.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import RxSwift
class AccountVerifyDto:Codable {
    static var share:AccountVerifyDto?
    {
        didSet {
            guard let share = share else { return }
            MemberProfileDto.update()
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<AccountVerifyDto?> = subject
        .do(onNext: { value in
            if share == nil {
                _ = update()
            }
        })
    static let disposeBag = DisposeBag()
    static private let subject = BehaviorSubject<AccountVerifyDto?>(value: nil)
    static func update() -> Observable<Void>{
        let completed = PublishSubject<Void>()
        Beans.memberServer.accountDetail().subscribeSuccess({ (accountVerifyDto) in
            share = accountVerifyDto
            completed.onNext(())
        }).disposed(by: disposeBag)
        return completed.asObservable()
    }

    let account:String
    let email:String?
    let phone:String?
    let accountChanged:Bool
    
    var phoneShownText:String {
        return  phone ?? "未綁定"
    }
    var mailShownText:String {
        return  email ?? "未綁定"
    }
    
    init(account:String, email:String?, phone:String?, accountChanged:Bool) {
        self.account = account
        self.email = email
        self.phone = phone
        self.accountChanged = accountChanged
    }
}
