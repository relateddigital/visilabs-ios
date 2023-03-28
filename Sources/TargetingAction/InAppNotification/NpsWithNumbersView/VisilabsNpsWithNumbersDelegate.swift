//
//  VisilabsNpsWithNumbersDelegate.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 28.03.2023.
//

import Foundation


@objc
public protocol VisilabsNpsWithNumbersDelegate: NSObjectProtocol {
    @objc
    func npsItemClicked(npsLink: String?)
}

