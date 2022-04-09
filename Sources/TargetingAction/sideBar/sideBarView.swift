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
    @IBOutlet weak var leftSideBarMiniView: UIView!
    @IBOutlet weak var leftSideBarMiniWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideBarMiniVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideBarMiniImageView: UIImageView!
    @IBOutlet weak var leftSideBarMiniContentImageView: UIImageView!
    @IBOutlet weak var leftTitleLabel: UILabel!
    @IBOutlet weak var leftSideBarMiniContentImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideBarMiniContentImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideBarMiniContentImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideBarMiniContentImageTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideBarMiniArrow: UILabel!
    @IBOutlet weak var leftSideBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideBarTitleLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideBarContentImageCenterXConstraint: NSLayoutConstraint!
    //rightMini
    @IBOutlet weak var rightSideBarMiniView: UIView!
    @IBOutlet weak var rightSideBarMiniWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniImageView: UIImageView!
    @IBOutlet weak var rightSideBarMiniContentImageView: UIImageView!
    @IBOutlet weak var rightTitleLabel: UILabel!
    @IBOutlet weak var rightSideBarMiniContentImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniContentImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniContentImageTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniContentImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniArrow: UILabel!
    @IBOutlet weak var rightSideBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarTitleLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarContentImageCenterXConstraint: NSLayoutConstraint!

    
    var sideBarModel : SideBarViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.bounds = self.frame
        self.sideBarGrandContentImageView.layer.zPosition = 1
        if sideBarModel?.screenXcoordinate == .right && !(sideBarModel?.isCircle ?? false) {
            self.leftSideBarMiniView.roundCorners(corners: [.topLeft, .bottomLeft], radius: sideBarModel?.cornerRadius ?? 0.0)
        } else if sideBarModel?.screenXcoordinate == .left && !(sideBarModel?.isCircle ?? false) {
            self.rightSideBarMiniView.roundCorners(corners: [.topRight, .bottomRight], radius: sideBarModel?.cornerRadius ?? 0.0)
        } 
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
