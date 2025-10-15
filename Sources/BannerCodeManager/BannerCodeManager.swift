//
//  BannerCodeManager.swift
//  CleanyModal
//
//  Created by Orhun Akmil on 18.11.2024.
//

import UIKit

public class BannerCodeManager {
    static let shared = BannerCodeManager()
    private let giftRainCode = "giftRainCode"
    private let findToWinCode = "findToWinCode"
    private let jackpotCode = "jackpotCode"
    private let clawMachineCode = "ClawMachineCode"
    private let shakeToWinCode = "shakeToWinCode"
    private let giftBoxCode = "giftBoxCode"
    private let ChooseFavoriteGameCode = "ChooseFavoriteGameCode"
    private let CustomWebViewCode = "CustomWebViewCode"
    public var sdkTypeForBanner = "native"

    

    func setGiftRainCode(code:String) {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey:giftRainCode)
    }
    
    func getGiftRainCode() -> String {
        let defaults = UserDefaults.standard
        let string = defaults.string(forKey: giftRainCode) ?? ""
        defaults.set("", forKey:giftRainCode)
        return string
    }
    
    func setFindToWinCode(code:String) {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey:findToWinCode)
    }
    
    func getFindToWinCode() -> String {
        let defaults = UserDefaults.standard
        let string = defaults.string(forKey: findToWinCode) ?? ""
        defaults.set("", forKey:findToWinCode)
        return string
    }
    
    
    func setGiftBoxCode(code:String) {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey:giftBoxCode)
    }
    
    func getGiftBoxCode() -> String {
        let defaults = UserDefaults.standard
        let string = defaults.string(forKey: giftBoxCode) ?? ""
        defaults.set("", forKey:giftBoxCode)
        return string
    }
    
    
    func setJackpotCode(code:String) {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey:jackpotCode)
    }
    
    func getJackpotCode() -> String {
        let defaults = UserDefaults.standard
        let string = defaults.string(forKey: jackpotCode) ?? ""
        defaults.set("", forKey:jackpotCode)
        return string
    }
        
    func setClawMachineCode(code:String) {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey:clawMachineCode)
    }
    
    func getClawMachineCode() -> String {
        let defaults = UserDefaults.standard
        let string = defaults.string(forKey: clawMachineCode) ?? ""
        defaults.set("", forKey:clawMachineCode)
        return string
    }
    
    func setShakeToWinCode(code:String) {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey:shakeToWinCode)
    }
    
    func getShakeToWinCode() -> String {
        let defaults = UserDefaults.standard
        let string = defaults.string(forKey: shakeToWinCode) ?? ""
        defaults.set("", forKey:shakeToWinCode)
        return string
    }
    
    func setChooseFavoriteGameCode(code:String) {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey:ChooseFavoriteGameCode)
    }
    
    func getChooseFavoriteGameCode() -> String {
        let defaults = UserDefaults.standard
        let string = defaults.string(forKey: ChooseFavoriteGameCode) ?? ""
        defaults.set("", forKey:ChooseFavoriteGameCode)
        return string
    }
    
    
    func setCustomWebViewCode(code:String) {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey:CustomWebViewCode)
    }
    
    func getCustomWebViewCode() -> String {
        let defaults = UserDefaults.standard
        let string = defaults.string(forKey: CustomWebViewCode) ?? ""
        defaults.set("", forKey:CustomWebViewCode)
        return string
    }
}
