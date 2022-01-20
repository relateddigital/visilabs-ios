//
//  sideBarView.swift
//  kulakcıkExample
//
//  Created by Orhun Akmil on 12.01.2022.
//

import UIKit

class sideBarView: UIView {

    
    @IBOutlet weak var sideBarMiniWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideBarMiniImageView: UIImageView!
    @IBOutlet weak var sideBarMiniView: UIView!
    @IBOutlet weak var sideBarMiniContentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sideBarGrandView: UIView!
    @IBOutlet weak var sideBarGrandImageView: UIImageView!
    @IBOutlet weak var sideBarGrandContentImageView: UIImageView!
    @IBOutlet weak var sideBarMiniVerticalConstraint: NSLayoutConstraint!
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        

    }

    override func layoutSubviews() {
        super.layoutSubviews()

       
        self.bounds = self.frame        
        
//        roundCorners(corners: [.topLeft, .bottomLeft], radius: 90)

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
