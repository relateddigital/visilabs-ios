//
//  VisilabsCarouselCollectionCell.swift
//  CleanyModal
//
//  Created by Umut Can Alparslan on 28.01.2022.
//

import UIKit

class VisilabsCarouselCollectionCell: UICollectionViewCell {
    
    // MARK: - Data
    
    static var id: String { return "VisilabsCarouselCollectionCell" }

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        if #available(iOS 11.0, *) {
            insetsLayoutMarginsFromSafeArea = false
            contentView.insetsLayoutMarginsFromSafeArea = false
        }
        preservesSuperviewLayoutMargins = false
        contentView.preservesSuperviewLayoutMargins = false
        contentView.layoutMargins = .zero
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    // MARK: - Actions
    
    func setViewController(_ controller: UIViewController) {
        guard let view = controller.view else { return }
        let superView = contentView
        superView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: superView.topAnchor),
            view.leftAnchor.constraint(equalTo: superView.leftAnchor),
            view.rightAnchor.constraint(equalTo: superView.rightAnchor),
            view.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
        ])
    }
}



