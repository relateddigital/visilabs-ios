//
//  TargetingActionViewModel.swift
//  VisilabsIOS
//
//  Created by Egemen Gulkilik on 5.03.2021.
//

import Foundation

public enum TargetingActionType: String, Codable {
    case mailSubscriptionForm = "MailSubscriptionForm"
    case spinToWin = "SpinToWin"
}

public protocol TargetingActionViewModel {
    var targetingActionType: TargetingActionType  { get set }
}
