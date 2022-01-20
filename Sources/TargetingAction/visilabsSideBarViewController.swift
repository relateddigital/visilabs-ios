//
//  VisilabsSideBar.swift
//  VisilabsIOS
//
//  Created by Orhun Akmil on 13.01.2022.
//

import Foundation

import UIKit


class SideBarModel {
    
    var text : String?
}


class visilabsSideBarViewController : UIViewController {
    
    
    var position: CGPoint?
    var model:SideBarModel?
    var sideBarHeight = 175.0
    var miniSideBarWidth = 40.0
    var window: UIWindow?
    var globSidebarView : sideBarView?
    var isCircle:Bool = true
    var sideBarOpen:Bool = false
    var sideBarFirstPosition:CGPoint?
    
    
    //dummy
    var titleStr = "denemekkkkkkkkkkkk"


    
    public init(model:SideBarModel?) {
        super.init(nibName: nil, bundle: nil)
        self.model = model
        let sidebarView : sideBarView = UIView.fromNib()
        globSidebarView = sidebarView
        addTapGestureToSideBarMiniView()
        addTapGestureToImageOfGranSideBar()
        //is circle servisten gelen veriye göre beslenmeli
        if isCircle {
            self.globSidebarView!.isHidden = true
        }
        self.view = sidebarView
    }
    
    
    func addTapGestureToSideBarMiniView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewClicked(_:)))
        globSidebarView?.sideBarMiniView.addGestureRecognizer(tap)
    }
    
    
    func addTapGestureToImageOfGranSideBar() {
        globSidebarView?.sideBarGrandContentImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.imageClicked(_:)))
        globSidebarView?.sideBarGrandContentImageView.addGestureRecognizer(tap)
        
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
        if isCircle {
            configureCircleSideBar()
        }
    }
    
    func configureCircleSideBar() {
        let semiCirleLayer: CAShapeLayer = CAShapeLayer()
        let arcCenter = CGPoint(x: globSidebarView!.sideBarMiniView.bounds.maxX, y: self.globSidebarView!.sideBarMiniView.bounds.maxY/2)
        let circleRadius = self.globSidebarView!.sideBarMiniView.height / 2
        let circlePath = UIBezierPath(arcCenter: arcCenter, radius: circleRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi*3/2 , clockwise: true)
        semiCirleLayer.path = circlePath.cgPath
        semiCirleLayer.fillColor = UIColor.red.cgColor
        semiCirleLayer.zPosition = -1
        self.globSidebarView!.sideBarMiniView.layer.addSublayer(semiCirleLayer)
        self.globSidebarView!.sideBarMiniView.backgroundColor = .clear
        self.globSidebarView!.isHidden = false
        
    }
    
    func configureView(sideBar:sideBarView) {
                
        sideBar.titleLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        if titleStr.count > 10 {
            while titleStr.count != 10 {
                titleStr.removeLast()
            }
        }
        sideBar.titleLabel.text = titleStr + " ^"
        
        
        


//        sideBar.labelSuperView.backgroundColor = .clear
//        sideBar.titleLabel.font = sideBar.titleLabel.font.withSize(30)
//        sideBar.titleLabel.textColor = .black
//        sideBar.backgroundColor = .red
//        sideBar.arrowLabel.textColor = .white

    }
    
    @objc func imageClicked(_ sender: UITapGestureRecognizer? = nil) {
        print("image a basıldı")
       


    }

    @objc func viewClicked(_ sender: UITapGestureRecognizer? = nil) {
        print("view a basıldı")
       
        UIView.animate(withDuration: 0.5, animations: { [self] in
            if sideBarOpen {
                self.window?.layer.position = sideBarFirstPosition!
                globSidebarView?.titleLabel.text = titleStr + " ^"
            } else {
                if let winPos = self.window?.layer.position {
                    self.window?.layer.position = CGPoint(x: winPos.x - globSidebarView!.width + miniSideBarWidth  , y: winPos.y)
                    globSidebarView?.titleLabel.text = titleStr + " ⌄"
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
        //ortada istiyorsak
        let frameY = bounds.size.height / 2 - sideBarHeight / 2
        //aşağıda istersek
        //let frameY = bounds.size.height - sideBarHeight * 1.5
        //yukarıda istersek
        //let frameY = bounds.size.height/2 - sideBarHeight * 1.5

        
    
        let frame = CGRect(origin: CGPoint(x: bounds.maxX-miniSideBarWidth, y: CGFloat(frameY)), size: CGSize(width: SideBarframeWidth, height: CGFloat(sideBarHeight)))
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
        configureView(sideBar: view as! sideBarView)
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
            //self.window?.frame.origin.y -= 75
            self.window?.frame.origin.y -= 0
        }, completion: { _ in
            self.position = self.window?.layer.position
        })
    }
}
