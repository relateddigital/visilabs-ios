//
//  sideBarView.swift
//  kulakcıkExample
//
//  Created by Orhun Akmil on 12.01.2022.
//

import UIKit

class drawerView: UIView {

    // grandView
    @IBOutlet weak var drawerGrandView: UIView!
    @IBOutlet weak var drawerGrandImageView: UIImageView!
    @IBOutlet weak var drawerGrandContentImageView: UIImageView!

    // leftMini
    @IBOutlet weak var leftDrawerMiniView: UIView!
    @IBOutlet weak var leftDrawerMiniWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftDrawerMiniVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftDrawerMiniImageView: UIImageView!
    @IBOutlet weak var leftDrawerMiniContentImageView: UIImageView!
    @IBOutlet weak var leftTitleLabel: UILabel!
    @IBOutlet weak var leftDrawerMiniContentImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftDrawerMiniContentImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftDrawerMiniContentImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftDrawerMiniContentImageTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftDrawerMiniArrow: UILabel!
    @IBOutlet weak var leftDrawerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftDrawerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftDrawerTitleLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftDrawerContentImageCenterXConstraint: NSLayoutConstraint!
    // rightMini
    @IBOutlet weak var rightDrawerMiniView: UIView!
    @IBOutlet weak var rightDrawerMiniWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightDrawerMiniImageView: UIImageView!
    @IBOutlet weak var rightDrawerMiniContentImageView: UIImageView!
    @IBOutlet weak var rightTitleLabel: UILabel!
    @IBOutlet weak var rightDrawerMiniContentImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightDrawerMiniContentImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightDrawerMiniContentImageTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightDrawerMiniContentImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightDrawerMiniArrow: UILabel!
    @IBOutlet weak var rightDrawerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightDrawerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightDrawerTitleLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightDrawerContentImageCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var closeButton: UIImageView!

    var drawerModel: DrawerViewModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.bounds = self.frame
        self.drawerGrandContentImageView.layer.zPosition = 1
        if drawerModel?.screenXcoordinate == .right && !(drawerModel?.isCircle ?? false) {
            self.leftDrawerMiniView.roundCorners(corners: [.topLeft, .bottomLeft], radius: drawerModel?.cornerRadius ?? 0.0)
        } else if drawerModel?.screenXcoordinate == .left && !(drawerModel?.isCircle ?? false) {
            self.rightDrawerMiniView.roundCorners(corners: [.topRight, .bottomRight], radius: drawerModel?.cornerRadius ?? 0.0)
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
