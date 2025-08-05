//
//  PollViewController.swift
//  Pods
//
//  Created by Orhun Akmil on 5.08.2025.
//



import Foundation

import UIKit
import WebKit

class PollViewController: VisilabsBaseNotificationViewController {
    weak var webView: WKWebView!
    var subsEmail = ""
    var codeGotten = false

    override func viewDidLoad() {
        super.viewDidLoad()
        webView = configureWebView()
        self.view.addSubview(webView)
        webView.allEdges(to: self.view)
    }

    init(_ pollModel: PollModel) {
        super.init(nibName: nil, bundle: nil)
        self.poll = pollModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func close() {
        dismiss(animated: true) {
            if let pollModel = self.poll, !pollModel.promocode_banner_button_label.isEmptyOrWhitespace, self.codeGotten == true {
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

    func configureWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "eventHandler")
        configuration.userContentController = userContentController
        configuration.preferences.javaScriptEnabled = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        if let htmlUrl = createPollFiles() {
            webView.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl.deletingLastPathComponent())
            webView.backgroundColor = .clear
            webView.translatesAutoresizingMaskIntoConstraints = false
        }

        return webView
    }

    private func createPollFiles() -> URL? {
        let manager = FileManager.default
        guard let docUrl = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            VisilabsLogger.error("Can not create documentDirectory")
            return nil
        }
        let htmlUrl = docUrl.appendingPathComponent("poll.html")
        let jsUrl = docUrl.appendingPathComponent("survey.js")
#if SWIFT_PACKAGE
        let bundle = Bundle.module
#else
        let bundle = Bundle(for: type(of: self))
#endif
        let bundleHtmlPath = bundle.path(forResource: "poll", ofType: "html") ?? ""

        let bundleHtmlUrl = URL(fileURLWithPath: bundleHtmlPath)

        VisilabsHelper.registerFonts(fontNames: getCustomFontNames())
        let fontUrls = gameFonts(fontNames: getCustomFontNames())

        do {
            if manager.fileExists(atPath: htmlUrl.path) {
                try manager.removeItem(atPath: htmlUrl.path)
            }
            if manager.fileExists(atPath: jsUrl.path) {
                try manager.removeItem(atPath: jsUrl.path)
            }

            try manager.copyItem(at: bundleHtmlUrl, to: htmlUrl)

            if let jsContent = poll?.jsContent?.utf8 {
                guard manager.createFile(atPath: jsUrl.path, contents: Data(jsContent)) else {
                    return nil
                }
            } else {
                return nil
            }

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
                self.poll?.fontFiles.append(fontUrlKeyValue.key)
            } catch let error {
                VisilabsLogger.error(error)
                VisilabsLogger.error(error.localizedDescription)
                continue
            }
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
        if let poll = self.poll {
            if !poll.custom_font_family_ios.isEmptyOrWhitespace {
                customFontNames.insert(poll.custom_font_family_ios)
            }
        }
        return customFontNames
    }

}

extension PollViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if message.name == "eventHandler" {
            if let event = message.body as? [String: Any], let method = event["method"] as? String {
                if method == "console.log", let message = event["message"] as? String {
                    VisilabsLogger.info("console.log: \(message)")
                }
                
                if method == "initSurvey" {
                    VisilabsLogger.info("initSurvey")
                    
                    if let jsonString = poll?.jsonContent {
                        self.webView.evaluateJavaScript("window.initSurvey(\(jsonString));") { (_, err) in
                            if let error = err {
                                VisilabsLogger.error(error)
                                VisilabsLogger.error(error.localizedDescription)

                            }
                        }
                    }
                }

                if method == "sendReport" {

                    Visilabs.callAPI().trackPollClick(pollReport: (self.poll?.report)!)

                    if let payloadString = event["payload"] as? String {

                        guard let payloadData = payloadString.data(using: .utf8) else {
                            print("Hata: Payload string'i Data'ya çevrilemedi.")
                            return
                        }

                        do {

                            let result = try JSONDecoder().decode(SurveyResult.self, from: payloadData)

                            if !result.questions.isEmpty {
                                for qa in result.questions {
                                    
                                    var parameters: [String: String] = [:]

                                    parameters["OM.s_group"] = result.title
                                    parameters["OM.s_cat"] = qa.question
                                    parameters["OM.s_page"] = qa.answer
                                    Visilabs.callAPI().customEvent("survey-report", properties: parameters)
                                    
                                    print("Custom Event Gönderildi: Soru='\(qa.question)', Cevap='\(qa.answer)'")
                                }
                            }
                        } catch {
                            print("JSON parse hatası: \(error)")
                        }
                    }
                }
                
                if method == "close" {
                    self.close()
                }
            }
        }

    }

}


struct SurveyResult: Codable {
    let title: String
    let questions: [QuestionAnswer]
}

struct QuestionAnswer: Codable {
    let question: String
    let answer: String
}
