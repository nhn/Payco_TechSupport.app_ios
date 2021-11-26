//
//  PaycoOnlinePaymentWebViewController.swift
//  PaycoOnlinePaymentDemo
//
//  Created by artist on 2020/02/20.
//  Copyright © 2020 NHN Payco. All rights reserved.
//

import UIKit
import WebKit

class PaycoOnlinePaymentWebViewController: UIViewController {

    lazy var wkWebView: WKWebView = {
        let webView = WKWebView();
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView;
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = URLRequest(url: URL(string: "https://devcenter.payco.com/demo/easyPay2")!)

        self.view.addSubview(wkWebView)
        
        wkWebView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        wkWebView.load(request)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PaycoOnlinePaymentWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url: URL = navigationAction.request.url, let scheme = url.scheme {
            switch scheme {
            case "payco":
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:]) { (success) in
                        decisionHandler(.cancel)
                    }
                } else {
                    UIApplication.shared.openURL(url)
                    decisionHandler(.cancel)
                }
                break
            default:
                decisionHandler(.allow)
                break
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertVC = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(ok)
        self.present(alertVC, animated: true, completion: nil)
        completionHandler()
        
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                wkWebView.load(URLRequest(url: url))
            }
        }
        return nil
    }
}

extension PaycoOnlinePaymentWebViewController: WKUIDelegate {
    // Do Something you need.
}
