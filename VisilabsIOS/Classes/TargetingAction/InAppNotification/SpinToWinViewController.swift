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
        webView = configureWebView()
        self.view.addSubview(webView)
        webView.allEdges(to: self.view)
    }
    
    
    override func hide(animated: Bool, completion: @escaping () -> Void) {
        dismiss(animated: true)
        completion()
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
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }
    
    private func close() {
        dismiss(animated: true) {
            self.delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: false, additionalTrackingProperties: nil)
        }
    }
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
                    if let json = try? JSONEncoder().encode(self.spinToWin!), let jsonString = String(data: json, encoding: .utf8) {
                        
                        print(jsonString) // TODO: KALDIR
                        
                        self.webView.evaluateJavaScript("window.initSpinToWin(\(jsonString));") { (data, err) in
                            if let error = err {
                                VisilabsLogger.error(error)
                                VisilabsLogger.error(error.localizedDescription)
                                
                            }
                        }
                    }
                }
                
                if method == "subscribeEmail", let email = event["email"] as? String  {
                    Visilabs.callAPI().subscribeSpinToWinMail(actid: "\(self.spinToWin!.actId)", auth: self.spinToWin!.auth, mail: email)
                }
                
                if method == "getPromotionCode" {
                    var promotionIndexCodes = [Int: String]()
                    var index = 0
                    
                    for slice in spinToWin!.slices {
                        if slice.type == "promotion" {
                            promotionIndexCodes[index] = slice.code
                        }
                        index += 1
                    }
                    
                    if !promotionIndexCodes.isEmpty {
                        if let randomIndex = promotionIndexCodes.keys.randomElement(), let randomCode = promotionIndexCodes[randomIndex] {
                            var props = [String: String]()
                            props[VisilabsConstants.organizationIdKey] = Visilabs.callAPI().visilabsProfile.organizationId
                            props[VisilabsConstants.profileIdKey] = Visilabs.callAPI().visilabsProfile.profileId
                            props[VisilabsConstants.cookieIdKey] = Visilabs.callAPI().visilabsUser.cookieId
                            props[VisilabsConstants.exvisitorIdKey] = Visilabs.callAPI().visilabsUser.exVisitorId
                            props["actionid"] = "\(self.spinToWin!.actId)"
                            props["promotionid"] = randomCode
                            props["promoauth"] = "\(self.spinToWin!.promoAuth)"
                            
                            VisilabsRequest.sendPromotionCodeRequest(properties: props,
                                                                     headers: [String: String](),
                                                                     timeoutInterval: Visilabs.callAPI().visilabsProfile.requestTimeoutInterval,
                                                                     completion: { (result: [String: Any]?, error: VisilabsError?) in
                                                                        
                                                                        var selectedIndex = randomIndex
                                                                        var selectedPromoCode = ""
                                                                        
                                                                        if error == nil, let res = result, let success = res["success"] as? Bool, success, let promocode = res["promocode"] as? String, !promocode.isEmptyOrWhitespace {
                                                                            selectedPromoCode = promocode
                                                                        } else {
                                                                            selectedIndex = -1
                                                                        }
                                                                        DispatchQueue.main.async {
                                                                            self.webView.evaluateJavaScript("window.chooseSlice(\(selectedIndex), '\(selectedPromoCode)');") { (data, err) in
                                                                                if let error = err {
                                                                                    VisilabsLogger.error(error)
                                                                                    VisilabsLogger.error(error.localizedDescription)
                                                                                }
                                                                            }
                                                                        }
                                                                     })
                            
                        }
                        
                        
                        
                    } else {
                        self.webView.evaluateJavaScript("window.chooseSlice(-1, undefined);") { (data, err) in
                            if let error = err {
                                VisilabsLogger.error(error)
                                VisilabsLogger.error(error.localizedDescription)
                                
                            }
                        }
                    }
                }
                
                if method == "sendReport" {
                    Visilabs.callAPI().trackSpinToWinClick(spinToWinReport: self.spinToWin!.report)
                }
                
                if method == "copyToClipboard", let couponCode = event["couponCode"] as? String  {
                    UIPasteboard.general.string = couponCode
                    VisilabsHelper.showCopiedClipboardMessage()
                    self.close()
                }
                
                if method == "close" {
                    self.close()
                }
                
                if method == "openUrl", let urlString = event["url"] as? String, let url = URL(string: urlString)  {
                    let app = VisilabsInstance.sharedUIApplication()
                    app?.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: url, waitUntilDone: true)
                }
                
            }
        }
    }
}
