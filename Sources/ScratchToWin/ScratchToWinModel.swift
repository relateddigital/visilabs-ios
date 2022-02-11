//
//  ScratchToWinModel.swift
//  VisilabsIOS
//
//  Created by Said Alır on 04.02.2021.
//

import UIKit
// swiftlint:disable type_body_length
public class ScratchToWinModel: TargetingActionViewModel {

    public var targetingActionType: TargetingActionType = .scratchToWin
    let actId: Int
    let auth: String
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
    let report: TargetingActionReport?
    let contentTitleCustomFontFamilyIos : String?
    let contentBodyCustomFontFamilyIos : String?
    let buttonCustomFontFamilyIos : String?
    let promocodeCustomFontFamilyIos : String?
    let copybuttonCustomFontFamilyIos : String?

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
                auth: String,
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
                backgroundColor: String?,
                report: TargetingActionReport?,
                contentTitleCustomFontFamilyIos:String?,
                contentBodyCustomFontFamilyIos:String?,
                buttonCustomFontFamilyIos : String?,
                promocodeCustomFontFamilyIos : String?,
                copybuttonCustomFontFamilyIos : String?) {

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
        self.auth = auth
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
        self.report = report
        self.contentTitleCustomFontFamilyIos = contentTitleCustomFontFamilyIos
        self.contentBodyCustomFontFamilyIos = contentBodyCustomFontFamilyIos
        self.buttonCustomFontFamilyIos = buttonCustomFontFamilyIos
        self.promocodeCustomFontFamilyIos = promocodeCustomFontFamilyIos
        self.copybuttonCustomFontFamilyIos = copybuttonCustomFontFamilyIos

        titleFont = VisilabsHelper.getFont(fontFamily: titleFontFamily,
                                                                  fontSize: titleTextSize,
                                                                  style: .title2,customFont: contentTitleCustomFontFamilyIos)
        messageFont = VisilabsHelper.getFont(fontFamily: messageFontFamily,
                                                        fontSize: messageTextSize,
                                                        style: .body,customFont: contentBodyCustomFontFamilyIos)
        mailButtonFont = VisilabsHelper.getFont(fontFamily: mailButtonFontFamily,
                                                           fontSize: mailButtonTextSize,
                                                           style: .title2,customFont: buttonCustomFontFamilyIos)
        promoFont = VisilabsHelper.getFont(fontFamily: promocodeTextFamily,
                                                      fontSize: promocodeTextSize,
                                                      style: .title2,customFont: promocodeCustomFontFamilyIos)
        copyButtonTextFont = VisilabsHelper.getFont(fontFamily: copyButtonFontFamily,
                                                              fontSize: copyButtonTextSize,
                                                              style: .title2,customFont: copybuttonCustomFontFamilyIos)
        emailPermitTextFont = UIFont.systemFont(ofSize: CGFloat(8 + (Int(emailPermitTextSize ?? "0") ?? 0)))
        consentTextFont = UIFont.systemFont(ofSize: CGFloat(8 + (Int(consentTextSize ?? "0") ?? 0)))

    }

    private static func getImageUrl(_ imageUrlString: String, type: VisilabsInAppNotificationType) -> URL? {
        var imageUrl: URL?
        if let escapedImageUrlString = imageUrlString.addingPercentEncoding(withAllowedCharacters:
                                                                     NSCharacterSet.urlQueryAllowed),
           let imageUrlComponents = URLComponents(string: escapedImageUrlString),
           let imageUrlParsed = imageUrlComponents.url {
            imageUrl = imageUrlParsed
        }
        return imageUrl
    }
}
