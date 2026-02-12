import Foundation
import UIKit

class RDDrawerViewController: VisilabsBaseNotificationViewController {
    
    var position: CGPoint?
    var model = DrawerViewModel()
    var globDrawerView: drawerView?
    var drawerOpen: Bool = false
    var drawerFirstPosition: CGPoint?

    var shouldDismissed = false
    var report: DrawerReport?
    
    init(model: DrawerServiceModel?) {
        super.init(nibName: nil, bundle: nil)
        self.model = RDDrawerViewControllerModel().mapServiceModelToNeededModel(serviceModel: model)
        let drawerView: drawerView = UIView.fromNib()
        drawerView.drawerModel = self.model
        globDrawerView = drawerView
        addTapGestureToDrawerMiniView()
        addTapGestureToImageOfGranDrawer()
        addTapGestureToCloseButton()
        if self.model.isCircle {
            self.globDrawerView!.isHidden = true
            self.model.miniDrawerWidth = self.model.miniDrawerWidthForCircle / 2
        }
        self.report = model?.report
        self.view = drawerView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawerFirstPosition = self.window?.layer.position
        if model.isCircle {
            configureCircleDrawer()
        }
        initializeData()
        
    }
    
    func initializeData() {
        
        if model.screenXcoordinate == .right {
            globDrawerView?.leftDrawerMiniContentImageView.setImage(withUrl: model.miniDrawerContentImage ?? "")
            globDrawerView?.leftTitleLabel.text = model.titleString
            globDrawerView?.leftTitleLabel.font = model.miniDrawerTextFont
            globDrawerView?.leftTitleLabel.textColor = model.miniDrawerTextColor
            globDrawerView?.leftDrawerMiniImageView.setImage(withUrl: model.miniDrawerBackgroundImage ?? "")
            globDrawerView?.leftDrawerMiniImageView.backgroundColor = model.miniDrawerBackgroundColor
            globDrawerView?.leftDrawerMiniArrow.textColor = model.arrowColor
        } else {
            globDrawerView?.rightDrawerMiniContentImageView.setImage(withUrl: model.miniDrawerContentImage ?? "")
            globDrawerView?.rightTitleLabel.text = model.titleString
            globDrawerView?.rightTitleLabel.font = model.miniDrawerTextFont
            globDrawerView?.rightTitleLabel.textColor = model.miniDrawerTextColor
            globDrawerView?.rightDrawerMiniImageView.setImage(withUrl: model.miniDrawerBackgroundImage ?? "")
            globDrawerView?.rightDrawerMiniImageView.backgroundColor = model.miniDrawerBackgroundColor
            globDrawerView?.rightDrawerMiniArrow.textColor = model.arrowColor
        }
        globDrawerView?.drawerGrandImageView.setImage(withUrl: model.drawerBackgroundImage ?? "")
        globDrawerView?.drawerGrandImageView.backgroundColor = model.drawerBackgroundColor
        globDrawerView?.drawerGrandContentImageView.setImage(withUrl: model.drawerContentImage ?? "")
        
    }
    
    @objc func closeClicked(_ sender: UITapGestureRecognizer? = nil) {
            
            
            self.window?.isHidden = true
            self.window?.removeFromSuperview()
            self.window = nil
        }
    
