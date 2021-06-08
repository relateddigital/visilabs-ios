//
//  VisilabsCellConfigurer.swift
//  VisilabsIOS
//
//  Created by Egemen on 28.09.2020.
//

import UIKit

protocol VisilabsCellConfigurer: AnyObject {
    static var reuseIdentifier: String {get}
}

extension VisilabsCellConfigurer {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: VisilabsCellConfigurer {}
extension UITableViewCell: VisilabsCellConfigurer {}
