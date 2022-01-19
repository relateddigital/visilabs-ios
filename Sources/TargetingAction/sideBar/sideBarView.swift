//
//  sideBarView.swift
//  kulakcıkExample
//
//  Created by Orhun Akmil on 12.01.2022.
//

import UIKit

class sideBarView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var labelSuperView: UIView!
    @IBOutlet weak var arrowLabel: UILabel!
    @IBOutlet weak var titleLabelWidth: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // we need to adjust the frame of the subview to no longer match the size used
        // in the XIB file BUT the actual frame we got assinged from the superview
        self.bounds = self.frame
        roundCorners(corners: [.topLeft, .bottomLeft], radius: 45)

    }
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
