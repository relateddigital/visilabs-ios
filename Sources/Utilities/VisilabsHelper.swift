//
//  VisilabsHelper.swift
//  VisilabsIOS
//
//  Created by Egemen on 27.04.2020.
//

import Foundation
import class Foundation.Bundle
import AdSupport
import WebKit
import UIKit
import AppTrackingTransparency

internal class VisilabsHelper {
    
    // TO_DO: buradaki değerleri VisilabsConfig e aktar, metersPerNauticalMile niye var?
    static func distanceSquared(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        let radius = 0.0174532925199433 // 3.14159265358979323846 / 180.0
        let nauticalMilesPerLatitude = 60.00721
        // let nauticalMilesPerLongitude = 60.10793
        let metersPerNauticalMile = 1852.00
        let nauticalMilesPerLongitudeDividedByTwo = 30.053965
        // simple pythagorean formula - for efficiency
        let yDistance = (lat2 - lat1) * nauticalMilesPerLatitude
        let xDistance = (cos(lat1 * radius) + cos(lat2 * radius))
        * (lng2 - lng1) * nauticalMilesPerLongitudeDividedByTwo
        let res = ((yDistance * yDistance) + (xDistance * xDistance))
        * (metersPerNauticalMile * metersPerNauticalMile)
        return res
    }
    
    static func generateCookieId() -> String {
        return UUID().uuidString
    }
    
    static func readCookie(_ url: URL) -> [HTTPCookie] {
        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies(for: url) ?? []
        return cookies
    }
    
    static func getIDFA(completion: @escaping (String?) -> Void) {
        if #available(iOS 14, *) {
            if containsUserTrackingUsageDescriptionKey() {
                ATTrackingManager.requestTrackingAuthorization { status in
                    if status == .authorized {
                        let IDFA = ASIdentifierManager.shared().advertisingIdentifier
                        completion(IDFA.uuidString)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                VisilabsLogger.warn("NSUserTrackingUsageDescription key is missing")
            }
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                let IDFA = ASIdentifierManager.shared().advertisingIdentifier
                completion(IDFA.uuidString)
            } else {
                completion(nil)
            }
        }
    }
    
    static private var webView: WKWebView?
    
    static func computeWebViewUserAgent(completion: @escaping ((String) -> Void)) {
        DispatchQueue.main.async { [completion] in
            webView = WKWebView(frame: CGRect.zero)
            webView?.loadHTMLString("<html></html>", baseURL: nil)
            webView?.evaluateJavaScript("navigator.userAgent", completionHandler: { userAgent, error in
                if error == nil, let userAgentString = userAgent as? String, userAgentString.count > 0 {
                    completion(userAgentString)
                } else {
                    VisilabsLogger.error("Visilabs can not compute user agent.")
                }
            })
        }
    }
    
    static func setEndpoints(dataSource: String, useInsecureProtocol: Bool = false) {
        let httpProtocol = useInsecureProtocol ? VisilabsConstants.HTTP : VisilabsConstants.HTTPS
        VisilabsBasePath.endpoints[.logger] =
        "\(httpProtocol)://\(VisilabsConstants.loggerEndPoint)/\(dataSource)/\(VisilabsConstants.omGif)"
        VisilabsBasePath.endpoints[.realtime] =
        "\(httpProtocol)://\(VisilabsConstants.realtimeEndPoint)/\(dataSource)/\(VisilabsConstants.omGif)"
        VisilabsBasePath.endpoints[.target] = "\(httpProtocol)://\(VisilabsConstants.recommendationEndPoint)"
        VisilabsBasePath.endpoints[.action] = "\(httpProtocol)://\(VisilabsConstants.actionEndPoint)"
        VisilabsBasePath.endpoints[.geofence] = "\(httpProtocol)://\(VisilabsConstants.geofenceEndPoint)"
        VisilabsBasePath.endpoints[.mobile] = "\(httpProtocol)://\(VisilabsConstants.mobileEndPoint)"
        VisilabsBasePath.endpoints[.subsjson] = "\(httpProtocol)://\(VisilabsConstants.subsjsonEndpoint)"
        VisilabsBasePath.endpoints[.promotion] = "\(httpProtocol)://\(VisilabsConstants.promotionEndpoint)"
        VisilabsBasePath.endpoints[.remote] = "https://\(VisilabsConstants.remoteConfigEndpoint)"
    }
    
