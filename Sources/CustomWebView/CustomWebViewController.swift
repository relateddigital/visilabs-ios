//
//  CustomWebViewController.swift
//  RelatedDigitalIOS
//
//  Created by Orhun Akmil on 18.11.2024.
//

import UIKit
import WebKit

class CustomWebViewController: VisilabsBaseNotificationViewController {
    weak var webView: WKWebView!
    var subsEmail = ""
    var codeGotten = false
    private let containerView = UIView()
    private var position: ScreenPosition = .bottomRight
    private var widthFraction: CGFloat = 1/3
    private var heightFraction: CGFloat = 1/3
    private var cornerRadius = 25.0

    override func viewDidLoad() {
        super.viewDidLoad()
        webView = configureWebView()
        containerView.layer.masksToBounds = true
        containerView.addSubview(webView)
        webView.allEdges(to: containerView)
        self.view.addSubview(containerView)
        containerView.allEdges(to: self.view)
        containerView.layer.cornerRadius = cornerRadius
        
    }

    init(_ customWebViewModel: CustomWebViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.customWebViewModel = customWebViewModel
        self.position = getScreenPosition(from: customWebViewModel.position) ?? .bottomLeft
        self.widthFraction = CGFloat(customWebViewModel.width / 100.0)
        self.heightFraction = CGFloat(customWebViewModel.height / 100.0)
        self.cornerRadius = Double(customWebViewModel.borderRadius)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func getScreenPosition(from string: String) -> ScreenPosition? {
        switch string.lowercased() {
        case "topleft": return .topLeft
        case "topcenter": return .topCenter
        case "topright": return .topRight
        case "middleleft": return .middleLeft
        case "middlecenter": return .middleCenter
        case "middleright": return .middleRight
        case "bottomleft": return .bottomLeft
        case "bottomcenter": return .bottomCenter
        case "bottomright": return .bottomRight
        default: return nil
        }
    }

    private func close() {
        dismiss(animated: true) {
            if let customWebView = self.customWebViewModel, !customWebView.promocode_banner_button_label.isEmptyOrWhitespace, self.codeGotten == true {
                if customWebView.bannercodeShouldShow ?? false {
                    let bannerVC = RDCustomWebViewBannerController(customWebView)
                    bannerVC.delegate = self.delegate
                    bannerVC.show(animated: true)
                }
                self.delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: false, additionalTrackingProperties: nil)
            } else {
                self.delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: false, additionalTrackingProperties: nil)
            }
        }
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

         var x: CGFloat = 0
         var y: CGFloat = 0

         switch position {
         case .topLeft:
              x = 0
              y = 0
          case .topCenter:
              x = ((window?.frame.width ?? 0) - ((window?.frame.width ?? 0) * widthFraction)) / 2
              y = 0
          case .topRight:
              x = (window?.frame.width ?? 0) - ((window?.frame.width ?? 0) * widthFraction)
              y = 0
          case .middleLeft:
              x = 0
              y = ((window?.frame.height ?? 0) - ((window?.frame.height ?? 0) * heightFraction)) / 2
          case .middleCenter:
              x = ((window?.frame.width ?? 0) - ((window?.frame.width ?? 0) * widthFraction)) / 2
              y = ((window?.frame.height ?? 0) - ((window?.frame.height ?? 0) * heightFraction)) / 2
          case .middleRight:
              x = (window?.frame.width ?? 0) - ((window?.frame.width ?? 0) * widthFraction)
              y = ((window?.frame.height ?? 0) - ((window?.frame.height ?? 0) * heightFraction)) / 2
          case .bottomLeft:
              x = 0
              y = (window?.frame.height ?? 0) - ((window?.frame.height ?? 0) * heightFraction)
          case .bottomCenter:
              x = ((window?.frame.width ?? 0) - ((window?.frame.width ?? 0) * widthFraction)) / 2
              y = (window?.frame.height ?? 0) - ((window?.frame.height ?? 0) * heightFraction)
          case .bottomRight:
              x = (window?.frame.width ?? 0) - ((window?.frame.width ?? 0) * widthFraction)
              y = (window?.frame.height ?? 0) - ((window?.frame.height ?? 0) * heightFraction)
          }

         let frame = CGRect(x: x, y: y, width: (window?.frame.width ?? 0) * widthFraction, height: (window?.frame.height ?? 0) * heightFraction)

