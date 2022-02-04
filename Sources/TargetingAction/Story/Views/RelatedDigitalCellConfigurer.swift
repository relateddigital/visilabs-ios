//
//  VisilabsCellConfigurer.swift
//  VisilabsIOS
//
//  Created by Egemen on 28.09.2020.
//

import UIKit

protocol RelatedDigitalCellConfigurer: AnyObject {
    static var reuseIdentifier: String {get}
}

extension RelatedDigitalCellConfigurer {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: RelatedDigitalCellConfigurer {}
extension UITableViewCell: RelatedDigitalCellConfigurer {}
