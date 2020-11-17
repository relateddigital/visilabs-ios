//
//  VisilabsHelper.swift
//  VisilabsIOS
//
//  Created by Egemen on 27.04.2020.
//

import Foundation
import AdSupport
import WebKit
import UIKit

internal class VisilabsHelper {

    //TODO: buradaki değerleri VisilabsConfig e aktar, metersPerNauticalMile niye var?
    static func distanceSquared(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        let radius = 0.0174532925199433 // 3.14159265358979323846 / 180.0
        let nauticalMilesPerLatitude = 60.00721
        //let nauticalMilesPerLongitude = 60.10793
        let metersPerNauticalMile = 1852.00
        let nauticalMilesPerLongitudeDividedByTwo = 30.053965
        // simple pythagorean formula - for efficiency
        let yDistance = (lat2 - lat1) * nauticalMilesPerLatitude
        let xDistance = (cos(lat1 * radius) + cos(lat2 * radius)) * (lng2 - lng1) * nauticalMilesPerLongitudeDividedByTwo
        let res = ((yDistance * yDistance) + (xDistance * xDistance)) * (metersPerNauticalMile * metersPerNauticalMile)
        return res
    }

    //TODO: props un boş gelme ihtimalini de düşün
    static func buildUrl(url: String, props: [String: String] = [:], additionalQueryString: String = "") -> String {
        var qsKeyValues = [String]()
        props.forEach { (key, value) in
            qsKeyValues.append("\(key)=\(value)")
        }
        var queryString = qsKeyValues.joined(separator: "&")
        if additionalQueryString.count > 0 {
            queryString = "\(queryString)&\(additionalQueryString)"
        }
        return "\(url)?\(queryString)"
    }

    static func generateCookieId() -> String {
        return UUID().uuidString
    }

    static func readCookie(_ url: URL) -> [HTTPCookie] {
        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies(for: url) ?? []
        return cookies
    }

    static func deleteCookie(_ url: URL) {
        let cookieStorage = HTTPCookieStorage.shared
        for cookie in readCookie(url) {
            cookieStorage.deleteCookie(cookie)
        }
    }

    static func getIDFA() -> String? {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            let IDFA = ASIdentifierManager.shared().advertisingIdentifier
            return IDFA.uuidString
        }
        return nil
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
        VisilabsBasePath.endpoints[.logger] = "\(httpProtocol)://\(VisilabsConstants.loggerEndPoint)/\(dataSource)/\(VisilabsConstants.omGif)"
        VisilabsBasePath.endpoints[.realtime] = "\(httpProtocol)://\(VisilabsConstants.realtimeEndPoint)/\(dataSource)/\(VisilabsConstants.omGif)"
        VisilabsBasePath.endpoints[.target] = "\(httpProtocol)://\(VisilabsConstants.recommendationEndPoint)"
        VisilabsBasePath.endpoints[.action] = "\(httpProtocol)://\(VisilabsConstants.actionEndPoint)"
        VisilabsBasePath.endpoints[.geofence] = "\(httpProtocol)://\(VisilabsConstants.geofenceEndPoint)"
        VisilabsBasePath.endpoints[.mobile] = "\(httpProtocol)://\(VisilabsConstants.mobileEndPoint)"
    }

    static private let dateFormatter = DateFormatter()

    static func formatDate(_ date: Date, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    static func getUIImage(named: String) -> UIImage? {
        let bundle = Bundle(identifier: "com.relateddigital.visilabs")
        return UIImage(named: named, in: bundle, compatibleWith: nil)!
    }

    /* TODO: AppDelegate'e ulaşamadığım için bunu değiştiremiyorum. Olmaması sorun mu?
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        self.lockOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
     */

}
