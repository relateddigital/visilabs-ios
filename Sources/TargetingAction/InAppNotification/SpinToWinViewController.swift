//
//  SpinToWinViewController.swift
//  VisilabsIOS
//
//  Created by Said Alır on 29.01.2021.
//

import UIKit
import WebKit

class SpinToWinViewController: VisilabsBaseNotificationViewController {
    
    weak var webView: WKWebView!
    var subsEmail = ""
    var sliceText = ""
    
    var pIndexCodes = [Int: String]()
    var pIndexDisplayNames = [Int: String]()
    var sIndexCodes = [Int: String]()
    var sIndexDisplayNames = [Int: String]()
    
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
        configuration.preferences.javaScriptEnabled = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
#if SWIFT_PACKAGE
        let bundle = Bundle.module
#else
        let bundle = Bundle(for: type(of: self))
#endif
        let htmlPath = bundle.path(forResource: "spintowin", ofType: "html") ?? ""
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
    
    private func sendPromotionCodeInfo(promo: String, actId: String, email: String? = "", promoTitle: String, promoSlice: String) {
        var properties = [String: String]()
        properties[VisilabsConstants.promoAction] = promo
        properties[VisilabsConstants.promoActionID] = actId
        if !self.subsEmail.isEmptyOrWhitespace {
            properties[VisilabsConstants.promoEmailKey] = email
        }
        properties[VisilabsConstants.promoTitleKey] = promoTitle
        if !self.sliceText.isEmptyOrWhitespace {
            properties[VisilabsConstants.promoSlice] = promoSlice
        }
        Visilabs.callAPI().customEvent(VisilabsConstants.omEvtGif, properties: properties)
    }
    
}

extension SpinToWinViewController: WKScriptMessageHandler {
    
    private func chooseSlice(selectedIndex: Int, selectedPromoCode: String) {
        
        var promoCode = selectedPromoCode
        var index = selectedIndex
        
        if selectedIndex < 0 {
            if !sIndexCodes.isEmpty, let randomIndex = sIndexCodes.keys.randomElement(), let randomCode = sIndexCodes[randomIndex], let randomDisplay = sIndexDisplayNames[randomIndex] {
                self.sliceText = randomDisplay
                promoCode = randomCode
                index = randomIndex
            }
        }
        
        if index > -1 {
            if !self.subsEmail.isEmptyOrWhitespace {
                self.sendPromotionCodeInfo(promo: promoCode, actId: "act-\(self.spinToWin!.actId)", email: self.subsEmail, promoTitle: self.spinToWin?.promocodeTitle ?? "", promoSlice: self.sliceText)
            } else {
                self.sendPromotionCodeInfo(promo: promoCode, actId: "act-\(self.spinToWin!.actId)", promoTitle: self.spinToWin?.promocodeTitle ?? "", promoSlice: self.sliceText)
            }
        }
        let promoCodeString = index > -1 ? "'\(promoCode)'" : "undefined"
        
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript("window.chooseSlice(\(index), \(promoCodeString));") { (_, err) in
                if let error = err {
                    VisilabsLogger.error(error)
                    VisilabsLogger.error(error.localizedDescription)
                }
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "eventHandler" {
            if let event = message.body as? [String: Any], let method = event["method"] as? String {
                if method == "console.log", let message = event["message"] as? String {
                    VisilabsLogger.info("console.log: \(message)")
                }
                if method == "initSpinToWin" {
                    VisilabsLogger.info("initSpinToWin")
                    if let json = try? JSONEncoder().encode(self.spinToWin!), let jsonString = String(data: json, encoding: .utf8) {
                        self.webView.evaluateJavaScript("window.initSpinToWin(\(jsonString));") { (_, err) in
                            if let error = err {
                                VisilabsLogger.error(error)
                                VisilabsLogger.error(error.localizedDescription)
                                
                            }
                        }
                    }
                }
                
                if method == "subscribeEmail", let email = event["email"] as? String {
                    Visilabs.callAPI().subscribeSpinToWinMail(actid: "\(self.spinToWin!.actId)", auth: self.spinToWin!.auth, mail: email)
                    subsEmail = email
                }
                
                if method == "getPromotionCode" {
                    
                    var index = 0
                    
                    for slice in spinToWin!.slices {
                        if slice.type == "promotion", slice.isAvailable {
                            pIndexCodes[index] = slice.code
                            pIndexDisplayNames[index] = slice.displayName
                        } else if slice.type == "staticcode" {
                            sIndexCodes[index] = slice.code
                            sIndexDisplayNames[index] = slice.displayName
                        }
                        index += 1
                    }
                    
                    if !pIndexCodes.isEmpty, let randomIndex = pIndexCodes.keys.randomElement(), let randomCode = pIndexCodes[randomIndex], let randomDisplay = pIndexDisplayNames[randomIndex] {
                        var props = [String: String]()
                        props["actionid"] = "\(self.spinToWin!.actId)"
                        props["promotionid"] = randomCode
                        props["promoauth"] = "\(self.spinToWin!.promoAuth)"
                        self.sliceText = randomDisplay
                        
                        VisilabsRequest.sendPromotionCodeRequest(properties: props, completion: { (result: [String: Any]?, error: VisilabsError?) in
                            var selectedIndex = randomIndex as Int
                            var selectedPromoCode = ""
                            if error == nil, let res = result, let success = res["success"] as? Bool, success, let promocode = res["promocode"] as? String, !promocode.isEmptyOrWhitespace {
                                selectedPromoCode = promocode
                            } else if let res = result, let success = res["success"] as? Bool, success, let promocode = res["promocode"] as? String  {
                                let id = res["id"] as? Int ?? 0
                                VisilabsLogger.error("Promocode request error: {\"id\":\(id),\"success\":\(success),\"promocode\":\"\(promocode)\"}")
                                selectedIndex = -1
                            } else {
                                VisilabsLogger.error("Promocode request error")
                                selectedIndex = -1
                            }
                            self.chooseSlice(selectedIndex: selectedIndex, selectedPromoCode: selectedPromoCode)
                            
                        })
                    } else {
                        self.chooseSlice(selectedIndex: -1, selectedPromoCode: "")
                    }
                    
                }
                
                if method == "sendReport" {
                    Visilabs.callAPI().trackSpinToWinClick(spinToWinReport: self.spinToWin!.report)
                }
                
                if method == "copyToClipboard", let couponCode = event["couponCode"] as? String {
                    UIPasteboard.general.string = couponCode
                    VisilabsHelper.showCopiedClipboardMessage()
                    self.close()
                }
                
                if method == "close" {
                    self.close()
                }
                
                if method == "openUrl", let urlString = event["url"] as? String, let url = URL(string: urlString) {
                    let app = VisilabsInstance.sharedUIApplication()
                    app?.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: url, waitUntilDone: true)
                }
                
            }
        }
    }
}
