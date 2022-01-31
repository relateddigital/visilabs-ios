//
//  VisilabsSideBar.swift
//  VisilabsIOS
//
//  Created by Orhun Akmil on 13.01.2022.
//

import Foundation
import UIKit


class visilabsSideBarViewController : UIViewController {
    
    
    var position: CGPoint?
    var model = SideBarModel()
    var window: UIWindow?
    var globSidebarView : sideBarView?
    var sideBarOpen:Bool = false
    var sideBarFirstPosition:CGPoint?
    var titleLenght = 12
    
    
    public init(model:SideBarModel?) {
        super.init(nibName: nil, bundle: nil)
        self.model = createDummyModel()
        let sidebarView : sideBarView = UIView.fromNib()
        sidebarView.sideBarModel = self.model
        globSidebarView = sidebarView
        addTapGestureToSideBarMiniView()
        addTapGestureToImageOfGranSideBar()
        if self.model.isCircle {
            self.globSidebarView!.isHidden = true
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
    }
    
    func createDummyModel()  -> SideBarModel {
        let model = SideBarModel()
        
        model.titleString = "denemeDeneme"
        model.isCircle = false
        model.screenYcoordinate = .bottom
        model.screenXcoordinate = .right
        model.labelType = .upToDown

        return model
    }
        
    func configureCircleSideBar() {

        if model.screenXcoordinate == .right {
            let semiCirleLayer: CAShapeLayer = CAShapeLayer()
            let arcCenter = CGPoint(x: globSidebarView!.leftSideBarMiniView.bounds.maxX, y: self.globSidebarView!.leftSideBarMiniView.bounds.maxY/2)
            let circleRadius = self.globSidebarView!.leftSideBarMiniView.height / 2
            let circlePath = UIBezierPath(arcCenter: arcCenter, radius: circleRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi*3/2 , clockwise: true)
            semiCirleLayer.path = circlePath.cgPath
            semiCirleLayer.fillColor = UIColor.red.cgColor
            semiCirleLayer.zPosition = -1
            self.globSidebarView!.leftSideBarMiniView.layer.addSublayer(semiCirleLayer)
            self.globSidebarView!.leftSideBarMiniView.backgroundColor = .clear
            self.globSidebarView!.isHidden = false
        } else if model.screenXcoordinate == .left {
            let semiCirleLayer: CAShapeLayer = CAShapeLayer()
            let arcCenter = CGPoint(x: globSidebarView!.rightSideBarMiniView.bounds.minX, y: self.globSidebarView!.rightSideBarMiniView.bounds.maxY/2)
            let circleRadius = self.globSidebarView!.rightSideBarMiniView.height / 2
            let circlePath = UIBezierPath(arcCenter: arcCenter, radius: circleRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi*3/2 , clockwise: false)
            semiCirleLayer.path = circlePath.cgPath
            semiCirleLayer.fillColor = UIColor.red.cgColor
            semiCirleLayer.zPosition = -1
            self.globSidebarView!.rightSideBarMiniView.layer.addSublayer(semiCirleLayer)
            self.globSidebarView!.rightSideBarMiniView.backgroundColor = .clear
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

    }
    
    @objc func imageClicked(_ sender: UITapGestureRecognizer? = nil) {
        print("image a basıldı")
        hide() {
            print("hided")
        }
    }

    @objc func viewClicked(_ sender: UITapGestureRecognizer? = nil) {
        print("view a basıldı")
       
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
    
    
    func show(animated: Bool) {
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
    
    
    func hide(completion: @escaping () -> Void) {
        self.window?.isHidden = true
        self.window?.removeFromSuperview()
        self.window = nil
        completion()
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



class SideBarModel {
    
    var isCircle : Bool = false
    var sideBarHeight = 200.0
    var miniSideBarWidth = 40.0
    var titleString : String = "Deneme"
    var screenYcoordinate : screenYcoordinate?
    var screenXcoordinate : screenXcoordinate?
    var labelType : labelType?
    
}

public enum screenYcoordinate {
    case top
    case middle
    case bottom
}

public enum screenXcoordinate {
    case right
    case left
}

public enum labelType {
    case downToUp
    case upToDown
}
