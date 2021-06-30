//
//  VisilabsInAppNotificationType.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.07.2020.
//

import Foundation

public enum VisilabsInAppNotificationType: String, CaseIterable {
    case mini
    case full
    case imageTextButton = "image_text_button"
    case fullImage = "full_image"
    case nps
    case imageButton = "image_button"
    case smileRating = "smile_rating"
    case emailForm = "mailsubsform"
    case alert
    case npsWithNumbers = "nps_with_numbers"
    case scratchToWin
    case secondNps = "nps_with_secondpopup"
    case carousel = "carousel"
    case imageButtonImage
    case spintowin
    case feedbackForm
}

public enum VisilabsSecondPopupType: String, CaseIterable {
    case imageTextButton = "image_text_button"
    case imageButtonImage = "image_text_button_image"
    case feedback = "feedback_form"
}
