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
    case scratchToWin = "ScratchToWin"
    case productStatNotifier = "ProductStatNotifier"
    case drawer = "Drawer"
}

public protocol TargetingActionViewModel {
    var targetingActionType: TargetingActionType { get set }
}