         let duration = animated ? 0.25 : 0
         UIView.animate(withDuration: duration, animations: {
             self.window?.alpha = 1
             self.window?.frame = frame
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

    func configureWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "eventHandler")
        configuration.userContentController = userContentController
        configuration.preferences.javaScriptEnabled = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        if let htmlUrl = createFiles() {
            webView.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl.deletingLastPathComponent())
            webView.backgroundColor = .clear
            webView.translatesAutoresizingMaskIntoConstraints = false
        }

        return webView
    }

    private func createFiles() -> URL? {
        let manager = FileManager.default
        
        let htmlString = self.customWebViewModel?.htmlContent

        guard let docUrl = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            VisilabsLogger.error("DocumentDirectory oluşturulamadı")
            return nil
        }

        let htmlUrl = docUrl.appendingPathComponent("index.html")
        let jsUrl = docUrl.appendingPathComponent("script.js")

        do {
            if manager.fileExists(atPath: htmlUrl.path) {
                try manager.removeItem(atPath: htmlUrl.path)
            }
            if manager.fileExists(atPath: jsUrl.path) {
                try manager.removeItem(atPath: jsUrl.path)
            }

            try htmlString?.write(to: htmlUrl, atomically: true, encoding: .utf8)

            if let jsContent = customWebViewModel?.jsContent?.utf8 {
                guard manager.createFile(atPath: jsUrl.path, contents: Data(jsContent)) else {
                    return nil
                }
            } else {
                return nil
            }

            // Geri kalan font işlemleri...

        } catch let error {
            VisilabsLogger.error(error)
            VisilabsLogger.error(error.localizedDescription)
            return nil
        }

        return htmlUrl
    }

    private func gameFonts(fontNames: Set<String>) -> [String: URL] {
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

    private func getCustomFontNames() -> Set<String> {
        var customFontNames = Set<String>()
        if let customWebViewModel = self.customWebViewModel {
            if !customWebViewModel.custom_font_family_ios.isEmptyOrWhitespace {
                customFontNames.insert(customWebViewModel.custom_font_family_ios)
            }
        }
        return customFontNames
    }

}

extension CustomWebViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if message.name == "eventHandler" {
            if let event = message.body as? [String: Any], let method = event["method"] as? String {
                if method == "console.log", let message = event["message"] as? String {
                    VisilabsLogger.info("console.log: \(message)")
                }
                
                if method == "initCustomweb" {
                    VisilabsLogger.info("initCustomweb")
                    
                    if let jsonString = customWebViewModel?.jsonContent {
                        self.webView.evaluateJavaScript("window.initCustomweb(\(jsonString));") { (_, err) in
                            if let error = err {
                                VisilabsLogger.error(error)
                                VisilabsLogger.error(error.localizedDescription)

                            }
                        }
                    }
                }

                if method == "copyToClipboard", let couponCode = event["couponCode"] as? String {
                    UIPasteboard.general.string = couponCode
                    VisilabsHelper.showCopiedClipboardMessage()
                    self.close()
                }

                if method == "subscribeEmail", let email = event["email"] as? String {
                    Visilabs.callAPI().subscribeCustomWebViewMail(actid: "\(self.customWebViewModel!.actId ?? 0)", auth: self.customWebViewModel!.auth, mail: email)
                    subsEmail = email
                }

                if method == "sendReport" {
                    Visilabs.callAPI().trackCustomWebviewClick(customWebviewReport:(self.customWebViewModel?.report)!)
                }

                if method == "linkClicked", let urlLnk = event["url"] as? String {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        if let url = URL(string: urlLnk) {
                            UIApplication.shared.open(url)
                        }
                    }
                }

                if method == "saveCodeGotten", let code = event["code"] as? String, let mail = event["email"] as? String  {
                    codeGotten = true
                    UIPasteboard.general.string = code
                    BannerCodeManager.shared.setCustomWebViewCode(code: code)
                    let actionID = self.customWebViewModel?.actId
                    var properties = [String:String]()
                    properties[VisilabsConstants.promoActionID] = String(actionID ?? 0)
                    properties[VisilabsConstants.promoEmailKey] = mail
                    properties[VisilabsConstants.promoAction] = code
                    Visilabs.callAPI().customEvent(VisilabsConstants.omEvtGif, properties: properties)
                    
                }
                

                if method == "close" {
                    self.close()
                }
            }
        }

    }

}


enum ScreenPosition {
    case topLeft
    case topCenter
    case topRight
    case middleLeft
    case middleCenter
    case middleRight
    case bottomLeft
    case bottomCenter
    case bottomRight
}
