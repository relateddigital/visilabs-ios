//
//  sideBarView.swift
//  kulakcıkExample
//
//  Created by Orhun Akmil on 12.01.2022.
//

import UIKit

class sideBarView: UIView {

    //grandView
    @IBOutlet weak var sideBarGrandView: UIView!
    @IBOutlet weak var sideBarGrandImageView: UIImageView!
    @IBOutlet weak var sideBarGrandContentImageView: UIImageView!
    
    //leftMini
    @IBOutlet weak var LeftSideBarMiniView: UIView!
    @IBOutlet weak var LeftSideBarMiniWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var LeftSideBarMiniVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var LeftSideBarMiniImageView: UIImageView!
    @IBOutlet weak var LeftSideBarMiniContentImageView: UIImageView!
    @IBOutlet weak var LeftTitleLabel: UILabel!
    
    //rightMini
    @IBOutlet weak var rightSideBarMiniView: UIView!
    @IBOutlet weak var rightSideBarMiniWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniImageView: UIImageView!
    @IBOutlet weak var rightSideBarMiniContentImageView: UIImageView!
    @IBOutlet weak var rightTitleLabel: UILabel!
    

    
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
