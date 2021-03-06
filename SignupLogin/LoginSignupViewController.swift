//
//  LoginSignupViewController.swift
//  betlead
//
//  Created by Victor on 2019/5/29.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import Parchment
import RxSwift
import Toaster
import AVFoundation
import AVKit
class LoginSignupViewController: BaseViewController {
    fileprivate let loginPageVC = LoginPageViewController()
    static let share: LoginSignupViewController = LoginSignupViewController.loadNib()
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImv: UIImageView!
    private var successView: SignupSuccessView?
    private let tabbarVC = BetLeadTabbarViewController()
    /// 显示注册或登入页面
    private var isLogin: Bool = true {
        didSet {
            resetUI()
            loginPageVC.reloadPageMenu(isLogin: isLogin)
        }
    }
    private var shouldVerify = false
    private var route: SuccessViewAction.Route? = nil
    private var backGroundVideoUrl: URL? = nil
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginPageVC()
        bindLoginPageVC()
        updateBottomView()
        setupUI()
        binding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bioVerifyCheck()
        VideoManager.share.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VideoManager.share.pause()
    }
    
    private func bioVerifyCheck() {
        if !isLogin { return }
        if !BioVerifyManager.share.bioLoginSwitchState() { return }
        if let loginPostDto = KeychainManager.share.getLastAccount(),
            BioVerifyManager.share.usedBIOVeritfy(loginPostDto.account) {
            // 進行臉部或指紋驗證
            BioVerifyManager.share.bioVerify { [weak self] (success, error) in
                if !success {
                    Toast.show(msg: "验证失败，请输入帐号密码")
                    return
                }
                if error != nil {
                    Toast.show(msg: "验证失败：\(error!.localizedDescription)")
                    return
                }
                self?.login(dto: loginPostDto)
                self?.loginPageVC.setAccount(acc: loginPostDto.account, pwd: loginPostDto.password)
            }
        } else {
            print("manual login.")
        }
    }
 
    func isLogin(_ isLogin: Bool) -> LoginSignupViewController {
        self.isLogin = isLogin
        return self
    }
    
    // MARK: - Actions
    func setMemberViewControllerDefault() {
        tabbarVC.memberVC.setDefault()
    }
    
    private func binding() {
        dismissButton.rx.tap
            .subscribeSuccess { [weak self] in
                KeychainManager.share.clearToken()
                DeepLinkManager.share.navigation = .none
                self?.goMainViewController()   
            }.disposed(by: disposeBag)
        
        bottomButton.rx.tap
            .subscribeSuccess { [weak self] in
                DispatchQueue.main.async {
                    self?.changeLoginState()
                }
            }.disposed(by: disposeBag)
    }
    func bindLoginPageVC() {
        loginPageVC.rxLoginBtnClick().subscribeSuccess { [weak self] (dto) in
            guard let strongSelf = self else { return }
            strongSelf.view.endEditing(true)
            if strongSelf.shouldVerify {
                strongSelf.showImageVerifyView(dto)
                return
            }
            strongSelf.login(dto: dto)
        }.disposed(by: disposeBag)
        
        loginPageVC.rxSignupBtnClick().subscribeSuccess { [weak self] (dto) in
            guard let strongSelf = self else { return }
            strongSelf.view.endEditing(true)
            if strongSelf.shouldVerify {
                strongSelf.showImageVerifyView(dto)
                return
            }
            strongSelf.signup(dto: dto)
        }.disposed(by: disposeBag)
        loginPageVC.rxVerifyCodeBtnClick().subscribeSuccess { [weak self] (phone) in
            self?.view.endEditing(true)
            self?.sendVerifyCode(phone)
        }.disposed(by: disposeBag)
        loginPageVC.rxForgetBtnClick().subscribeSuccess { [weak self] in
            self?.view.endEditing(true)
            self?.showForgetPasswordVC()
        }.disposed(by: disposeBag)
    }
    // MARK: 驗證碼
    private func sendVerifyCode(_ phone: String) {
        
        Beans.memberServer
            .sendVerifyCode(phone, isLogin: isLogin)
            .subscribeSuccess({ [weak self] (res) in
                guard let strongSelf = self else { return }
                if res.1 != 1 { return }
                print("otp: \(res.0.otp ?? "no otp")")
                DispatchQueue.main.async {
                    strongSelf.loginPageVC.startReciprocal()
                }
                #if DEBUG // 測試時直接把otp貼在textfield上
                DispatchQueue.main.async {
                    strongSelf.loginPageVC.setVerifyCode(code: res.0.otp ?? "")
                }
                #endif
            }).disposed(by: disposeBag)
    }
    
    // MARK: 登入
   
    private func showForgetPasswordVC() {
        self.present(ForgetPasswordViewController(), animated: true, completion: nil)
    }
    
    // Confirm Touch/Face ID
    private func showBioConfirmView() {
        let popVC =  ConfirmPopupView(title: "登入确认",
                                      message: "启用脸部辨识或指纹辨识进行登入？") { [weak self] isOK in
                                        if isOK {
                                            guard let acc = MemberAccount.share?.account else { return }
                                            BioVerifyManager.share.applyMemberInBIOList(acc)
                                        }
                                        BioVerifyManager.share.setBioLoginSwitch(to: isOK)
                                        self?.navigateToRouter(showBioView: false)
        }
        DispatchQueue.main.async {[weak self] in
            self?.present(popVC, animated: true, completion: nil)
        }
    }
    
    func login(dto: LoginPostDto, checkBioList: Bool = true , route: SuccessViewAction.Route = .main, showLoadingView: Bool = true) {
        LoadingViewController.show()
        Beans.memberServer
            .login(dto: dto)
            .subscribe(onSuccess: { [weak self] (res) in
                guard let strongSelf = self else { return }
                //_ = MemberDto.update()
                strongSelf.removeSuccessView()
                strongSelf.shouldVerify = false
                strongSelf.postPushDevice()
                MemberAccount.share = MemberAccount(account: dto.account,
                                                    password: dto.password,
                                                    loginMode: dto.loginMode)
                KeychainManager.share.setLastAccount(dto.account)
                if dto.loginMode == .account {
                    BioVerifyManager.share.applyMemberInBIOList(dto.account)
                    KeychainManager.share.updateAccount(acc: dto.account,
                                                        pwd: dto.password)
                }
                let didAskBioLogin = BioVerifyManager.share.didAskBioLogin()
                let showBioView = (dto.loginMode == .account) && checkBioList && !didAskBioLogin
                strongSelf.setLoginPageToDefault()
                strongSelf.handleLoginSuccess(showLoadingView: showLoadingView,
                                              showBioView: showBioView,
                                              route: route)
                }, onError: { [weak self] (error) in
                    self?.handleApiServiceError(error)
            }).disposed(by: disposeBag)
    }
    
    func postPushDevice() {
        guard let regID = JPushManager.share.registerID, let apnsToken = JPushManager.deviceToken else { return }
        Beans.baseServer.jpsuh(apnsToken: apnsToken, jpushID: regID).subscribeSuccess().disposed(by: disposeBag)
    }
    
    func handleLoginSuccess(showLoadingView: Bool, showBioView: Bool, route: SuccessViewAction.Route = .main) {
        WalletDto.update()
        if showLoadingView {
            LoadingViewController.action(mode: .success, title: "登入成功")
                .subscribeSuccess({ [weak self] in
                self?.navigateToRouter(showBioView: showBioView,
                                            route: route)
            }).disposed(by: disposeBag)
            return
        }
        _ = LoadingViewController.dismiss()
        navigateToRouter(showBioView: showBioView,
                              route: route)
    }
    
    func navigateToRouter(showBioView: Bool, route: SuccessViewAction.Route = .main) {
        if showBioView {  // 第一次登入，詢問是否要用臉部或指紋驗證登入
            showBioConfirmView()
            BioVerifyManager.share.applyLogedinAccount(MemberAccount.share!.account)
            BioVerifyManager.share.setBioLoginAskStateToTrue()
        } else {
            if DeepLinkManager.share.navigation != .none {
                goMainViewController()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    DeepLinkManager.share.navigation.toTargetVC()
                    DeepLinkManager.share.navigation = .none
                }
                return
            }
            
            switch route {
            case .main: goMainViewController()
            case .personal: goPersonalViewController()
            case .bet: goBetViewController()
            case .clickAD(let url): goADPopupView(urlStr: url)
            case .member : goMember()
            }
        }
    }
    
    func setLoginPageToDefault() {
        DispatchQueue.main.async {[weak self] in
            self?.loginPageVC.setVerifyCodeBtnToDefault()
        }
    }
    
    // MARK: 註冊
    func signup(dto: SignupPostDto) {
        LoadingViewController.show()
        Beans.memberServer
            .signup(dto: dto)
            .subscribe(onSuccess: { [weak self] (res) in
                self?.signupSuccess(dto: dto, res: res)
            }, onError: { [weak self] (error) in
                self?.handleApiServiceError(error)
            }).disposed(by: disposeBag)
    }
    
    func signupSuccess(dto: SignupPostDto, res: (SignupDto?, Int)) {
        LoadingViewController.action(mode: .success, title: "注册成功")
            .subscribeSuccess({ [weak self]_ in
                self?.shouldVerify = false
                DispatchQueue.main.async {
                    if dto.signupMode == .phone {
                        guard let acc = res.0?.account, let pwd = res.0?.password else { return }
                        KeychainManager.share.saveAccPwd(acc: acc,
                                                         pwd: pwd,
                                                         tel: dto.account)
                        
                        self?.showSignupSuccessView(acc: acc,
                                                    pwd: pwd,
                                                    mode: dto.signupMode)
                        return
                    }
                    KeychainManager.share.saveAccPwd(acc: dto.account,
                                                     pwd: dto.password,
                                                     tel: "")
                    self?.showSignupSuccessView(acc: dto.account,
                                                pwd: dto.password,
                                                mode: dto.signupMode)
                }
            }).disposed(by: disposeBag)
    }
    
    func handleApiServiceError(_ error: Error) {
        guard let err = error as? ApiServiceError else { return }
        ErrorHandler.show(error: err)
        if err == .failThrice {
            shouldVerify = true
        }
    }
    // MARK: Login Video
    func fetchBackgroundVideo() {
        print("fetch bg video")
        if backGroundVideoUrl != nil {
            DispatchQueue.main.async { [weak self] in
                self?.setupLoginVideo()
            }
            return
        }
        
        let lastUpdateDate = UserDefaults.Verification.string(forKey: .loginVideoUpdateDate)
        Beans.bannerServer.loginVideo().subscribe(onSuccess: { [weak self] (dto) in
            guard let urlString = dto?.bannerVideoMobile, !urlString.isEmpty, let updaateDate = dto?.bannerUpdatedAt else {
                    self?.fetchLoginVideofromLocal()
                    self?.setupLoginVideo()
                    return
            }
            self?.backGroundVideoUrl = URL(string: urlString)
            if !updaateDate.isEmpty && updaateDate == lastUpdateDate {
                print("get login video from local url")
                self?.fetchLoginVideofromLocal()
            } else {
                print("get login video from api url")
                self?.backGroundVideoUrl = URL(string: urlString)
                Beans.bannerServer.fetchLoginVideoData(urlString: urlString, updateDate: updaateDate)
            }
            self?.setupLoginVideo()
        }, onError: { [weak self] (error) in
            print("fetch login video error")
            self?.fetchLoginVideofromLocal()
            self?.setupLoginVideo()
        }).disposed(by: disposeBag)
    }
    private func fetchLoginVideofromLocal() {
        let baseUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storeUrl = baseUrl.appendingPathComponent("loginVideo.mp4")
        if FileManager.default.fileExists(atPath: storeUrl.path) {
            backGroundVideoUrl = storeUrl
        } else {
            backGroundVideoUrl = URL(string: BuildConfig.LOGIN_VIDEO_URL)
        }
    }
    
    // MARK: - ViewController navigation
    func changeLoginState() {// 登入註冊頁面
        isLogin = !isLogin
    }
    
    func goMainViewController() {
        tabbarVC.selected(0)
        tabbarVC.mainPageVC.shouldFetchGameType = true
        let betleadMain = BetleadNavigationController(rootViewController: tabbarVC)
        DispatchQueue.main.async {
            if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
                print("go main")
                mainWindow.rootViewController = betleadMain
                mainWindow.makeKeyAndVisible()
            }
        }
    }
    
    func goPersonalViewController() {
        tabbarVC.mainPageVC.shouldFetchGameType = true
        let betleadMain = BetleadNavigationController(rootViewController:tabbarVC)
        if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
            print("go personal")
            mainWindow.rootViewController = betleadMain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tabbarVC.selected(3)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                   UIApplication.topViewController()?.navigationController?.pushViewController(SecurityViewController.loadNib(), animated: true)
                })
            }
        }
    }
    
    func goBetViewController() {
        tabbarVC.mainPageVC.shouldFetchGameType = true
        let betleadMain = BetleadNavigationController(rootViewController:tabbarVC)
        if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
            print("go bet")
            mainWindow.rootViewController = betleadMain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tabbarVC.selected(3)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    UIApplication.topViewController()?.navigationController?.pushViewController(BetRecordViewController(), animated: true)
                })
            }
        }
    }
    
    func goMember() {
        tabbarVC.mainPageVC.shouldFetchGameType = true
        let betleadMain = BetleadNavigationController(rootViewController:tabbarVC)
        if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
            print("go Member")
            mainWindow.rootViewController = betleadMain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tabbarVC.selected(3)

            }
        }
    }
    
    func goADPopupView(urlStr: String) {
        let betleadMain = BetleadNavigationController(rootViewController:tabbarVC)
        if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
            mainWindow.rootViewController = betleadMain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tabbarVC.selected(0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    let webViewBottomSheep = WebViewBottomSheet()
                    webViewBottomSheep.urlString = urlStr
                    webViewBottomSheep.start(viewController: betleadMain)
                })
            }
        }
    }
    
    //MARK: - 註冊成功頁面
    func showSignupSuccessView(acc: String, pwd: String, mode: LoginMode) {
        shouldVerify = false
        successView = SignupSuccessView.loadNib()
        successView?.account = acc
        successView?.password = pwd
        successView?.setup(title: mode.signupSuccessTitles().title,
                          buttonTitle: mode.signupSuccessTitles().doneButtonTitle,
                          showAccount: mode.signupSuccessTitles().showAccount)
        view.addSubview(successView!)
        successView?.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        bindSignupSuccessView()
    }
    
    func bindSignupSuccessView() {
        successView?.rxSuccessViewDidPressed()
            .subscribeSuccess { [weak self] (type) in
                switch type {
                case .toMainView(let acc, let pwd):
                    
                    let dto = LoginPostDto(account: acc,
                                           password: pwd,
                                           loginMode: .account)
                    self?.login(dto: dto, checkBioList: false, showLoadingView: false)
                case .toPersonal(let acc, let pwd):
                    
                    let dto = LoginPostDto(account: acc,
                                           password: pwd,
                                           loginMode: .account)
                    self?.login(dto: dto, checkBioList: false , route: type.route, showLoadingView: false)
                case .toBet(let acc, let pwd):
                    let dto = LoginPostDto(account: acc,
                                           password: pwd,
                                           loginMode: .account)
                    self?.login(dto: dto, checkBioList: false , route: type.route, showLoadingView: false)
                case .clickAD(let acc, let pwd, _):
                    let dto = LoginPostDto(account: acc,
                                           password: pwd,
                                           loginMode: .account)
                    self?.login(dto: dto, checkBioList: false , route: type.route, showLoadingView: false)
                default: break
                }
            }.disposed(by: disposeBag)
    }
    
    func removeSuccessView() {
        successView?.removeFromSuperview()
        successView = nil
    }
    
    //MARK: - 顯示滑塊驗證
    private func showImageVerifyView(_ postDto: Any) {
        let imageVerifyView = ImageVerifyView()
        self.view.addSubview(imageVerifyView)
        imageVerifyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        imageVerifyView
            .rxVerifySuccess()
            .subscribeSuccess { [weak self] (success) in
                if let dto = postDto as? SignupPostDto {
                    self?.signup(dto: dto)
                } else if let dto = postDto as? LoginPostDto {
                    self?.login(dto: dto, checkBioList: dto.loginMode == .account)
                }
                imageVerifyView.removeFromSuperview()
            }.disposed(by: disposeBag)
        
    }
}

