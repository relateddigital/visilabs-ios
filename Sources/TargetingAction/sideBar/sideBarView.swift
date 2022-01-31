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
    @IBOutlet weak var leftSideBarMiniArrow: UILabel!
    
    //rightMini
    @IBOutlet weak var rightSideBarMiniView: UIView!
    @IBOutlet weak var rightSideBarMiniWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniImageView: UIImageView!
    @IBOutlet weak var rightSideBarMiniContentImageView: UIImageView!
    @IBOutlet weak var rightTitleLabel: UILabel!
    @IBOutlet weak var rightSideBarMiniContentImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniContentImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniContentImageTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideBarMiniArrow: UILabel!

    
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
            self.leftSideBarMiniView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 10)
            self.leftSideBarMiniContentImageTopConstraint.constant = self.leftSideBarMiniContentImageTopConstraint.constant * 1.2
        } else if sideBarModel?.screenXcoordinate == .left && !(sideBarModel?.isCircle ?? false) {
            self.rightSideBarMiniView.roundCorners(corners: [.topRight, .bottomRight], radius: 10)
            self.rightSideBarMiniContentImageTopConstraint.constant = self.rightSideBarMiniContentImageTopConstraint.constant * 1.2
        } else if sideBarModel?.screenXcoordinate == .right && (sideBarModel?.isCircle ?? false) {
            if sideBarModel?.titleString.count ?? 0 > 0 {
                self.leftSideBarMiniContentImageView.isHidden = true
                self.leftSideBarMiniContentImageTopConstraint.constant = self.leftSideBarMiniContentImageTopConstraint.constant * 1.8
            } else {
                self.leftSideBarMiniContentImageTopConstraint.constant = self.leftSideBarMiniContentImageTopConstraint.constant * 2.66
                self.leftSideBarMiniContentImageBottomConstraint.constant = self.leftSideBarMiniContentImageBottomConstraint.constant * 2.66
                self.leftSideBarMiniContentImageLeadingConstraint.constant = 0
            }

        } else if sideBarModel?.screenXcoordinate == .left && (sideBarModel?.isCircle ?? false) {
            
            if sideBarModel?.titleString.count ?? 0 > 0 {
                self.rightSideBarMiniContentImageView.isHidden = true
                self.rightSideBarMiniContentImageTopConstraint.constant = self.rightSideBarMiniContentImageTopConstraint.constant * 1.8

            } else {
                self.rightSideBarMiniContentImageTopConstraint.constant = self.rightSideBarMiniContentImageTopConstraint.constant * 2.66
                self.rightSideBarMiniContentImageBottomConstraint.constant = self.rightSideBarMiniContentImageBottomConstraint.constant * 2.66
                self.rightSideBarMiniContentImageTrailingConstraint.constant = 0
            }
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