    static private let dateFormatter = DateFormatter()
    
    static func formatDate(_ date: Date, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    static func parseDate(_ dateString: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }
    
    static func getUIImage(named: String) -> UIImage? {
#if SWIFT_PACKAGE
        let bundle = Bundle.module
#else
        let bundle = Bundle(for: self as AnyClass)
#endif
        return UIImage(named: named, in: bundle, compatibleWith: nil)!
    }
    
    static func checkEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //static let DELAY_SHORT = 1.5
    static let DELAY_LONG = 3.0
    
    static func showToast(_ text: String, delay: TimeInterval = DELAY_LONG) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        let label = ToastLabel()
        label.backgroundColor = UIColor(white: 0, alpha: 0.5)
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.alpha = 0
        label.text = text
        label.numberOfLines = 0
        
        var vertical: CGFloat = 0
        var size = label.intrinsicContentSize
        var width = min(size.width, window.frame.width - 60)
        if width != size.width {
            vertical = 10
            label.textAlignment = .justified
        }
        label.textInsets = UIEdgeInsets(top: vertical, left: 15, bottom: vertical, right: 15)
        
        size = label.intrinsicContentSize
        width = min(size.width, window.frame.width - 60)
        
        label.frame = CGRect(x: 20, y: window.frame.height - 90, width: width, height: size.height + 20)
        label.center.x = window.center.x
        label.layer.cornerRadius = min(label.frame.height/2, 25)
        label.layer.masksToBounds = true
        window.addSubview(label)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            label.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseOut, animations: {
                label.alpha = 0
            }, completion: {_ in
                label.removeFromSuperview()
            })
        })
    }
    
    static func showCopiedClipboardMessage() {
        if Locale.current.languageCode == "en" {
            VisilabsHelper.showToast("Copied to clipboard", delay: 1.5)
        } else {
            VisilabsHelper.showToast("Panoya kopyalandı", delay: 1.5)
        }
    }
    
    static func convertColorArray(_ strArr: [String]?) -> [UIColor]? {
        guard let arr = strArr else {
            return nil
        }
        var colorArr: [UIColor] = []
        for hex in arr {
            colorArr.append(UIColor(hex: hex) ?? UIColor.black)
        }
        return colorArr
    }
    
    static func isiOSAppExtension() -> Bool {
        return Bundle.main.bundlePath.hasSuffix(".appex")
    }
    
    static func getSdkVersion() -> String {
#if SWIFT_PACKAGE
        let bundle = Bundle.module
#else
        let bundle = Bundle(for: Visilabs.self)
#endif
        if let infos = bundle.infoDictionary {
            if let shortVersion = infos["CFBundleShortVersionString"] as? String {
                return shortVersion
            }
        }
        return VisilabsConstants.sdkVersion
    }
    
    static func getAppVersion() -> String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static func containsUserTrackingUsageDescriptionKey() -> Bool {
        guard let _ = Bundle.main.object(forInfoDictionaryKey: "NSUserTrackingUsageDescription") else {
            return false
        }
        return true
    }
    
    static private func getVisibleViewController(_ vc: UIViewController?) -> UIViewController? {
        if vc is UINavigationController {
            return getVisibleViewController((vc as? UINavigationController)?.visibleViewController)
        } else if vc is UITabBarController {
            return getVisibleViewController((vc as? UITabBarController)?.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return getVisibleViewController(pvc.presentedViewController)
            } else {
                return vc
            }
        }
    }
    
    static func getRootViewController() -> UIViewController? {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else {
            return nil
        }
        if let rootViewController = sharedUIApplication.keyWindow?.rootViewController {
            return getVisibleViewController(rootViewController)
        }
        return nil
    }
    
    static func getSafeAreaInsets() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets ?? .zero
        } else {
            let statusBarMaxY = UIApplication.shared.statusBarFrame.maxY
            return UIEdgeInsets(top: statusBarMaxY, left: 0, bottom: 10, right: 0)
        }
    }
    
    static func getFont(fontFamily: String?, fontSize: String?, style: UIFont.TextStyle,customFont:String? = "") -> UIFont {
        var size = style == .title2 ? 12 : 8
        if let fSize = fontSize, let siz = Int(fSize), siz > 0 {
            size += siz
        }
        var finalFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: style),
                               size: CGFloat(size))
        if let font = fontFamily {
            if #available(iOS 13.0, *) {
                var systemDesign: UIFontDescriptor.SystemDesign  = .default
                if font.lowercased() == "serif" || font.lowercased() == "sansserif" {
                    systemDesign = .serif
                } else if font.lowercased() == "monospace" {
                    systemDesign = .monospaced
                }
                if let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
                    .withDesign(systemDesign) {
                    finalFont = UIFont(descriptor: fontDescriptor, size: CGFloat(size))
                }
            } else {
                if font.lowercased() == "serif" || font.lowercased() == "sansserif" {
                    let fontName = style == .title2 ? "GillSans-Bold": "GillSans"
                    finalFont = UIFont(name: fontName, size: CGFloat(size))!
                } else if font.lowercased() == "monospace" {
                    let fontName = style == .title2 ? "CourierNewPS-BoldMT": "CourierNewPSMT"
                    finalFont = UIFont(name: fontName, size: CGFloat(size))!
                }
            }
            
            if let uiCustomFont = UIFont(name: customFont ?? "", size: CGFloat(size)) {
                return uiCustomFont
            }
        }
        return finalFont
    }
    
    static func getImageUrl(_ imageUrlString: String, type: VisilabsInAppNotificationType) -> URL? {
        var imageUrl: URL?
        var urlString = imageUrlString
        if type == .mini {
            urlString = imageUrlString.getUrlWithoutExtension() + "@2x." + imageUrlString.getUrlExtension()
        }
        if let escapedImageUrlString = urlString.addingPercentEncoding(withAllowedCharacters:
                                                                        NSCharacterSet.urlQueryAllowed),
           let imageUrlComponents = URLComponents(string: escapedImageUrlString),
           let imageUrlParsed = imageUrlComponents.url {
            imageUrl = imageUrlParsed
        }
        return imageUrl
    }
    
    static func registerFonts(fontNames: Set<String>) {
        if let infos = Bundle.main.infoDictionary {
            if let uiAppFonts = infos["UIAppFonts"] as? [String] {
                for uiAppFont in uiAppFonts {
                    
                    let uiAppFontParts = uiAppFont.split(separator: ".")
                    guard uiAppFontParts.count == 2 else {
                        return
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
                    
                    guard let fontDataProvider = CGDataProvider(url: url as CFURL) else {
                        VisilabsLogger.error("CGDataProvider: ERROR")
                        continue
                    }
                    
                    if let font = CGFont(fontDataProvider) {
                        var error: Unmanaged<CFError>?
                        guard CTFontManagerRegisterGraphicsFont(font, &error) else {
                            VisilabsLogger.error("CTFontManagerRegisterGraphicsFont: ERROR")
                            continue
                        }
                        VisilabsLogger.error("\(String(describing: font.fullName)): registered")
                    }
                }
            }
        }
    }
    
}

class ToastLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top, left: -textInsets.left, bottom: -textInsets.bottom, right: -textInsets.right)
        
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}
