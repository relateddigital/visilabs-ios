//
//  ShakeToWinViewModel.swift
//  VisilabsIOS
//
//  Created by Said Alır on 6.04.2021.
//

import UIKit

struct ShakeToWinViewModel {
    var firstPage: ShakeToWinFirstPage
    var secondPage: ShakeToWinSecondPage
    var thirdPage: ShakeToWinThirdPage
}

struct ShakeToWinFirstPage {
    var image: UIImage?
    var title: String?
    var titleFont: UIFont?
    var titleColor: UIColor?
    var message: String?
    var messageColor: UIColor?
    var messageFont: UIFont?
    var buttonText: String?
    var buttonTextColor: UIColor
    var buttonFont: UIFont?
    var buttonBgColor: UIColor
    var backgroundColor: UIColor?
    var closeButtonColor: ButtonColor = .white
}

struct ShakeToWinSecondPage {
    var waitSeconds: Int?
    var videoURL: URL?
    var closeButtonColor: ButtonColor = .white
}

//For this page button will be coupon code
struct ShakeToWinThirdPage {
    var image: UIImage?
    var title: String?
    var titleFont: UIFont?
    var titleColor: UIColor?
    var message: String?
    var messageColor: UIColor?
    var messageFont: UIFont?
    var buttonText: String?
    var buttonTextColor: UIColor
    var buttonFont: UIFont?
    var buttonBgColor: UIColor
    var backgroundColor: UIColor?
    var closeButtonColor: ButtonColor = .white
}

