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
    var sideBarHeight = 0.0
    var window: UIWindow?


    
    public init(model:SideBarModel?) {
        super.init(nibName: nil, bundle: nil)
        self.model = model
        
        let sidebarView : sideBarView = UIView.fromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewClicked(_:)))
        sidebarView.labelSuperView.addGestureRecognizer(tap)
        sidebarView.translatesAutoresizingMaskIntoConstraints = false
        self.view = sidebarView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureView(sideBar:sideBarView) {
        sideBar.titleLabelWidth.constant = (view.height - sideBar.arrowLabel.height) * 0.9
        sideBar.titleLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        sideBar.labelSuperView.backgroundColor = .clear
        sideBar.titleLabel.text = "deneme"
        sideBar.titleLabel.font = sideBar.titleLabel.font.withSize(30)
        sideBar.titleLabel.textColor = .black
        sideBar.backgroundColor = .red
        sideBar.arrowLabel.textColor = .white

    }


    @objc func viewClicked(_ sender: UITapGestureRecognizer? = nil) {
        print("view a basıldı")
    }
    
    func setTextToLineByLine(text:String) -> String {
        let characters = Array(text)
        var result : String = ""
        
        for element in characters {
            result += String(element) + "\n"
        }
        
        return result
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
        let SideBarframeWidth = 30.0
        sideBarHeight = bounds.size.height / 3
        
        //ortada istiyorsak
        let frameY = bounds.size.height / 2 - sideBarHeight / 2
        //aşşağıda istersek
        

        
    
        let frame = CGRect(origin: CGPoint(x: bounds.maxX-SideBarframeWidth, y: CGFloat(frameY)), size: CGSize(width: SideBarframeWidth, height: CGFloat(sideBarHeight)))
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
