//
//  ScratchToWinModel.swift
//  VisilabsIOS
//
//  Created by Said Alır on 04.02.2021.
//

import Foundation
//swiftlint:disable type_body_length
public class ScratchToWinModel: TargetingActionViewModel {

    public var targetingActionType: TargetingActionType = .scratchToWin
    let actId: Int
    let hasMailForm: Bool
    let scratchColor: UIColor?
    var waitingTime: Int = 0
    let promocode: String?
    let sendMail: Bool?
    let copyButtonText: String?
    let imageUrlString: String?
    let title: String?
    let message: String?
    let placeholder: String?
    let mailButtonText: String?
    let consentText: ParsedPermissionString?
    let permitText: ParsedPermissionString?
    let invalidEmailMessage: String?
    let successMessage: String?
    let checkConsentText: String?
    let titleTextColor: UIColor?
    let titleFont: UIFont?
    let messageTextColor: UIColor?
    let messageFont: UIFont?
    let mailButtonColor: UIColor?
    let mailButtonTextColor: UIColor?
    let mailButtonFont: UIFont?
    let promoTextColor: UIColor?
    let promoFont: UIFont?
    let copyButtonColor: UIColor?
    let copyButtonTextColor: UIColor?
    let copyButtonTextFont: UIFont?
    let emailPermitTextFont: UIFont?
    let consentTextFont: UIFont?
    var closeButtonColor: UIColor = .black
    let backgroundColor: UIColor?
    let consentUrl: URL?
    let permitUrl: URL?
    
    var imageUrl: URL?
    lazy var image: Data? = {
        var data: Data?
        if let iUrl = self.imageUrl {
            do {
                data = try Data(contentsOf: iUrl, options: [.mappedIfSafe])
            } catch {
                VisilabsLogger.error("image failed to load from url \(iUrl)")
            }
        }
        return data
    }()

    var messageTitleFont: UIFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2),
                                          size: CGFloat(12))
    var messageBodyFont: UIFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body),
                                         size: CGFloat(8))
    var buttonTextFont: UIFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body),
                                        size: CGFloat(8))

    public init(type: VisilabsInAppNotificationType,
                actid: Int,
                hasMailForm: Bool,
                scratchColor: String,
                waitingTime: Int,
                promocode: String,
                sendMail: Bool,
                copyButtonText: String,
                imageUrlString: String,
                title: String,
                message: String,
                mailPlaceholder: String?,
                mailButtonText: String?,
                consentText: String?,
                invalidEmailMsg: String?,
                successMessage: String?,
                emailPermitText: String?,
                checkConsentMessage: String?,
                titleTextColor: String?,
                titleFontFamily: String?,
                titleTextSize: String?,
                messageTextColor: String?,
                messageFontFamily: String?,
                messageTextSize: String?,
                mailButtonColor: String?,
                mailButtonTextColor: String?,
                mailButtonFontFamily: String?,
                mailButtonTextSize: String?,
                promocodeTextColor: String?,
                promocodeTextFamily: String?,
                promocodeTextSize: String?,
                copyButtonColor: String?,
                copyButtonTextColor: String?,
                copyButtonFontFamily: String?,
                copyButtonTextSize: String?,
                emailPermitTextSize: String?,
                emailPermitUrl: String?,
                consentTextSize: String?,
                consentUrl: String?,
                closeButtonColor: String?,
                backgroundColor: String?) {

        if let cBColor = closeButtonColor {
            if cBColor.lowercased() == "white" {
                self.closeButtonColor = UIColor.white
            } else if cBColor.lowercased() == "black" {
                self.closeButtonColor = UIColor.black
            } else {
                self.closeButtonColor = UIColor(hex: cBColor) ?? .black
            }
        }
        self.actId = actid
        self.hasMailForm = hasMailForm
        self.scratchColor = UIColor(hex: scratchColor)
        self.waitingTime = waitingTime
        self.promocode = promocode
        self.sendMail = sendMail
        self.copyButtonText = copyButtonText
        self.imageUrlString = imageUrlString
        self.title = title
        self.message = message
        self.placeholder = mailPlaceholder
        self.mailButtonText = mailButtonText
        self.consentText = consentText?.parsePermissionText()
        self.permitText = emailPermitText?.parsePermissionText()
        self.invalidEmailMessage = invalidEmailMsg
        self.successMessage = successMessage
        self.checkConsentText = checkConsentMessage
        self.titleTextColor = UIColor(hex: titleTextColor)
        self.messageTextColor = UIColor(hex: messageTextColor)
        self.mailButtonTextColor = UIColor(hex: mailButtonTextColor)
        self.mailButtonColor = UIColor(hex: mailButtonColor)
        self.promoTextColor = UIColor(hex: promocodeTextColor)
        self.copyButtonTextColor = UIColor(hex: copyButtonTextColor)
        self.copyButtonColor = UIColor(hex: copyButtonColor)
        self.backgroundColor = UIColor(hex: backgroundColor)
        self.consentUrl = URL(string: consentUrl ?? "")
        self.permitUrl = URL(string: emailPermitUrl ?? "")
        if !self.imageUrlString.isNilOrWhiteSpace {
            self.imageUrl = ScratchToWinModel.getImageUrl(self.imageUrlString!, type: .full)
        }
        
        titleFont = VisilabsInAppNotification.getFont(fontFamily: titleFontFamily,
                                                                  fontSize: titleTextSize,
                                                                  style: .title2)
        messageFont = VisilabsInAppNotification.getFont(fontFamily: messageFontFamily,
                                                        fontSize: messageTextSize,
                                                        style: .body)
        mailButtonFont = VisilabsInAppNotification.getFont(fontFamily: mailButtonFontFamily,
                                                           fontSize: mailButtonTextSize,
                                                           style: .title2)
        promoFont = VisilabsInAppNotification.getFont(fontFamily: promocodeTextFamily,
                                                      fontSize: promocodeTextSize,
                                                      style: .title2)
        copyButtonTextFont = VisilabsInAppNotification.getFont(fontFamily: copyButtonFontFamily,
                                                              fontSize: copyButtonTextSize,
                                                              style: .title2)
        emailPermitTextFont = UIFont.systemFont(ofSize: CGFloat(6 + (Int(emailPermitTextSize ?? "0") ?? 0)))
        consentTextFont = UIFont.systemFont(ofSize: CGFloat(6 + (Int(consentTextSize ?? "0") ?? 0)))
        
        
    }

    static func getFont(fontFamily: String?, fontSize: String?, style: UIFont.TextStyle) -> UIFont {
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
        }
        return finalFont
    }

    private static func getImageUrl(_ imageUrlString: String, type: VisilabsInAppNotificationType) -> URL? {
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
}
