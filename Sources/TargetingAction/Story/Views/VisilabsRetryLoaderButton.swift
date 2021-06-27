//
//  VisilabsRetryLoaderButton.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.10.2020.
//

import Foundation
import UIKit

protocol RetryBtnDelegate: AnyObject {
    func retryButtonTapped()
}

public class VisilabsRetryLoaderButton: UIButton {
    var contentURL: String?
    weak var delegate: RetryBtnDelegate?
    convenience init(withURL url: String) {
        self.init()
        self.backgroundColor = .white
        self.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        if let closeButtonImage = VisilabsHelper.getUIImage(named: "VisilabsRetryButton") {
            self.setImage(closeButtonImage, for: .normal)
        }
        self.addTarget(self, action: #selector(didTapRetryBtn), for: .touchUpInside)
        self.contentURL = url
        self.tag = 100
    }
    @objc func didTapRetryBtn() {
        delegate?.retryButtonTapped()
    }
}

extension UIView {
    func removeRetryButton() {
        self.subviews.forEach({view in
            if view.tag == 100 {view.removeFromSuperview()}
        })
    }

}