    func addTapGestureToCloseButton() {
            
        globDrawerView?.closeButton.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeClicked(_:)))
        globDrawerView?.closeButton.addGestureRecognizer(tap)
            
        }
    
    func createDummyModel() -> DrawerViewModel {
        var model = DrawerViewModel()
        
        model.titleString = "DenemeDeneme"
        model.isCircle = true
        model.screenYcoordinate = .middle
        model.screenXcoordinate = .right
        model.labelType = .downToUp
        
        return model
    }
    
    func configureCircleDrawer() {
        
        if model.screenXcoordinate == .right {
            
            self.globDrawerView?.leftDrawerMiniView.layer.zPosition = -1
            self.globDrawerView?.leftDrawerWidthConstraint.constant = self.model.miniDrawerWidthForCircle
            self.globDrawerView?.leftDrawerMiniView.layer.cornerRadius = self.model.miniDrawerWidthForCircle / 3
            self.globDrawerView?.leftDrawerTrailingConstraint.constant = -((self.globDrawerView?.leftDrawerWidthConstraint.constant)! / 2)
            self.globDrawerView?.leftDrawerTitleLabelCenterXConstraint.constant =  self.model.xCoordPaddingConstant
            self.globDrawerView?.leftDrawerContentImageCenterXConstraint.constant =  2
            
            if let imgUrl = self.model.miniDrawerContentImage, !imgUrl.isEmpty {
                self.globDrawerView?.leftDrawerMiniContentImageView.isHidden = false
                self.globDrawerView?.leftTitleLabel.isHidden = true
                self.globDrawerView?.leftDrawerMiniContentImageTopConstraint.constant = 0
                self.globDrawerView?.leftDrawerMiniContentImageBottomConstraint.constant = 0
                self.globDrawerView?.leftDrawerMiniContentImageLeadingConstraint.constant = 0
                self.globDrawerView?.leftDrawerMiniContentImageTrailingConstraint.constant += (self.globDrawerView?.drawerModel!.miniDrawerWidth)!
            } else {
                self.globDrawerView?.leftDrawerMiniContentImageView.isHidden = true
                self.globDrawerView?.leftTitleLabel.isHidden = false
                self.globDrawerView?.leftDrawerMiniContentImageTopConstraint.constant *= 1.6
                self.globDrawerView?.leftDrawerMiniContentImageBottomConstraint.constant *= 3
                self.globDrawerView?.leftDrawerMiniContentImageLeadingConstraint.constant = 20
                self.globDrawerView?.leftDrawerMiniContentImageTrailingConstraint.constant += (self.globDrawerView?.drawerModel!.miniDrawerWidth)!
            }
            self.globDrawerView!.leftDrawerMiniView.clipsToBounds = true
            // self.globSidebarView?.leftSideBarMiniImageView.image = self.model.dataImage
            self.globDrawerView!.isHidden = false
        } else if model.screenXcoordinate == .left {
            
            self.globDrawerView?.rightDrawerMiniView.layer.zPosition = -1
            self.globDrawerView?.rightDrawerWidthConstraint.constant = self.model.miniDrawerWidthForCircle
            self.globDrawerView?.rightDrawerMiniView.layer.cornerRadius = self.model.miniDrawerWidthForCircle / 3
            self.globDrawerView?.rightDrawerTrailingConstraint.constant = -((self.globDrawerView?.rightDrawerWidthConstraint.constant)! / 2)
            self.globDrawerView?.rightDrawerTitleLabelCenterXConstraint.constant =  -(self.model.xCoordPaddingConstant)
            self.globDrawerView?.rightDrawerContentImageCenterXConstraint.constant = -2
            
            if let imgUrl = self.model.miniDrawerContentImage, !imgUrl.isEmpty {
                self.globDrawerView?.rightDrawerMiniContentImageView.isHidden = false
                self.globDrawerView?.rightTitleLabel.isHidden = true
                self.globDrawerView?.rightDrawerMiniContentImageTopConstraint.constant = 0
                self.globDrawerView?.rightDrawerMiniContentImageBottomConstraint.constant = 0
                self.globDrawerView?.rightDrawerMiniContentImageTrailingConstraint.constant = 0
                self.globDrawerView?.rightDrawerMiniContentImageLeadingConstraint.constant += (self.globDrawerView?.drawerModel!.miniDrawerWidth)!
            } else {
                self.globDrawerView?.rightDrawerMiniContentImageView.isHidden = true
                self.globDrawerView?.rightTitleLabel.isHidden = false
                self.globDrawerView?.rightDrawerMiniContentImageTopConstraint.constant *= 1.6
                self.globDrawerView?.rightDrawerMiniContentImageBottomConstraint.constant *= 3
                self.globDrawerView?.rightDrawerMiniContentImageTrailingConstraint.constant = 20
                self.globDrawerView?.rightDrawerMiniContentImageLeadingConstraint.constant += (self.globDrawerView?.drawerModel!.miniDrawerWidth)!
            }
            self.globDrawerView!.rightDrawerMiniView.clipsToBounds = true
            // self.globSidebarView?.rightSideBarMiniImageView.image = self.model.dataImage
            self.globDrawerView!.isHidden = false
        }
    }
    
    func configureStandartView(drawer: drawerView) {
        
        // ekranın sağında mı solunda mı
        if self.model.screenXcoordinate == .right {
            globDrawerView?.leftDrawerMiniWidthConstraint.constant = self.model.miniDrawerWidth
            globDrawerView?.rightDrawerMiniWidthConstraint.constant = 0
            globDrawerView?.rightDrawerMiniView.isHidden = true
        } else if self.model.screenXcoordinate == .left {
            globDrawerView?.rightDrawerMiniWidthConstraint.constant = self.model.miniDrawerWidth
            globDrawerView?.leftDrawerMiniWidthConstraint.constant = 0
            globDrawerView?.leftDrawerMiniView.isHidden = true
        }
        
        // label tipi
        if self.model.labelType == .downToUp  && self.model.screenXcoordinate == .right {
            globDrawerView!.leftTitleLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        } else if self.model.labelType == .upToDown  && self.model.screenXcoordinate == .right {
            globDrawerView!.leftTitleLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        } else if self.model.labelType == .downToUp  && self.model.screenXcoordinate == .left {
            globDrawerView!.rightTitleLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        } else if self.model.labelType == .upToDown  && self.model.screenXcoordinate == .left {
            globDrawerView!.rightTitleLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        }
        
        if self.model.screenXcoordinate == .right {

            globDrawerView!.leftTitleLabel.text = model.titleString
            // modele göre diğer elementlerin assign edilmesi gerek left mini viewa
        } else if self.model.screenXcoordinate == .left {

            globDrawerView!.rightTitleLabel.text = model.titleString
            // modele göre diğer elementlerin assign edilmesi gerek right mini viewa
        }
        if !self.model.isCircle {
            globDrawerView?.rightDrawerMiniContentImageView.isHidden = true
            globDrawerView?.leftDrawerMiniContentImageView.isHidden = true
        }
        
        if self.model.screenXcoordinate == .right && !(self.model.isCircle ) {
            self.globDrawerView?.leftDrawerMiniContentImageTopConstraint.constant *= 1.2
        } else if self.model.screenXcoordinate == .left && !(self.model.isCircle ) {
            self.globDrawerView?.rightDrawerMiniContentImageTopConstraint.constant *= 1.2
        }
        
    }
    
    @objc func imageClicked(_ sender: UITapGestureRecognizer? = nil) {
        
        if let report = self.report {
            Visilabs.callAPI().trackDrawerClick(drawerReport: report)
        }
        
        if model.staticcode?.count ?? 0 > 0 {
            UIPasteboard.general.string = model.staticcode
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                VisilabsHelper.showCopiedClipboardMessage()
            }
        }
        
        if let url = URL(string: self.model.linkToGo ?? "") {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @objc func viewClicked(_ sender: UITapGestureRecognizer? = nil) {
        
        UIView.animate(withDuration: 0.5, animations: { [self] in
            if drawerOpen {
                self.window?.layer.position = drawerFirstPosition!
                if model.screenXcoordinate == .right {
                    globDrawerView?.leftDrawerMiniArrow.text = "<"
                } else if model.screenXcoordinate == .left {
                    globDrawerView?.rightDrawerMiniArrow.text = ">"
                }
            } else {
                if model.screenXcoordinate == .right {
                    if let winPos = self.window?.layer.position {
                        self.window?.layer.position = CGPoint(x: winPos.x - globDrawerView!.width + self.model.miniDrawerWidth, y: winPos.y)
                    }
                    globDrawerView?.leftDrawerMiniArrow.text = ">"
                } else if model.screenXcoordinate == .left {
                    if let winPos = self.window?.layer.position {
                        self.window?.layer.position = CGPoint(x: winPos.x + globDrawerView!.width - self.model.miniDrawerWidth, y: winPos.y)
                    }
                    globDrawerView?.rightDrawerMiniArrow.text = "<"
                }
            }
        })
        drawerOpen = !drawerOpen
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
        let DrawerframeWidth = bounds.size.width / 2
        
        var frameY = Double()
        
        if self.model.screenYcoordinate == .top {
            frameY = bounds.size.height/2 - self.model.drawerHeight * 1.5
        } else if self.model.screenYcoordinate == .bottom {
            frameY = bounds.size.height - self.model.drawerHeight * 1.5
        } else if self.model.screenYcoordinate == .middle {
            frameY = bounds.size.height / 2 - self.model.drawerHeight / 2
        }
        
        var frame = CGRect()
        
        if self.model.screenXcoordinate == .right {
            frame = CGRect(origin: CGPoint(x: bounds.maxX-self.model.miniDrawerWidth, y: CGFloat(frameY)), size: CGSize(width: DrawerframeWidth, height: CGFloat(self.model.drawerHeight)))
        } else if self.model.screenXcoordinate == .left {
            frame = CGRect(origin: CGPoint(x: bounds.minX-DrawerframeWidth+model.miniDrawerWidth, y: CGFloat(frameY)), size: CGSize(width: DrawerframeWidth, height: CGFloat(self.model.drawerHeight)))
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
        configureStandartView(drawer: view as! drawerView)
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
    
    func addTapGestureToDrawerMiniView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewClicked(_:)))
        if self.model.screenXcoordinate == .right {
            globDrawerView?.leftDrawerMiniView.addGestureRecognizer(tap)
        } else if self.model.screenXcoordinate == .left {
            globDrawerView?.rightDrawerMiniView.addGestureRecognizer(tap)
        }
    }
    
    func addTapGestureToImageOfGranDrawer() {
        globDrawerView?.drawerGrandContentImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.imageClicked(_:)))
        globDrawerView?.drawerGrandContentImageView.addGestureRecognizer(tap)

    }
}
