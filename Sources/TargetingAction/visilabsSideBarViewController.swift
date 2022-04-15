//
//  VisilabsSideBar.swift
//  VisilabsIOS
//
//  Created by Orhun Akmil on 13.01.2022.
//

import Foundation
import UIKit


class visilabsSideBarViewController : VisilabsBaseNotificationViewController {
    
    
    var position: CGPoint?
    var model = SideBarViewModel()
    var globSidebarView : sideBarView?
    var sideBarOpen:Bool = false
    var sideBarFirstPosition:CGPoint?
    var titleLenght = 12
    var shouldDismissed = false
    
    
    public init(model:SideBarServiceModel?) {
        super.init(nibName: nil, bundle: nil)
        self.model = visilabsSideBarViewControllerModel().mapServiceModelToNeededModel(serviceModel: model)
        let sidebarView : sideBarView = UIView.fromNib()
        sidebarView.sideBarModel = self.model
        globSidebarView = sidebarView
        addTapGestureToSideBarMiniView()
        addTapGestureToImageOfGranSideBar()
        if self.model.isCircle {
            self.globSidebarView!.isHidden = true
            self.model.miniSideBarWidth = self.model.miniSideBarWidthForCircle / 2
        }
        self.view = sidebarView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sideBarFirstPosition = self.window?.layer.position
        if model.isCircle {
            configureCircleSideBar()
        }
        initializeData()
        
    }
    
    func initializeData() {
        
        if model.screenXcoordinate == .right {
            globSidebarView?.leftSideBarMiniContentImageView.image = model.miniSidebarContentImage
            globSidebarView?.leftTitleLabel.text = model.titleString
            globSidebarView?.leftTitleLabel.font = model.miniSideBarTextFont
            globSidebarView?.leftTitleLabel.textColor = model.miniSideBarTextColor
            globSidebarView?.leftSideBarMiniImageView.image = model.miniSideBarBackgroundImage
            globSidebarView?.leftSideBarMiniImageView.backgroundColor = model.miniSideBarBackgroundColor
            globSidebarView?.leftSideBarMiniArrow.textColor = model.arrowColor
        } else {
            globSidebarView?.rightSideBarMiniContentImageView.image = model.miniSidebarContentImage
            globSidebarView?.rightTitleLabel.text = model.titleString
            globSidebarView?.rightTitleLabel.font = model.miniSideBarTextFont
            globSidebarView?.rightTitleLabel.textColor = model.miniSideBarTextColor
            globSidebarView?.rightSideBarMiniImageView.image = model.miniSideBarBackgroundImage
            globSidebarView?.rightSideBarMiniImageView.backgroundColor = model.miniSideBarBackgroundColor
            globSidebarView?.rightSideBarMiniArrow.textColor = model.arrowColor
        }
        globSidebarView?.sideBarGrandImageView.image = model.sideBarBackgroundImage
        globSidebarView?.sideBarGrandImageView.backgroundColor = model.sideBarBackgroundColor
        globSidebarView?.sideBarGrandContentImageView.image = model.sideBarContentImage

    }
    
    func createDummyModel()  -> SideBarViewModel {
        var model = SideBarViewModel()
        
        model.titleString = "DenemeDeneme"
        model.isCircle = true
        model.screenYcoordinate = .middle
        model.screenXcoordinate = .right
        model.labelType = .downToUp

        return model
    }
        
