//
//  SignupViewController.swift
//  betlead
//
//  Created by Victor on 2019/5/28.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import RxSwift

class SignupViewController: BaseViewController {
    @IBOutlet weak var registerButton: CornerradiusButton!
    @IBOutlet weak var bottomMessageLabel: UILabel!
    private var accountInputView: AccountInputView?
    private var timer: Timer? = nil
    private var seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
    var rxVerifyCodeButtonClick: Observable<String>?
    private var onClick = PublishSubject<SignupPostDto>()
    
    private var loginMode : LoginMode = .account {
        didSet {
            loginModeDidChange()
        }
    }
    static func instance(mode: LoginMode) -> SignupViewController {
        let vc = SignupViewController.loadNib()
        vc.loginMode = mode
        return vc
    }
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindRegisterBtn()
        bindAccountView()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - UI
    func setDefault() {
        stopTimer()
        accountInputView?.passwordRightButton.setTitle("发送验证码", for: .normal)
    }
    
    func cleanTextField() {
        accountInputView?.cleanTextField()
    }
    
    private func setupUI() {
        
        accountInputView = AccountInputView(inputMode: loginMode, isLogin: false, lineColor: Themes.grayLight)
        rxVerifyCodeButtonClick = accountInputView?.rxVerifyCodeButtonClick()
        view.addSubview(accountInputView!)
        accountInputView?.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(88)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.872)
            make.height.equalToSuperview().multipliedBy(0.275)
        }
        
        registerButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.accountInputView!.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.872)
            make.height.equalTo(view).multipliedBy(0.08)
            
        }
        
        bottomMessageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(registerButton.snp.bottom).offset(24)
            make.centerX.equalTo(registerButton)
        }
        
    }
    
    func modeTitle() -> String {
        switch  loginMode {
        case .account: return "帐号注册"
        case .phone: return "手机注册"
        }
    }
    
    func showVerifyCode(_ code: String) {
        self.accountInputView?.passwordTextField.text = code
        self.accountInputView?.passwordTextField.sendActions(for: .valueChanged)
    }
    // MARK: - Actions
    func bindAccountView() {
        accountInputView!
            .rxCheckPassed()
            .bind(to:registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func bindRegisterBtn() {
        registerButton.rx.tap.subscribeSuccess { [weak self] in
            self?.signup()
        }.disposed(by: disposeBag)
    }
    
    func signup() {
        guard let acc = accountInputView?.accountTextField.text?.lowercased() else { return }
        guard let pwd = accountInputView?.passwordTextField.text else { return }
        let dto = SignupPostDto(account: acc, password: pwd, signupMode: loginMode)
        self.view.endEditing(true)
        onClick.onNext(dto)
    }
    
    func rxSignupButtonPressed() -> Observable<SignupPostDto> {
        return onClick.asObserver()
    }
  
    private func loginModeDidChange() {
        accountInputView?.changeInputMode(mode: self.loginMode)
    }
    
    func startReciprocal() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setPwdRightBtnSecondTime), userInfo: nil, repeats: true)
        self.accountInputView?.setPasswordRightBtnEnable(isEnable: false)
        timer?.fire()
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
}


