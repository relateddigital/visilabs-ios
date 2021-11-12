//
//  VisilabsProductStatNotifierView.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 11.11.2021.
//

import UIKit

class VisilabsProductStatNotifierView: UIView {
    
    var productStatNotifier: VisilabsProductStatNotifierViewModel
    var titleLabel: UILabel!
    var closeButton: UIButton!
    
    init(frame: CGRect, productStatNotifier: VisilabsProductStatNotifierViewModel) {
        self.productStatNotifier = productStatNotifier
        super.init(frame: frame)
        setupTitle()
        setCloseButton()
        layoutContent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTitle() {
        titleLabel = UILabel()
        titleLabel.attributedText = productStatNotifier.attributedString
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
    }
    
    private func setCloseButton() {
        closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.contentHorizontalAlignment = .right
        closeButton.clipsToBounds = false
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.setTitle("×", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 35.0, weight: .regular)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        closeButton.setTitleColor(productStatNotifier.closeButtonColor.lowercased() == "white" ? UIColor.white : UIColor.black , for: .normal)
        addSubview(closeButton)
    }
    
    private func layoutContent() {
        self.backgroundColor = UIColor(hex: productStatNotifier.bgcolor)
        titleLabel.leading(to: self, offset: 40, relation: .equal, priority: .required)
        titleLabel.trailing(to: self, offset: -40, relation: .equal, priority: .required)
        titleLabel.centerX(to: self,priority: .required)
        if productStatNotifier.showclosebtn {
            closeButton.top(to: self, offset: -5.0)
            closeButton.trailing(to: self, offset: -10.0)
        } else {
            closeButton.isHidden = true
        }
        self.window?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
        self.window?.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        if titleLabel.text.isNilOrWhiteSpace {
            titleLabel.height(0)
            titleLabel.isHidden = true
        } else {
            titleLabel.height(titleLabel.intrinsicContentSize.height + 20 )
        }
        super.layoutSubviews()
    }
}