    func configureCircleSideBar() {

        if model.screenXcoordinate == .right {
            
            self.globSidebarView?.leftSideBarMiniView.layer.zPosition = -1
            self.globSidebarView?.leftSideBarWidthConstraint.constant = self.model.miniSideBarWidthForCircle
            self.globSidebarView?.leftSideBarMiniView.layer.cornerRadius = self.model.miniSideBarWidthForCircle / 2
            self.globSidebarView?.leftSideBarTrailingConstraint.constant = -((self.globSidebarView?.leftSideBarWidthConstraint.constant)! / 2)
            self.globSidebarView?.leftSideBarTitleLabelCenterXConstraint.constant =  self.model.xCoordPaddingConstant
            self.globSidebarView?.leftSideBarContentImageCenterXConstraint.constant =  2
    
            if self.model.titleString.count > 0 {
                self.globSidebarView?.leftSideBarMiniContentImageView.isHidden = true
                self.globSidebarView?.leftSideBarMiniContentImageTopConstraint.constant *= 1.6
                self.globSidebarView?.leftSideBarMiniContentImageBottomConstraint.constant *= 3
                self.globSidebarView?.leftSideBarMiniContentImageLeadingConstraint.constant = 20
                self.globSidebarView?.leftSideBarMiniContentImageTrailingConstraint.constant += (self.globSidebarView?.sideBarModel!.miniSideBarWidth)!
            } else {
                self.globSidebarView?.leftSideBarMiniContentImageTopConstraint.constant *=  3
                self.globSidebarView?.leftSideBarMiniContentImageBottomConstraint.constant *= 3
                self.globSidebarView?.leftSideBarMiniContentImageLeadingConstraint.constant = 20
                self.globSidebarView?.leftSideBarMiniContentImageTrailingConstraint.constant += (self.globSidebarView?.sideBarModel!.miniSideBarWidth)!
            }
            self.globSidebarView!.leftSideBarMiniView.clipsToBounds = true
            //self.globSidebarView?.leftSideBarMiniImageView.image = self.model.dataImage
            self.globSidebarView!.isHidden = false
        } else if model.screenXcoordinate == .left {

            self.globSidebarView?.rightSideBarMiniView.layer.zPosition = -1
            self.globSidebarView?.rightSideBarWidthConstraint.constant = self.model.miniSideBarWidthForCircle
            self.globSidebarView?.rightSideBarMiniView.layer.cornerRadius = self.model.miniSideBarWidthForCircle / 2
            self.globSidebarView?.rightSideBarTrailingConstraint.constant = -((self.globSidebarView?.rightSideBarWidthConstraint.constant)! / 2)
            self.globSidebarView?.rightSideBarTitleLabelCenterXConstraint.constant =  -(self.model.xCoordPaddingConstant)
            self.globSidebarView?.rightSideBarContentImageCenterXConstraint.constant = -2
    
            if self.model.titleString.count > 0 {
                self.globSidebarView?.rightSideBarMiniContentImageView.isHidden = true
                self.globSidebarView?.rightSideBarMiniContentImageTopConstraint.constant *= 1.6
                self.globSidebarView?.rightSideBarMiniContentImageBottomConstraint.constant *= 3
                self.globSidebarView?.rightSideBarMiniContentImageTrailingConstraint.constant = 20
                self.globSidebarView?.rightSideBarMiniContentImageLeadingConstraint.constant += (self.globSidebarView?.sideBarModel!.miniSideBarWidth)!
            } else {
                self.globSidebarView?.rightSideBarMiniContentImageTopConstraint.constant *=  3
                self.globSidebarView?.rightSideBarMiniContentImageBottomConstraint.constant *= 3
                self.globSidebarView?.rightSideBarMiniContentImageTrailingConstraint.constant = 20
                self.globSidebarView?.rightSideBarMiniContentImageLeadingConstraint.constant += (self.globSidebarView?.sideBarModel!.miniSideBarWidth)!
            }
            self.globSidebarView!.rightSideBarMiniView.clipsToBounds = true
            //self.globSidebarView?.rightSideBarMiniImageView.image = self.model.dataImage
            self.globSidebarView!.isHidden = false
        }
    }
    
    func configureStandartView(sideBar:sideBarView) {
        
        //ekranın sağında mı solunda mı
        if self.model.screenXcoordinate == .right {
            globSidebarView?.rightSideBarMiniWidthConstraint.constant = 0
            globSidebarView?.rightSideBarMiniView.isHidden = true
        } else if self.model.screenXcoordinate == .left {
            globSidebarView?.leftSideBarMiniWidthConstraint.constant = 0
            globSidebarView?.leftSideBarMiniView.isHidden = true
        }
        
        //label tipi
        if self.model.labelType == .downToUp  && self.model.screenXcoordinate == .right {
            globSidebarView!.leftTitleLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        } else if self.model.labelType == .upToDown  && self.model.screenXcoordinate == .right {
            globSidebarView!.leftTitleLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        } else if self.model.labelType == .downToUp  && self.model.screenXcoordinate == .left {
            globSidebarView!.rightTitleLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        } else if self.model.labelType == .upToDown  && self.model.screenXcoordinate == .left {
            globSidebarView!.rightTitleLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        }
        
        if self.model.screenXcoordinate == .right {
            if model.titleString.count > titleLenght {
                while model.titleString.count != titleLenght {
                    model.titleString.removeLast()
                }
            }
            globSidebarView!.leftTitleLabel.text = model.titleString
            //modele göre diğer elementlerin assign edilmesi gerek left mini viewa
        } else if self.model.screenXcoordinate == .left {
            if model.titleString.count > titleLenght {
                while model.titleString.count != titleLenght {
                    model.titleString.removeLast()
                }
            }
            globSidebarView!.rightTitleLabel.text = model.titleString
            //modele göre diğer elementlerin assign edilmesi gerek right mini viewa
        }
        
        if !self.model.isCircle {
            globSidebarView?.rightSideBarMiniContentImageView.isHidden = true
            globSidebarView?.leftSideBarMiniContentImageView.isHidden = true
        }
        
        if self.model.screenXcoordinate == .right && !(self.model.isCircle ) {
            self.globSidebarView?.leftSideBarMiniContentImageTopConstraint.constant *= 1.2
        } else if self.model.screenXcoordinate == .left && !(self.model.isCircle ) {
            self.globSidebarView?.rightSideBarMiniContentImageTopConstraint.constant *= 1.2
        }

    }
    
