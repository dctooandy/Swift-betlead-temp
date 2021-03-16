//
//  LoginPageViewController.swift
//  betlead
//
//  Created by Victor on 2019/10/2.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import Parchment
import  RxSwift

class LoginPageViewController: BaseViewController {
    private var pageViewcontroller: PagingViewController<PagingIndexItem>?
    private var loginViewControllers = [LoginViewController]()
    private var signupViewControllers = [SignupViewController]()
    private let verifyCodeBtnClick = PublishSubject<String>()
    private let signupBtnClick = PublishSubject<SignupPostDto>()
    private let loginBtnClick = PublishSubject<LoginPostDto>()
    private let forgetBtnClick = PublishSubject<Void>()
    
    private var isLogin: Bool = true {
        didSet {
            cleanTextField()
            pageViewcontroller?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupMenu()
    }
    
    private func setupMenu() {
        pageViewcontroller = PagingViewController<PagingIndexItem>()
        pageViewcontroller?.delegate = self
        pageViewcontroller?.dataSource = self
        // menu item
        pageViewcontroller?.menuItemSize = PagingMenuItemSize.fixed(width: 90, height: 50)
        pageViewcontroller?.menuHorizontalAlignment = .center
        pageViewcontroller?.menuItemSpacing = 20
        pageViewcontroller?.menuBackgroundColor = .clear
        pageViewcontroller?.borderColor = .clear
        // menu text
        pageViewcontroller?.selectedFont = UIFont.systemFont(ofSize: 20)
        pageViewcontroller?.font = UIFont.systemFont(ofSize: 20)
        pageViewcontroller?.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
        pageViewcontroller?.selectedTextColor = .white
        // menu indicator
        pageViewcontroller?.indicatorColor = Themes.secondaryOrange
        pageViewcontroller?.indicatorClass = RoundedIndicatorView.self
        pageViewcontroller?.indicatorOptions = .visible(height: 4,
                                                        zIndex: Int.max,
                                                        spacing: UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30),
                                                        insets: .zero)
        addChild(pageViewcontroller!)
        view.addSubview(pageViewcontroller!.view)
        pageViewcontroller?.view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    private func setupVC() {
            let accLogin = LoginViewController.instance(mode: .account)
            let phoneLogin = LoginViewController.instance(mode: .phone)
            let accSignup = SignupViewController.instance(mode: .account)
            let phoneSignup = SignupViewController.instance(mode: .phone)
            loginViewControllers = [accLogin, phoneLogin]
            bindVerifyCodeBtn(obs: phoneLogin.rxVerifyCodeButtonClick)
            signupViewControllers = [accSignup, phoneSignup]
            bindVerifyCodeBtn(obs: phoneSignup.rxVerifyCodeButtonClick)
            bindLoginViewControllers()
            bindSingupViewControllers()
    }
    private func cleanTextField() {
        loginViewControllers.forEach({$0.cleanTextField()})
        signupViewControllers.forEach({$0.cleanTextField()})
    }
    
    func reloadPageMenu(isLogin: Bool) {
        self.isLogin = isLogin
        DispatchQueue.main.async {[weak self] in
            self?.pageViewcontroller?.reloadData()
        }
    }
    
    func startReciprocal() {
        if isLogin {
            loginViewControllers[1].startReciprocal()
        } else {
            signupViewControllers[1].startReciprocal()
        }
    }
    
    func setVerifyCode(code: String) {
        if isLogin {
            loginViewControllers[1].showVerifyCode(code)
        } else {
            signupViewControllers[1].showVerifyCode(code)
        }
    }
    
    func setVerifyCodeBtnToDefault() {
        loginViewControllers.last?.setDefault()
        signupViewControllers.last?.setDefault()
    }
    
    func setAccount(acc: String, pwd: String) {
        loginViewControllers[0].setAccount(acc: acc, pwd: pwd)
    }
    
    private func bindLoginViewControllers() {
        for i in loginViewControllers {
            i.rxLoginButtonPressed()
                .subscribeSuccess { [weak self] dto in
                    self?.loginBtnClick.onNext(dto)
                }.disposed(by: disposeBag)
            
            i.rxForgetPassword()
                .subscribeSuccess { [weak self] in
                    self?.forgetBtnClick.onNext(())
                }.disposed(by: disposeBag)
        }
    }
    
    private func bindSingupViewControllers() {
        for i in signupViewControllers {
            i.rxSignupButtonPressed()
                .subscribeSuccess { [weak self] dto in
                    self?.signupBtnClick.onNext(dto)
                }.disposed(by: disposeBag)
        }
    }
    
    private func bindVerifyCodeBtn(obs: Observable<String>?) {
        obs?.subscribeSuccess({ [weak self] (phone) in
            self?.verifyCodeBtnClick.onNext(phone)
        }).disposed(by: disposeBag)
    }
    
    
    func rxLoginBtnClick() -> Observable<LoginPostDto> {
        return loginBtnClick.asObserver()
    }
    
    func rxSignupBtnClick() -> Observable<SignupPostDto> {
        return signupBtnClick.asObserver()
    }
    
    func rxForgetBtnClick() -> Observable<Void> {
        return forgetBtnClick.asObserver()
    }
    
    func rxVerifyCodeBtnClick() -> Observable<String> {
        return verifyCodeBtnClick.asObserver()
    }
    
    
}

// MARK: - Page menu delegate datasource
extension LoginPageViewController: PagingViewControllerDataSource, PagingViewControllerDelegate {
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T where T : PagingItem, T : Comparable, T : Hashable {
        if isLogin {
            return PagingIndexItem(index: index, title: loginViewControllers[index].modeTitle()) as! T
        }
        return PagingIndexItem(index: index, title: signupViewControllers[index].modeTitle()) as! T
    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController where T : PagingItem, T : Comparable, T : Hashable {
        return isLogin ? loginViewControllers[index] : signupViewControllers[index]
    }
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int where T : PagingItem, T : Comparable, T : Hashable {
        return 2
    }
}

//MARK: - apply menu indicator ui
class RoundedIndicatorView: PagingIndicatorView {
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layer.cornerRadius = layoutAttributes.frame.height / 2
    }
}
