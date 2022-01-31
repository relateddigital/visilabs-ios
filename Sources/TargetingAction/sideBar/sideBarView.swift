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
    @IBOutlet weak var leftSideBarMiniTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideBarMiniBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideBarMiniLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideBarMiniImageArrow: UILabel!
    
    //rightMini
    @IBOutlet weak var rightSideBarMiniView: UIView!
    @IBOutlet weak var rightSideBarMiniWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniImageView: UIImageView!
    @IBOutlet weak var rightSideBarMiniContentImageView: UIImageView!
    @IBOutlet weak var rightTitleLabel: UILabel!
    @IBOutlet weak var rightSideBarMiniTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniImageArrow: UILabel!

    
    var sideBarModel : SideBarModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.bounds = self.frame
        if sideBarModel?.screenXcoordinate == .right && !(sideBarModel?.isCircle ?? false) {
            self.LeftSideBarMiniView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 10)
        } else if sideBarModel?.screenXcoordinate == .left && !(sideBarModel?.isCircle ?? false) {
            self.rightSideBarMiniView.roundCorners(corners: [.topRight, .bottomRight], radius: 10)
        } else if sideBarModel?.screenXcoordinate == .right && (sideBarModel?.isCircle ?? false) {
            self.leftSideBarMiniTopConstraint.constant = self.leftSideBarMiniTopConstraint.constant * 2.66
            self.leftSideBarMiniBottomConstraint.constant = self.leftSideBarMiniBottomConstraint.constant * 2.66
            self.leftSideBarMiniLeadingConstraint.constant = 0
        } else if sideBarModel?.screenXcoordinate == .left && (sideBarModel?.isCircle ?? false) {
            self.rightSideBarMiniTopConstraint.constant = self.rightSideBarMiniTopConstraint.constant * 2.66
            self.rightSideBarMiniBottomConstraint.constant = self.rightSideBarMiniBottomConstraint.constant * 2.66
            self.rightSideBarMiniTrailingConstraint.constant = 0
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
