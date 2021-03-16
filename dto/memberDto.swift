//
//  memberDto.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/13.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import RxSwift

class MemberDto:Codable {
    static var share:MemberDto?
    {
        didSet {
            guard let share = share else { return }
            
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<MemberDto?> = subject
        .do(onNext: { value in
            if share == nil {
               _ = update()
            }
        })
    static let disposeBag = DisposeBag()
    static private let subject = BehaviorSubject<MemberDto?>(value: nil)
    static func update() -> Observable<()>{
        let subject = PublishSubject<Void>()
        Beans.memberServer.getPersonalInfo().subscribeSuccess({ (memberDto) in
            share = memberDto
            _ = AccountVerifyDto.update()
            subject.onNext(())
        }).disposed(by: disposeBag)
        return subject.asObservable()
    }
   
    let id:Int
    let memberId:Int
    let memberAccount:String
    let memberRealname:String?
    let memberBirthday:String?
    let memberGender:ValueIntDto
    let memberProvince:Int?
    let memberCity:Int?
    let memberState:Int?
    let memberAddress:String?
    let memberFullAddress:String
    let memberCreatedAt:String
    let memberUpdatedAt:String
    let memberPofilePicture:Int
    
    var lockIcon:UIImage? {
        return (memberRealname == nil) ? UIImage(named: "vertify-lock") : UIImage(named: "vertify-lock-active")
    }
    
}
