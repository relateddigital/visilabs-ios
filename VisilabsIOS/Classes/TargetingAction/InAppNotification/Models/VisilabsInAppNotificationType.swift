//
//  VisilabsInAppNotificationType.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.07.2020.
//

//Spin to win is not a in-app however it should be in this list
//It must be at the end of the list
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
    case carousel = "carousel"
    case spintowin
}
