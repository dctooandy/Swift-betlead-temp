//
//  MemberProfileDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/7/4.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import RxSwift
class MemberProfileDto:Codable {
    
    static var share:MemberProfileDto?
    {
        didSet {
            guard let share = share else { return }
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<MemberProfileDto?> = subject
        .do(onNext: { value in
            if share == nil {
                update()
            }
        })
    static let disposeBag = DisposeBag()
    static private let subject = BehaviorSubject<MemberProfileDto?>(value: nil)
    static func update(){
        Beans.memberServer.getMemberProfile().subscribeSuccess({ (memberProfileDto) in
            share = memberProfileDto
        }).disposed(by: disposeBag)
    }
    let memberId:Int
    let memberAccount:String
    let memberInboxCnt:Int
    let memberLastLogin:String
    let memberPofilePicture:Int
    let memberVerifybar:Int
    let memberEmailCert:Int
    let memberPhoneCert:Int
    let memberBankCard:Int
    let memberRealName:Int
    
    var isMailVerify:Bool {
        return memberEmailCert == 1
    }
    var mailIcon:UIImage? {
        return isMailVerify ? UIImage(named: "vertify-envelope-active") : UIImage(named: "vertify-envelope")
    }
    
    var isPhoneVerify:Bool {
        return memberPhoneCert == 1
    }
    var phoneIcon:UIImage? {
        return isPhoneVerify ? UIImage(named: "vertify-mobile-active") : UIImage(named: "vertify-mobile")
    }
    
    var isBankVerify:Bool {
        return memberBankCard == 1
    }
    var bankIcon:UIImage? {
        return isBankVerify ? UIImage(named: "vertify-credit-card-active") : UIImage(named: "vertify-credit-card")
    }
    
    var isRealNameVerify:Bool {
        return memberRealName == 1
    }
    var realNameIcon:UIImage? {
        return isRealNameVerify ? UIImage(named: "vertify-lock-active") : UIImage(named: "vertify-lock")
    }
    var avatar:UIImage? {
        return UIImage(named: "avatar\(memberPofilePicture)")
    }
    
}
