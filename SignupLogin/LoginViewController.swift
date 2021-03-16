//
//  LoginViewController.swift
//  betlead
//
//  Created by Victor on 2019/5/28.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift




class LoginViewController: BaseViewController {

    @IBOutlet weak private var forgetPasswordButton: UIButton!
    @IBOutlet weak var loginButton: CornerradiusButton!
    private var accountInputView: AccountInputView?
    private var checkboxView: CheckBoxView!
    private var timer: Timer?
    private var seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
    private var onClickLogin = PublishSubject<LoginPostDto>()
    var rxVerifyCodeButtonClick: Observable<String>?
    private var loginMode : LoginMode = .account {
        didSet {
            self.loginModeDidChange()
        }
    }
    // MARK: instance
    static func instance(mode: LoginMode) -> LoginViewController {
        let vc = LoginViewController.loadNib()
        vc.loginMode = mode
        return vc
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindLoginBtn()
        bindAccountView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - UI
    
    func setDefault() {
        stopTimer()
        accountInputView?.passwordRightButton.setTitle("发送验证码", for: .normal)
    }
    
    func cleanTextField() {
        self.accountInputView?.cleanTextField()
    }
    
    func setAccount(acc: String, pwd: String) {
        DispatchQueue.main.async { [weak self] in
            self?.accountInputView?.accountTextField.text = acc
            self?.accountInputView?.passwordTextField.text = pwd
            self?.accountInputView?.passwordTextField.sendActions(for: .valueChanged)
        }
    }
    func modeTitle() -> String {
        switch  loginMode {
        case .account: return "帐号登录"
        case .phone: return "手机登录"
        }
    }
    
    func setup() {
        
        accountInputView = AccountInputView(inputMode: loginMode, isLogin: true, lineColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        self.rxVerifyCodeButtonClick = accountInputView?.rxVerifyCodeButtonClick()
        view.addSubview(accountInputView!)
        accountInputView?.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(56)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.872)
            //make.height.equalToSuperview().multipliedBy(0.275)
        }
        
//        checkboxView = CheckBoxView(title: "保持登录",
//                                    titleColor: .white,
//                                    checkBoxSize: 18,
//                                    checkBoxColor: Themes.primaryBase)
//
//        view.addSubview(checkboxView)
//        checkboxView.snp.makeConstraints { make in
//            make.leading.equalTo(accountInputView!)
//            make.top.equalTo(accountInputView!.snp.bottom).offset(30)
//            make.height.equalTo(18)
//        }
//
        forgetPasswordButton.titleLabel?.font = Fonts.pingFangTCRegular(16)
        forgetPasswordButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(accountInputView!)
            make.top.equalTo(accountInputView!.snp.bottom).offset(20)
            make.height.equalTo(18)
        }
        loginButton.titleLabel?.font = Fonts.pingFangTCRegular(16)
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.forgetPasswordButton.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.872)
            make.height.equalTo(view).multipliedBy(0.08)
        }
        // set default login mode
        loginModeDidChange()
    }
    
    func showVerifyCode(_ code: String) {
        self.accountInputView?.passwordTextField.text = code
        self.accountInputView?.passwordTextField.sendActions(for: .valueChanged)
    }
    
    //MARK: Actions
    func bindAccountView() {
        accountInputView!.rxCheckPassed()
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func bindLoginBtn() {
        loginButton.rx.tap.subscribeSuccess { [weak self] _ in
                self?.login()
            }.disposed(by: disposeBag)
    }
    
    private func login() {
        
        guard let account = accountInputView?.accountTextField.text?.lowercased() else {return}
        guard let password = accountInputView?.passwordTextField.text else {return}
        let dto = LoginPostDto(account: account, password: password,loginMode: self.loginMode)
        self.onClickLogin.onNext(dto)
        
    }
    
    func startReciprocal() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setPwdRightBtnSecondTime), userInfo: nil, repeats: true)
        self.accountInputView?.setPasswordRightBtnEnable(isEnable: false)
    }
    
    @objc private func setPwdRightBtnSecondTime() {
        
        self.accountInputView?.setPasswordRightBtnTime(seconds)
        if seconds == 0 {
            stopTimer()
            return
        }
        seconds -= 1
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
        seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
        self.accountInputView?.setPasswordRightBtnEnable(isEnable: true)
    }
    
    func rxForgetPassword() -> ControlEvent<Void> {
        return forgetPasswordButton.rx.tap
    }
    
    func rxLoginButtonPressed() -> Observable<LoginPostDto> {
        return onClickLogin.asObserver()
    }

    
    private func loginModeDidChange() {
        forgetPasswordButton.isHidden = loginMode == .phone
        accountInputView?.changeInputMode(mode: loginMode)
    }
}


