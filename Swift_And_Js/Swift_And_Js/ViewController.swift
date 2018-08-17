//
//  WebViewController.swift
//  WKWebViewJSForSwift
//
//  Created by 小星星 on 2018/8/16.
//  Copyright © 2018年 yangxin. All rights reserved.
//

import UIKit
import WebKit

public let kScreenHeight = UIScreen.main.bounds.size.height
public let kScreenWdith = UIScreen.main.bounds.size.width

class ViewController: UIViewController {
    static let kListener = "JSListener"
    static let kListenerOther = "JSListenerOther"
    
    
    private lazy var wkConfig: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()
        //声明一个WKUserScript对象
        let params = ["name" : "nicooYoung", "phone": "15108440024"]
        let script = WKUserScript.init(source: "function callJavaScript() {nativeToJavaScript('\(params)');}", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
        return config
    }()
    
    lazy private var rightBarButton: UIBarButtonItem = {
        let barBtn = UIBarButtonItem(title: "CallJs",  style: .plain, target: self, action: #selector(ViewController.rightBarButtonClick))
        return barBtn
    }()
    lazy private var leftBarButton: UIBarButtonItem = {
        let barBtn = UIBarButtonItem(title: "CallJs1",  style: .plain, target: self, action: #selector(ViewController.leftBarButtonClick))
        return barBtn
    }()
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: kScreenWdith, height: kScreenHeight), configuration: wkConfig)
        webView.navigationDelegate = self
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.backgroundColor = UIColor.white
        // 用WeakScriptMessageDelegate(self) 代替self,解决内存泄漏的问题
        webView.configuration.userContentController.add(WeakScriptDelegate(self), name: ViewController.kListener)
        webView.configuration.userContentController.add(WeakScriptDelegate(self), name: ViewController.kListenerOther)
        
        return webView
    }()
    
    deinit {
        print("vc is deinit")    // 出站的时候，这里没走，说明当前控制器没有被释放调，存在内存泄漏
        webView.configuration.userContentController.removeScriptMessageHandler(forName: ViewController.kListener)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: ViewController.kListenerOther)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [leftBarButton, rightBarButton]
        view.addSubview(webView)
        let resouce = Bundle.main.path(forResource: "test", ofType: "html")
        let urlstr = String(format: "file://%@", resouce!)
        webView.load(URLRequest(url: URL(string: urlstr)!))
    }
    
    
  
}

//MARK: - js交互 - 原生调用Js

extension ViewController {
    
    /// WKUserScript对象 调用JS      也可以直接调用 jsString = "nativeToJavaScript('\(params)')"
    @objc func rightBarButtonClick() {
        let jsString = "callJavaScript()"
        webView.evaluateJavaScript(jsString) { (response, error) in
            if (error != nil) {
                print("getINFOfROM = \(String(describing: response))")
            }
        }
    }
    
    /// 直接调用JS,传递参数
    @objc func leftBarButtonClick() {
        
        let params = ["firstObjc", "secondObjc"]
        let jsString = "changeHead('\(params)')"
        webView.evaluateJavaScript(jsString) { (response, error) in
            if (error != nil) {
                print("getINFOfROM = \(response ?? "")")
            }
        }
        
    }
}


//MARK: - js交互  js调用原生  获取到JS传来的参数

extension ViewController: WKScriptMessageHandler {
    /// 交互， 监听JS的事件返回
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == ViewController.kListener {
            print("Js回调的数据为:---\(message.body), 当前线程是：\(Thread.current)")
        } else if message.name == ViewController.kListenerOther {
            print("Js回调的数据为:---\n\(message.body),")
        }
    }
    
    
}

extension ViewController: WKNavigationDelegate {
    
    // 决定导航的动作，通常用于处理跨域的链接能否导航。
    // WebKit对跨域进行了安全检查限制，不允许跨域，因此我们要对不能跨域的链接单独处理。
    // 但是，对于Safari是允许跨域的，不用这么处理。
    // 这个是决定是否Request
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    // 开始接收响应
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    //用于授权验证的API，与AFN、UIWebView的授权验证API是一样的
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling ,nil)
    }
    
    // 开始加载数据
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webView.isHidden = false
        // self.indicatorView.startAnimating()
    }
    
    // 当main frame接收到服务重定向时调用
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        // 接收到服务器跳转请求之后调用
    }
    
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.offsetHeight") { [weak self] (result, error) in
            if let strongSelf = self {
                if let webheight = result as? CGFloat {
                    print("网页高度= \(webheight)")
                }
            }
        }
    }
    
    //当main frame导航完成时，会回调
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        webView.evaluateJavaScript("document.body.offsetHeight") { [weak self] (result, error) in
            if let strongSelf = self {
                if let webheight = result as? CGFloat {
                    print("网页高度= \(webheight)")
                }
            }
        }
    }
    
    // 当web content处理完成时，会回调
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.evaluateJavaScript("document.body.offsetHeight") { [weak self] (result, error) in
            if let strongSelf = self {
                if let webheight = result as? CGFloat {
                    print("网页高度= \(webheight)")
                }
            }
        }
    }
    
    // 当main frame开始加载数据失败时，会回调
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
    // 当main frame最后下载数据失败时，会回调
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
}


