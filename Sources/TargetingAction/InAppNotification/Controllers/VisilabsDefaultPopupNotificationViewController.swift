//
//  VisilabsDefaultPopupNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import AVFoundation
import UIKit
// swiftlint:disable type_name
public final class VisilabsDefaultPopupNotificationViewController: UIViewController {
    weak var visilabsInAppNotification: VisilabsInAppNotification?
    var mailForm: MailSubscriptionViewModel?
    var scratchToWin: ScratchToWinModel?
    var player: AVPlayer?

    convenience init(visilabsInAppNotification: VisilabsInAppNotification? = nil,
                     emailForm: MailSubscriptionViewModel? = nil,
                     scratchToWin: ScratchToWinModel? = nil) {
        self.init()
        self.visilabsInAppNotification = visilabsInAppNotification
        mailForm = emailForm
        self.scratchToWin = scratchToWin

        if let image = visilabsInAppNotification?.image {
            if let imageGif = UIImage.gif(data: image) {
                self.image = imageGif
            } else {
                self.image = UIImage(data: image)
            }
        }

        if let secondImage = visilabsInAppNotification?.secondImage2 {
            self.secondImage = UIImage.gif(data: secondImage)
        }
    }

    public var standardView: VisilabsPopupDialogDefaultView {
        return view as! VisilabsPopupDialogDefaultView // swiftlint:disable:this force_cast
    }

    override public func loadView() {
        super.loadView()
        view = VisilabsPopupDialogDefaultView(frame: .zero,
                                              visilabsInAppNotification: visilabsInAppNotification,
                                              emailForm: mailForm,
                                              scratchTW: scratchToWin)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !inAppCurrentState.shared.isFirstPageOpened {
            player = standardView.imageView.addVideoPlayer(urlString: visilabsInAppNotification?.videourl ?? "")
        } else {
            if visilabsInAppNotification?.secondPopupVideourl1?.count ?? 0 > 0 {
                player = standardView.imageView.addVideoPlayer(urlString: visilabsInAppNotification?.secondPopupVideourl1 ?? "")
            }

            if visilabsInAppNotification?.secondPopupVideourl2?.count ?? 0 > 0 {
                player = standardView.secondImageView.addVideoPlayer(urlString: visilabsInAppNotification?.secondPopupVideourl2 ?? "")
            }
            inAppCurrentState.shared.isFirstPageOpened = false
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
}

public extension VisilabsDefaultPopupNotificationViewController {
    // MARK: - Setter / Getter

    // MARK: Content

    /// The dialog image
    var image: UIImage? {
        get { return standardView.imageView.image }
        set {
            standardView.imageView.image = newValue
            if visilabsInAppNotification?.videourl?.count ?? 0 > 0 {
                standardView.imageHeightConstraint?.constant = standardView.imageView.pv_heightForImageView(isVideoExist: true)
            } else {
                standardView.imageHeightConstraint?.constant = standardView.imageView.pv_heightForImageView(isVideoExist: false)
            }
        }
    }

    /// Second Image View
    var secondImage: UIImage? {
        get { return standardView.secondImageView.image }
        set {
            standardView.secondImageView.image = newValue
            if visilabsInAppNotification?.videourl?.count ?? 0 > 0 {
                standardView.secondImageHeight?.constant = standardView.imageView.pv_heightForImageView(isVideoExist: true)
            } else {
                standardView.secondImageHeight?.constant = standardView.imageView.pv_heightForImageView(isVideoExist: false)
            }
        }
    }

    // TO_DO: hideTitle ve hideMessage kaldırılabilir sanırım.
    func hideTitle() {
        standardView.titleLabel.isHidden = true
    }

    func hideMessage() {
        standardView.messageLabel.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if visilabsInAppNotification?.videourl?.count ?? 0 > 0 {
            standardView.imageHeightConstraint?.constant = standardView.imageView.pv_heightForImageView(isVideoExist: true)
        } else {
            standardView.imageHeightConstraint?.constant = standardView.imageView.pv_heightForImageView(isVideoExist: false)
        }

        if visilabsInAppNotification?.secondPopupVideourl1?.count ?? 0 > 0 && inAppCurrentState.shared.isFirstPageOpened {
            standardView.imageHeightConstraint?.constant = standardView.imageView.pv_heightForImageView(isVideoExist: true)
        } else if inAppCurrentState.shared.isFirstPageOpened {
            standardView.imageHeightConstraint?.constant = standardView.imageView.pv_heightForImageView(isVideoExist: false)
        }

        if visilabsInAppNotification?.secondPopupVideourl2?.count ?? 0 > 0 && inAppCurrentState.shared.isFirstPageOpened {
            standardView.secondImageHeight?.constant = standardView.secondImageView.pv_heightForImageView(isVideoExist: true)
        } else if inAppCurrentState.shared.isFirstPageOpened {
            standardView.secondImageHeight?.constant = standardView.secondImageView.pv_heightForImageView(isVideoExist: false)
        }
        if let _ = scratchToWin {
            standardView.sctw.centerX(to: standardView)
        }
    }
}