    @objc func imageClicked(_ sender: UITapGestureRecognizer? = nil) {
        shouldDismissed = true
        if let url = URL(string: self.model.linkToGo ?? "") {
            delegate?.notificationShouldDismiss(controller: self, callToActionURL: url, shouldTrack: false, additionalTrackingProperties: nil)
        }
    }

    @objc func viewClicked(_ sender: UITapGestureRecognizer? = nil) {
        
        UIView.animate(withDuration: 0.5, animations: { [self] in
            if sideBarOpen {
                self.window?.layer.position = sideBarFirstPosition!
                if model.screenXcoordinate == .right {
                    globSidebarView?.leftSideBarMiniArrow.text = "<"
                } else if model.screenXcoordinate == .left {
                    globSidebarView?.rightSideBarMiniArrow.text = ">"
                }
            } else {
                if model.screenXcoordinate == .right {
                    if let winPos = self.window?.layer.position {
                        self.window?.layer.position = CGPoint(x: winPos.x - globSidebarView!.width + self.model.miniSideBarWidth  , y: winPos.y)
                    }
                    globSidebarView?.leftSideBarMiniArrow.text = ">"
                } else if model.screenXcoordinate == .left {
                    if let winPos = self.window?.layer.position {
                        self.window?.layer.position = CGPoint(x: winPos.x + globSidebarView!.width - self.model.miniSideBarWidth  , y: winPos.y)
                    }
                    globSidebarView?.rightSideBarMiniArrow.text = "<"
                }
            }
        })
        sideBarOpen = !sideBarOpen
    }
    
    
    override func show(animated: Bool) {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else {
            return
        }
        var bounds: CGRect
        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication
                           .connectedScenes
                           .filter { $0.activationState == .foregroundActive }
                           .first
            guard let scene = windowScene as? UIWindowScene else { return }
            bounds = scene.coordinateSpace.bounds
        } else {
            bounds = UIScreen.main.bounds
        }
        let SideBarframeWidth = bounds.size.width / 2
        
        var frameY = Double()

        if self.model.screenYcoordinate == .top {
            frameY = bounds.size.height/2 - self.model.sideBarHeight * 1.5
        } else if self.model.screenYcoordinate == .bottom {
            frameY = bounds.size.height - self.model.sideBarHeight * 1.5
        } else if self.model.screenYcoordinate == .middle {
            frameY = bounds.size.height / 2 - self.model.sideBarHeight / 2
        }

        var frame = CGRect()
        
        if self.model.screenXcoordinate == .right {
            frame = CGRect(origin: CGPoint(x: bounds.maxX-self.model.miniSideBarWidth, y: CGFloat(frameY)), size: CGSize(width: SideBarframeWidth, height: CGFloat(self.model.sideBarHeight)))
        } else if self.model.screenXcoordinate == .left {
            frame = CGRect(origin: CGPoint(x: bounds.minX-SideBarframeWidth+model.miniSideBarWidth, y: CGFloat(frameY)), size: CGSize(width: SideBarframeWidth, height: CGFloat(self.model.sideBarHeight)))
        }
        
        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first
            if let windowScene = windowScene as? UIWindowScene {
                window = UIWindow(frame: frame)
                window?.windowScene = windowScene
            }
        } else {
            window = UIWindow(frame: frame)
        }
        if let window = window {
            window.windowLevel = UIWindow.Level.alert
            window.clipsToBounds = false // true
            window.rootViewController = self
            window.isHidden = false
        }
        self.position = self.window?.layer.position
        configureStandartView(sideBar: view as! sideBarView)
    }
    
    
    fileprivate func setWindowAndAddAnimation(_ animated: Bool) {
        if let window = window {
            window.windowLevel = UIWindow.Level.alert
            window.clipsToBounds = true
            window.rootViewController = self
            window.isHidden = false
        }

        let duration = animated ? 0.1 : 0
        UIView.animate(withDuration: duration, animations: {
            self.window?.frame.origin.y -= 0
        }, completion: { _ in
            self.position = self.window?.layer.position
        })
    }
    
    
    override func hide(animated: Bool, completion: @escaping () -> Void) {
        if shouldDismissed {
            self.window?.isHidden = true
            self.window?.removeFromSuperview()
            self.window = nil
            completion()
        }
    }
    
    func addTapGestureToSideBarMiniView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewClicked(_:)))
        if self.model.screenXcoordinate == .right {
            globSidebarView?.leftSideBarMiniView.addGestureRecognizer(tap)
        } else if self.model.screenXcoordinate == .left {
            globSidebarView?.rightSideBarMiniView.addGestureRecognizer(tap)
        }
    }
    
    
    func addTapGestureToImageOfGranSideBar() {
        globSidebarView?.sideBarGrandContentImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.imageClicked(_:)))
        globSidebarView?.sideBarGrandContentImageView.addGestureRecognizer(tap)
        
    }
}



