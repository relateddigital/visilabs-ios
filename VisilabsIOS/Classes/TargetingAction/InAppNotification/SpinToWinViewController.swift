//
//  SpinToWinViewController.swift
//  VisilabsIOS
//
//  Created by Said Alır on 29.01.2021.
//

import UIKit
import WebKit

class SpinToWinViewController: VisilabsBaseNotificationViewController {
    
    var webView: WKWebView!
    
    init(_ spinToWin: SpinToWinViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.spinToWin = spinToWin
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView = configureWebView()
        self.view.addSubview(webView)
        webView.allEdges(to: self.view)
    }

    
    func configureWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "eventHandler")
        configuration.userContentController = userContentController
        let webView = WKWebView(frame: .zero, configuration: configuration)
        let bundle = Bundle(identifier: "com.relateddigital.visilabs")
        let htmlPath = bundle?.path(forResource: "spintowin", ofType: "html") ?? ""
        let url = URL(fileURLWithPath: htmlPath)
        webView.load(URLRequest(url: url))
        webView.backgroundColor = .clear
        return webView
    }
    
    
    /*
    func configureJS() -> SpinConfig?{
        var config = SpinConfig(actid: "1", actionData: nil)
        let encoder = JSONEncoder()
        let jsonConf = try? encoder.encode(config)
        self.webView.evaluateJavaScript("var config = \(jsonConf); var spinToWin = new SpinToWin(config);") { (data, err) in
            
        }
        return config;
    }
    */
    
    
}

extension SpinToWinViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "eventHandler" {
            if let event = message.body as? [String: Any], let method = event["method"] as? String {
                if method == "console.log", let message = event["message"] as? String {
                    VisilabsLogger.info("console.log: \(message)")
                }
                if method == "initSpinToWin" {
                    VisilabsLogger.info("initSpinToWin")
                    if let json = try? JSONEncoder().encode(self.spinToWin), let jsonString = String(data: json, encoding: .utf8) {
                        print(jsonString)
                        self.webView.evaluateJavaScript("window.initSpinToWin(\(jsonString));") { (data, err) in
                            if let error = err {
                                VisilabsLogger.error(error.localizedDescription)
                            }
                        }
                    }
                }
                
                
            }
        }
        
        
        /*
        if message.name == "initSpinToWin" {
            //TODO: buraya data gelecek
            self.webView.evaluateJavaScript("initSpinToWin()") { (data, err) in
                
            }
        }
        
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
        */
        
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
