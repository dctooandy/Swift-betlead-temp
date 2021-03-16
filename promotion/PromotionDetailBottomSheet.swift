//
//  PromotionDetailBottomSheet.swift
//  betlead
//
//  Created by Andy Chen on 2019/7/5.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import WebKit
import RxSwift
import Lottie
class PromotionDetailBottomSheet: BaseBottomSheet {
    
    enum Method:String,CaseIterable {
        case bonus_success
        case bonus_failed
        case token_expired
    }
    
    private lazy var contentWebView:WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        for method in Method.allCases {
            configuration.userContentController.add(self, name: method.rawValue)
        }
        let source: String = "var meta = document.createElement('meta');" + "meta.name = 'viewport';" + "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" + "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
        let webview = WKWebView(frame: self.view.frame, configuration: configuration)
        webview.navigationDelegate = self
        return webview
    }()
     var promotionDetailId:Int = 0
    
    private let host = ApiService.host == BuildConfig.HG_SITE_TEST_API_HOST ? BuildConfig.HG_SITE_TEST_PROMOTIONDETAIL : BuildConfig.HG_SITE_STAGE_PROMOTIONDETAIL
    
    private let loadingView: AnimationView = {
        let view = AnimationView(name:"betlead_loading")
        view.loopMode = LottieLoopMode.loop
        view.animationSpeed = 2
        return view
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ parameters: Any? ) {
        self.promotionDetailId = parameters as! Int
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadingView.play()
        if let finger = KeychainManager.share.getFingerID(){
            contentWebView.load(URLRequest(url: URL(string: "\(host)?id=\(promotionDetailId)&token=\(KeychainManager.share.getToken())&finger=\(finger)")!) )
        }
    }
    override func setupViews() {
        super.setupViews()
        defaultContainer.addSubview(contentWebView)
        defaultContainer.addSubview(loadingView)
        defaultContainer.snp.makeConstraints { (maker) in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.height.equalTo(600 + Views.bottomOffset)
        }
        
        contentWebView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: Views.bottomOffset, right: 0) )
        }
        loadingView.frame.size = CGSize(width: 200, height: 200)
        loadingView.center = CGPoint(x: Views.screenWidth/2  , y: 200)
        view.layoutIfNeeded()
        defaultContainer.roundCorner(corners: [.topLeft,.topRight], radius: 18)
        submitBtn.isHidden = true
        
    }
    
}

extension PromotionDetailBottomSheet: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        guard let method = Method(rawValue: message.name)
            else { return }
        switch method {
        case .bonus_success:
            dismissVC()
        case .bonus_failed:
            break
        case .token_expired:
            ErrorHandler.showAlert(title: "错误讯息", message: "连线逾时请重新登入")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIApplication.shared.keyWindow?.rootViewController =  LoginSignupViewController.share.isLogin(true)
            }
        }
    }
    
    
}
extension PromotionDetailBottomSheet: WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        loadingView.isHidden = true
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
        loadingView.isHidden = true
    }
}
