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
    
    private func getCustomFontNames() -> Set<String> {
        var customFontNames = Set<String>()
        if let spinToWin = self.spinToWin {
            if !spinToWin.displaynameCustomFontFamilyIos.isEmptyOrWhitespace {
                customFontNames.insert(spinToWin.displaynameCustomFontFamilyIos)
            }
            if !spinToWin.titleCustomFontFamilyIos.isEmptyOrWhitespace {
                customFontNames.insert(spinToWin.titleCustomFontFamilyIos)
            }
            if !spinToWin.textCustomFontFamilyIos.isEmptyOrWhitespace {
                customFontNames.insert(spinToWin.textCustomFontFamilyIos)
            }
            if !spinToWin.buttonCustomFontFamilyIos.isEmptyOrWhitespace {
                customFontNames.insert(spinToWin.buttonCustomFontFamilyIos)
            }
            if !spinToWin.promocodeTitleCustomFontFamilyIos.isEmptyOrWhitespace {
                customFontNames.insert(spinToWin.promocodeTitleCustomFontFamilyIos)
            }
            if !spinToWin.copybuttonCustomFontFamilyIos.isEmptyOrWhitespace {
                customFontNames.insert(spinToWin.copybuttonCustomFontFamilyIos)
            }
            if !spinToWin.promocodesSoldoutMessageCustomFontFamilyIos.isEmptyOrWhitespace {
                customFontNames.insert(spinToWin.promocodesSoldoutMessageCustomFontFamilyIos)
            }
        }
        return customFontNames
    }
    
    private func createSpinToWinFiles() -> URL? {
        let manager = FileManager.default
        guard let docUrl = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            VisilabsLogger.error("Can not create documentDirectory")
            return nil
        }
        let htmlUrl = docUrl.appendingPathComponent("spintowin.html")
        let jsUrl = docUrl.appendingPathComponent("spintowin.js")
#if SWIFT_PACKAGE
        let bundle = Bundle.module
#else
        let bundle = Bundle(for: type(of: self))
#endif
        let bundleHtmlPath = bundle.path(forResource: "spintowin", ofType: "html") ?? ""
        let bundleJsPath = bundle.path(forResource: "spintowin", ofType: "js") ?? ""

        let bundleHtmlUrl = URL(fileURLWithPath: bundleHtmlPath)
        let bundleJsUrl = URL(fileURLWithPath: bundleJsPath)
        
        VisilabsHelper.registerFonts(fontNames: getCustomFontNames())
        let fontUrls = getSpinToWinFonts(fontNames: getCustomFontNames())

        do {
            if manager.fileExists(atPath: htmlUrl.path) {
                try manager.removeItem(atPath: htmlUrl.path)
            }
            if manager.fileExists(atPath: jsUrl.path) {
                try manager.removeItem(atPath: jsUrl.path)
            }
            
            try manager.copyItem(at: bundleHtmlUrl, to: htmlUrl)
            try manager.copyItem(at: bundleJsUrl, to: jsUrl)
        } catch let error {
            VisilabsLogger.error(error)
            VisilabsLogger.error(error.localizedDescription)
            return nil
        }
        
        for fontUrlKeyValue in fontUrls {
            do {
                let fontUrl = docUrl.appendingPathComponent(fontUrlKeyValue.key)
                if manager.fileExists(atPath: fontUrl.path) {
                    try manager.removeItem(atPath: fontUrl.path)
                }
                try manager.copyItem(at: fontUrlKeyValue.value, to: fontUrl)
                self.spinToWin?.fontFiles.append(fontUrlKeyValue.key)
            } catch let error {
                VisilabsLogger.error(error)
                VisilabsLogger.error(error.localizedDescription)
                continue
            }
        }
        
        return htmlUrl
    }
    
    private func getSpinToWinFonts(fontNames: Set<String>) -> [String: URL] {
        var fontUrls = [String: URL]()
        if let infos = Bundle.main.infoDictionary {
            if let uiAppFonts = infos["UIAppFonts"] as? [String] {
                for uiAppFont in uiAppFonts {
                    let uiAppFontParts = uiAppFont.split(separator: ".")
                    guard uiAppFontParts.count == 2 else {
                        continue
                    }
                    let fontName = String(uiAppFontParts[0])
                    let fontExtension = String(uiAppFontParts[1])
                    
                    var register = false
                    for name in fontNames {
                        if name.contains(fontName, options: .caseInsensitive) {
                            register = true
                        }
                    }
                    
                    if !register {
                        continue
                    }
                    
                    guard let url = Bundle.main.url(forResource: fontName, withExtension: fontExtension) else {
                        VisilabsLogger.error("UIFont+:  Failed to register font - path for resource not found.")
                        continue
                    }
                    fontUrls[uiAppFont] = url
                }
            }
        }
        return fontUrls
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
    
    func configureWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "eventHandler")
        configuration.userContentController = userContentController
        configuration.preferences.javaScriptEnabled = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        if let htmlUrl = createSpinToWinFiles() {
            webView.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl.deletingLastPathComponent())
            webView.backgroundColor = .clear
            webView.translatesAutoresizingMaskIntoConstraints = false            
        }
        
        return webView
    }
    
    private func close() {
        self.dismiss(animated: true) {
            if let spinToWin = self.spinToWin, spinToWin.showPromoCodeBanner {
                let bannerVC = VisilabsSpinToWinCodeBannerController(spinToWin)
                bannerVC.delegate = self.delegate
                bannerVC.show(animated: true)
                self.delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: false, additionalTrackingProperties: nil)
            } else {
                self.delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: false, additionalTrackingProperties: nil)
            }
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
    
    override func show(animated: Bool) {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else {
            return
        }
        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first
            if let windowScene = windowScene as? UIWindowScene {
                window = UIWindow(frame: windowScene.coordinateSpace.bounds)
                window?.windowScene = windowScene
            }
        } else {
            window = UIWindow(frame: CGRect(x: 0,
                                            y: 0,
                                            width: UIScreen.main.bounds.size.width,
                                            height: UIScreen.main.bounds.size.height))
        }
        if let window = window {
            window.alpha = 0
            window.windowLevel = UIWindow.Level.alert
            window.rootViewController = self
            window.isHidden = false
        }

        let duration = animated ? 0.25 : 0
        UIView.animate(withDuration: duration, animations: {
            self.window?.alpha = 1
            }, completion: { _ in
        })
    }

    override func hide(animated: Bool, completion: @escaping () -> Void) {
        let duration = animated ? 0.25 : 0
        UIView.animate(withDuration: duration, animations: {
            self.window?.alpha = 0
            }, completion: { _ in
                self.window?.isHidden = true
                self.window?.removeFromSuperview()
                self.window = nil
                completion()
        })
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
                } else {
                    self.spinToWin?.bannerCode = promoCodeString.replacingOccurrences(of: "\'", with: "")
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
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            UIPasteboard.general.string = couponCode
                            VisilabsHelper.showCopiedClipboardMessage()
                        }
                        self.close()
                    }
                    
                }
                
                if method == "close" {
                    DispatchQueue.main.async {
                        self.close()
                    }
                }
                
                if method == "openUrl", let urlString = event["url"] as? String, let url = URL(string: urlString) {
                    DispatchQueue.main.async {
                        let app = VisilabsInstance.sharedUIApplication()
                        app?.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: url, waitUntilDone: true)
                    }
                }
                
            }
        }
    }
}
