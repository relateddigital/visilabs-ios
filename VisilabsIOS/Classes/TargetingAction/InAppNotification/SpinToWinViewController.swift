//
//  SpinToWinViewController.swift
//  VisilabsIOS
//
//  Created by Said Alır on 29.01.2021.
//

import UIKit
import WebKit

class SpinToWinViewController: UIViewController {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView = configureWebView()
        self.view.addSubview(webView)
        webView.allEdges(to: self.view)
    }

    
    func configureWebView() -> WKWebView {
        let view = WKWebView(frame: .zero)
        view.configuration.userContentController.add(self, name: "logHandler")
        
        let bundle = Bundle(identifier: "com.relateddigital.visilabs")
        let htmlPath = bundle?.path(forResource: "spintowin", ofType: "html") ?? ""
        let url = URL(fileURLWithPath: htmlPath)
        view.load(URLRequest(url: url))
        view.backgroundColor = .clear
        return view
    }
}

extension SpinToWinViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("*** \(message.name) === \(message.body)")
        if message.name == "logHandler" {
            print("LOG: \(message.body)")
        }
        guard let body = message.body as? String else {
            return
        }
        if body == "close button clicked" {
            self.dismiss(animated: true, completion: nil)
        } else if body.contains("copyToClipboard button clicked") {
            VisilabsHelper.showCopiedClipboardMessage()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
