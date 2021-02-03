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
    
    func configureJS() -> SpinConfig?{
//        let actionData: [String: Any] = [:]
//
//        return nil
        var config = SpinConfig(actid: "1", actionData: nil)
        let encoder = JSONEncoder()
        let jsonConf = try? encoder.encode(config)
        self.webView.evaluateJavaScript("var config = \(jsonConf); var spinToWin = new SpinToWin(config);") { (<#Any?#>, <#Error?#>) in
            <#code#>
        }
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

struct SpinConfig: Codable {
    var actid: String
    var actionData: ConfigAction?
}

struct ConfigAction: Codable {

    var background_color: String
    var close_button_color: String

    var msg_title_color: String
    var msg_title_font_family: String
    var msg_title_textsize: Int
    
    var button_color: String
    var button_text_color: String
    var button_font_family: String
    var button_textsize: Int
    
    var consent_text_textsize: Int
    
    var promotion_code_color: String
    var promotion_code_text_color: String
    var promotion_code_font_family: String
    var promotion_code_textsize: Int
    
    var copy_button_text: String
    var copy_button_color: String
    var copy_button_text_color: String
    var copy_button_font_family: String
    var copy_button_textsize: Int
    
    var slices: [SpinTWSlice]
    
    var view_type: String
    var mail_subscription: Bool
    var spin_to_win_content: SpinTWContent

    var font_size: Int
    var circle_R: Float
    var auth: String
    var type: String
    var waiting_time: Int
    var promoAuth: String
    var slice_count: Int
    var sendemail: Bool
    var esp_cmpid: String?
    var courseofaction: String
    var Javascript: String?
}

struct SpinTWSlice: Codable {
    var displayName: String
    var color: String
    var code: String?
    var type: String
}

struct SpinTWContent: Codable {
    var title: String
    var message: String
    var placeholder: String
    var button_label: String
    var title_style: String?
    var message_style: String?
    var button_style: String?
    var consent_text: String
    var container_style: String?
    var invalid_email_message: String
    var input_style: String
    var validation_message_style: String?
    var consent_text_container_style: String?
    var success_message: String
    var success_message_style: String?
    var emailpermit_text: String
}