// MARK: - UI setup
extension LoginSignupViewController {
    
    private func setupUI() {
        
        dismissButton.snp.makeConstraints { (make) in
            make.size.equalTo(height(24/812))
            make.top.equalToSuperview().offset(topOffset(56/812))
            make.left.equalToSuperview().offset(leftRightOffset(24/375))
        }
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.26)
        }
        resetUI()
        backgroundImageView.image = #imageLiteral(resourceName: "Member-Bg-purple")
    }
    
    private func resetUI() {
        updateBottomView()
        if isLogin {
            fetchBackgroundVideo()
            backgroundImageView.isHidden = true
            bottomLabel.text = "还没有倍利帐号？"
            bottomLabel.textColor = .white
            bottomButton.setTitle("注册帐号", for: .normal)
            logoImv.isHidden = false
        } else {
            backgroundImageView.isHidden = false
            VideoManager.share.removeVideoLayer()
            bottomLabel.text = "已经有倍利帐号？"
            bottomLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            bottomButton.setTitle("登录", for: .normal)
            logoImv.isHidden = true
        }
    }
    
    private func updateBottomView() {
        if isLogin {
            let top = Views.isIPhoneWithNotch() ? topOffset(555/812) : topOffset(589/812)
            bottomView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(top)
                make.centerX.equalToSuperview()
            }
            return
        }
        bottomView.snp.remakeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-topOffset(24/812))
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupLoginPageVC() {
        addChild(loginPageVC)
        view.insertSubview(loginPageVC.view, aboveSubview: backgroundImageView)
        loginPageVC.view.snp.makeConstraints({ (make) in
            make.top.equalToSuperview().offset(topOffset(136/812))
            make.left.bottom.right.equalToSuperview()
        })
    }
    
    private func setupLoginVideo() {
        let videoManager = VideoManager.share
        if let _ = videoManager.videoLayer() {
            videoManager.addVideoLayer(view: view)
            videoManager.play()
            return
        }
        let url = backGroundVideoUrl != nil ? backGroundVideoUrl! : URL(string: BuildConfig.LOGIN_VIDEO_URL)!
        if let _ = videoManager.videoFrom(url: url) {
             videoManager.addVideoLayer(view: view)
        }
    }
}
