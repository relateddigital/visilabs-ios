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
    private weak var initialTopViewController: UIViewController?
    private var pageChangeTimer: Timer?

    private var currentItemIndex = 0
    /// Incremented on every item change so that a late image response cannot overwrite a newer item.
    private var itemGeneration = 0
    private var autoScrollTimer: Timer?
    private var minimizedPageIndicator: DrawerPageIndicatorView?
    private var maximizedPageIndicator: DrawerPageIndicatorView?
    private var didConfigureItems = false

    private var hasMultipleItems: Bool {
        model.items.count > 1
    }

    private var minimizedContainerView: UIView? {
        model.screenXcoordinate == .right ? globDrawerView?.leftDrawerMiniView : globDrawerView?.rightDrawerMiniView
    }

    private let minimizedDotSpacing: CGFloat = 4.0
    private let minimizedDotHorizontalPadding: CGFloat = 4.0

    /// Vertical space the minimized dots occupy at the bottom of the strip.
    private var minimizedIndicatorReservedHeight: CGFloat {
        hasMultipleItems ? DrawerPageIndicatorView.height() : 0
    }
    
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

        if !didConfigureItems {
            didConfigureItems = true
            prefetchItemImages()
            setupPageIndicators()
            addSwipeGestures()
        }

        applyItem(at: currentItemIndex, animated: false)
        startAutoScrollIfNeeded()
    }

    // MARK: - Items

    private func applyItem(at index: Int, animated: Bool) {
        guard !model.items.isEmpty else { return }

        let itemCount = model.items.count
        let boundedIndex = ((index % itemCount) + itemCount) % itemCount
        currentItemIndex = boundedIndex
        itemGeneration += 1

        let item = model.items[boundedIndex]
        let applyContent = { [weak self] in
            self?.applyMinimizedContent(item)
            self?.applyMaximizedContent(item)
        }

        if animated, let view = self.view {
            UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: applyContent, completion: nil)
        } else {
            applyContent()
        }

        minimizedPageIndicator?.setCurrentIndex(boundedIndex)
        maximizedPageIndicator?.setCurrentIndex(boundedIndex)
    }

    private func applyMinimizedContent(_ item: DrawerItemViewModel) {
        if model.screenXcoordinate == .right {
            setImage(globDrawerView?.leftDrawerMiniContentImageView, urlString: item.miniDrawerContentImage)
            globDrawerView?.leftTitleLabel.text = item.titleString
            globDrawerView?.leftTitleLabel.font = item.miniDrawerTextFont
            globDrawerView?.leftTitleLabel.textColor = item.miniDrawerTextColor
            globDrawerView?.leftTitleLabel.transform = labelTransform(for: item.labelType)
            setImage(globDrawerView?.leftDrawerMiniImageView, urlString: item.miniDrawerBackgroundImage)
            globDrawerView?.leftDrawerMiniImageView.backgroundColor = item.miniDrawerBackgroundColor
            globDrawerView?.leftDrawerMiniArrow.textColor = item.arrowColor
        } else {
            setImage(globDrawerView?.rightDrawerMiniContentImageView, urlString: item.miniDrawerContentImage)
            globDrawerView?.rightTitleLabel.text = item.titleString
            globDrawerView?.rightTitleLabel.font = item.miniDrawerTextFont
            globDrawerView?.rightTitleLabel.textColor = item.miniDrawerTextColor
            globDrawerView?.rightTitleLabel.transform = labelTransform(for: item.labelType)
            setImage(globDrawerView?.rightDrawerMiniImageView, urlString: item.miniDrawerBackgroundImage)
            globDrawerView?.rightDrawerMiniImageView.backgroundColor = item.miniDrawerBackgroundColor
            globDrawerView?.rightDrawerMiniArrow.textColor = item.arrowColor
        }
    }

    private func applyMaximizedContent(_ item: DrawerItemViewModel) {
        setImage(globDrawerView?.drawerGrandImageView, urlString: item.drawerBackgroundImage)
        globDrawerView?.drawerGrandImageView.backgroundColor = item.drawerBackgroundColor
        setImage(globDrawerView?.drawerGrandContentImageView, urlString: item.drawerContentImage)
    }

    private func labelTransform(for type: labelType) -> CGAffineTransform {
        let angle = type == .upToDown ? CGFloat.pi / 2 : -CGFloat.pi / 2
        let rotation = CGAffineTransform(rotationAngle: angle)

        let reserved = minimizedIndicatorReservedHeight
        guard reserved > 0 else { return rotation }

        // The label is centered in the strip; shifting it up by half of the reserved height
        // re-centers it within the area that is left above the dots.
        return rotation.concatenating(CGAffineTransform(translationX: 0, y: -reserved / 2))
    }

    private func selectItem(at index: Int) {
        guard hasMultipleItems else { return }
        applyItem(at: index, animated: true)
        // Restart the countdown so a manual change is not followed by an immediate automatic one.
        startAutoScrollIfNeeded()
    }

    // MARK: - Images

    private func setImage(_ imageView: UIImageView?, urlString: String) {
        guard let imageView = imageView else { return }

        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            imageView.image = cachedImage
            return
        }

        imageView.image = nil
        guard !urlString.isEmpty, let url = URL(string: urlString) else { return }

        let generation = itemGeneration
        URLSession.shared.dataTask(with: url) { [weak self, weak imageView] data, _, _ in
            guard let data = data, let image = UIImage.gif(data: data) else { return }
            imageCache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async {
                guard let self = self, let imageView = imageView, self.itemGeneration == generation else { return }
                imageView.image = image
            }
        }.resume()
    }

    /// Warms up the cache so switching between items does not flicker.
    private func prefetchItemImages() {
        let urlStrings = model.items.flatMap {
            [$0.miniDrawerContentImage, $0.miniDrawerBackgroundImage, $0.drawerContentImage, $0.drawerBackgroundImage]
        }

        for urlString in urlStrings where !urlString.isEmpty {
            guard imageCache.object(forKey: urlString as NSString) == nil, let url = URL(string: urlString) else { continue }
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let image = UIImage.gif(data: data) else { return }
                imageCache.setObject(image, forKey: urlString as NSString)
            }.resume()
        }
    }

    // MARK: - Auto scroll

    private func startAutoScrollIfNeeded() {
        stopAutoScroll()
        guard hasMultipleItems, !drawerOpen else { return }

        let timer = Timer(timeInterval: model.autoScrollInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            guard !self.drawerOpen else { return }
            self.applyItem(at: self.currentItemIndex + 1, animated: true)
        }
        RunLoop.current.add(timer, forMode: .common)
        autoScrollTimer = timer
    }

    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    // MARK: - Item navigation setup

    private func setupPageIndicators() {
        guard hasMultipleItems else { return }

        if let containerView = minimizedContainerView {
            // The strip is narrow, so the dots are laid out horizontally with tighter
            // spacing than in the maximized panel to stay inside its width.
            let indicator = makePageIndicator(axis: .horizontal,
                                              dotSpacing: minimizedDotSpacing,
                                              horizontalPadding: minimizedDotHorizontalPadding)
            containerView.addSubview(indicator)

            var centerXOffset = 0.0
            if model.isCircle {
                // In circle mode the outer half of the strip sits off screen, so the dots follow the label.
                centerXOffset = model.screenXcoordinate == .right ? model.xCoordPaddingConstant : -model.xCoordPaddingConstant
            }

            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: centerXOffset),
                indicator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            minimizedPageIndicator = indicator
            reserveSpaceForMinimizedIndicator()
        }

        if let grandView = globDrawerView?.drawerGrandView {
            let indicator = makePageIndicator(axis: .horizontal)
            grandView.addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: grandView.centerXAnchor),
                indicator.bottomAnchor.constraint(equalTo: grandView.bottomAnchor)
            ])
            maximizedPageIndicator = indicator
        }
    }

    /// Pushes the minimized content up so that it sits above the dots instead of behind them.
    private func reserveSpaceForMinimizedIndicator() {
        let reserved = minimizedIndicatorReservedHeight
        guard reserved > 0 else { return }

        // The label is centered in the strip and is re-centered above the dots by labelTransform.
        if model.screenXcoordinate == .right {
            globDrawerView?.leftDrawerMiniContentImageBottomConstraint.constant += reserved
        } else {
            globDrawerView?.rightDrawerMiniContentImageBottomConstraint.constant += reserved
        }
    }

    private func makePageIndicator(axis: NSLayoutConstraint.Axis,
                                   dotSpacing: CGFloat = 5.0,
                                   horizontalPadding: CGFloat = 7.0) -> DrawerPageIndicatorView {
        let indicator = DrawerPageIndicatorView(numberOfPages: model.items.count,
                                                axis: axis,
                                                dotSpacing: dotSpacing,
                                                horizontalPadding: horizontalPadding)
        // The content image view of the maximized part sits on zPosition 1.
        indicator.layer.zPosition = 2
        indicator.onIndexSelected = { [weak self] index in
            self?.selectItem(at: index)
        }
        return indicator
    }

    private func addSwipeGestures() {
        guard hasMultipleItems else { return }

        // The minimized strip changes items on horizontal swipes; opening and closing stays on tap.
        if let containerView = minimizedContainerView {
            addSwipeGestures(to: containerView, directions: [.left, .right])
        }
        if let grandView = globDrawerView?.drawerGrandView {
            addSwipeGestures(to: grandView, directions: [.up, .down, .left, .right])
        }
    }

    private func addSwipeGestures(to view: UIView, directions: [UISwipeGestureRecognizer.Direction]) {
        view.isUserInteractionEnabled = true
        for direction in directions {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipe.direction = direction
            view.addGestureRecognizer(swipe)
        }
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard hasMultipleItems else { return }
        switch gesture.direction {
        case .up, .left:
            selectItem(at: currentItemIndex + 1)
        default:
            selectItem(at: currentItemIndex - 1)
        }
    }
    
    @objc func closeClicked(_ sender: UITapGestureRecognizer? = nil) {
            stopPageChangeObserving()
            stopAutoScroll()
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
        
        // The label text, font, colour and orientation are per item and applied by applyItem(at:animated:).

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

        // Taps that land on the dots switch the item instead of following the link.
        if let indicator = maximizedPageIndicator, let sender = sender,
           indicator.bounds.contains(sender.location(in: indicator)) {
            return
        }

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

        // Taps that land on the dots switch the item instead of opening or closing the drawer.
        if let indicator = minimizedPageIndicator, let sender = sender,
           indicator.bounds.contains(sender.location(in: indicator)) {
            return
        }

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

        if drawerOpen {
            stopAutoScroll()
        } else {
            startAutoScrollIfNeeded()
        }
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
        startPageChangeObserving()
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
            stopPageChangeObserving()
            stopAutoScroll()
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

    // MARK: - Page Change Detection
    private func startPageChangeObserving() {
        initialTopViewController = RDDrawerViewController.topViewController(excluding: self.window)
        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            let currentTop = RDDrawerViewController.topViewController(excluding: self.window)
            if let initial = self.initialTopViewController,
               let current = currentTop,
               initial !== current {
                self.closeClicked()
            }
        }
        RunLoop.current.add(timer, forMode: .common)
        pageChangeTimer = timer
    }

    private func stopPageChangeObserving() {
        pageChangeTimer?.invalidate()
        pageChangeTimer = nil
    }

    private static func topViewController(excluding excludedWindow: UIWindow?) -> UIViewController? {
        guard let app = VisilabsInstance.sharedUIApplication() else { return nil }
        var mainWindow: UIWindow?
        if #available(iOS 13.0, *) {
            let scene = app.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
            mainWindow = scene?.windows.first { $0 !== excludedWindow && $0.windowLevel == .normal }
        } else {
            mainWindow = app.windows.first { $0 !== excludedWindow && $0.windowLevel == .normal }
        }
        guard let root = mainWindow?.rootViewController else { return nil }
        return topMost(of: root)
    }

    private static func topMost(of vc: UIViewController) -> UIViewController {
        if let nav = vc as? UINavigationController, let visible = nav.visibleViewController {
            return topMost(of: visible)
        }
        if let tab = vc as? UITabBarController, let selected = tab.selectedViewController {
            return topMost(of: selected)
        }
        if let presented = vc.presentedViewController {
            return topMost(of: presented)
        }
        return vc
    }
}
