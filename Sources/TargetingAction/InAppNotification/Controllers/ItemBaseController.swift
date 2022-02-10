//
//  ItemBaseController.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 8.02.2022.
//

import UIKit

public class ItemBaseController: UIViewController, ItemController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    //UI
    public var itemView: VisilabsCarouselItemView!
    let scrollView = UIScrollView()
    
    //DELEGATE / DATASOURCE
    weak public var delegate:                 ItemControllerDelegate?
    weak public var displacedViewsDataSource: GalleryDisplacedViewsDataSource?
    
    //STATE
    public let index: Int
    public var isInitialController = false
    let itemCount: Int
    var swipingToDismiss: SwipeToDismiss?
    fileprivate var isAnimating = false
    fileprivate var fetchImageBlock: FetchImageBlock
    
    //CONFIGURATION
    fileprivate var presentationStyle = GalleryPresentationStyle.displacement
    fileprivate var displacementDuration: TimeInterval = 0.55
    fileprivate var reverseDisplacementDuration: TimeInterval = 0.25
    fileprivate var itemFadeDuration: TimeInterval = 0.3
    fileprivate var displacementTimingCurve: UIView.AnimationCurve = .linear
    fileprivate var displacementSpringBounce: CGFloat = 0.7
    fileprivate var pagingMode: GalleryPagingMode = .standard
    fileprivate var thresholdVelocity: CGFloat = 500 // The speed of swipe needs to be at least this amount of pixels per second for the swipe to finish dismissal.
    fileprivate var displacementKeepOriginalInPlace = false
    fileprivate var displacementInsetMargin: CGFloat = 0
    fileprivate var swipeToDismissMode = GallerySwipeToDismissMode.always
    fileprivate var activityViewByLongPress = true
    
    /// INTERACTIONS
    fileprivate let swipeToDismissRecognizer = UIPanGestureRecognizer()
    
    // TRANSITIONS
    fileprivate var swipeToDismissTransition: GallerySwipeToDismissTransition?
    
    
    // MARK: - Initializers
    
    public init(index: Int, itemCount: Int, fetchImageBlock: @escaping FetchImageBlock, visilabsCarouselItemView: VisilabsCarouselItemView, configuration: GalleryConfiguration, isInitialController: Bool = false) {
        
        self.itemView = visilabsCarouselItemView
        
        self.index = index
        self.itemCount = itemCount
        self.isInitialController = isInitialController
        self.fetchImageBlock = fetchImageBlock
        
        for item in configuration {
            
            switch item {
                
            case .swipeToDismissThresholdVelocity(let velocity):    thresholdVelocity = velocity
            case .presentationStyle(let style):                     presentationStyle = style
            case .pagingMode(let mode):                             pagingMode = mode
            case .displacementDuration(let duration):               displacementDuration = duration
            case .reverseDisplacementDuration(let duration):        reverseDisplacementDuration = duration
            case .displacementTimingCurve(let curve):               displacementTimingCurve = curve
            case .itemFadeDuration(let duration):                   itemFadeDuration = duration
            case .displacementKeepOriginalInPlace(let keep):        displacementKeepOriginalInPlace = keep
            case .displacementInsetMargin(let margin):              displacementInsetMargin = margin
            case .swipeToDismissMode(let mode):                     swipeToDismissMode = mode
                
            case .displacementTransitionStyle(let style):
                switch style {
                case .springBounce(let bounce):                     displacementSpringBounce = bounce
                case .normal:                                       displacementSpringBounce = 1
                }
                
            default: break
            }
        }
        
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom
        
        //TODO: egemen
        self.itemView.imageView.isHidden = isInitialController
        
        configureScrollView()
        configureGestureRecognizers()
        
    }
    
    @available (*, unavailable)
    required public init?(coder aDecoder: NSCoder) { fatalError() }
    
    deinit {
        self.scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    // MARK: - Configuration
    
    fileprivate func configureScrollView() {
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = UIScrollView.DecelerationRate.normal
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.contentOffset = CGPoint.zero
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.delegate = self
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    /*
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
     */
    
    func configureGestureRecognizers() {
        
        if swipeToDismissMode != .never {
            swipeToDismissRecognizer.addTarget(self, action: #selector(scrollViewDidSwipeToDismiss))
            swipeToDismissRecognizer.delegate = self
            view.addGestureRecognizer(swipeToDismissRecognizer)
        }
    }
    
    fileprivate func createViewHierarchy() {
        //TODO:egemen
        //scrollView.addSubview(itemView)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        self.view.addSubview(scrollView)
        
    }
    
    // MARK: - View Controller Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        createViewHierarchy()
        
        fetchImage()
    }
    
    public func fetchImage() {
        
        fetchImageBlock { [weak self] image, carouselItem in
            
            DispatchQueue.main.async {
                
                
                if let s = self {
                    s.itemView = VisilabsCarouselItemView(frame: .zero, visilabsCarouselItem: carouselItem)
                    s.scrollView.addSubview(s.itemView)
                    s.itemView.titleColor = carouselItem.titleColor
                    s.itemView.titleFont = carouselItem.titleFont
                    s.itemView.imageView.image = image
                    //s.itemView.imageView.contentMode = .scaleAspectFill
                    s.itemView.centerYAnchor.constraint(equalTo: s.scrollView.centerYAnchor).isActive = true
                    //s.itemView.centerXAnchor.constraint(equalTo: s.scrollView.centerXAnchor).isActive = true
                    s.itemView.centerXAnchor.constraint(equalTo: s.view.centerXAnchor).isActive = true
                    s.itemView.leadingAnchor.constraint(equalTo: s.scrollView.leadingAnchor, constant: 30.0).isActive = true
                    s.itemView.trailingAnchor.constraint(equalTo: s.scrollView.trailingAnchor, constant: -30.0).isActive = true
                    s.itemView.imageHeightConstraint?.constant = s.itemView.imageView.pv_heightForImageView()
                    s.itemView.translatesAutoresizingMaskIntoConstraints = false
                    s.itemView.isAccessibilityElement = true
                    s.itemView.accessibilityLabel = UUID().uuidString // TODO: egemen önemi var mı?
                    s.itemView.accessibilityTraits = .none //TODO: egemen önemi var mı? image.accessibilityTraits
                    
                    self?.view.setNeedsLayout()
                    self?.view.layoutIfNeeded()
                }
            }
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.delegate?.itemControllerWillAppear(self)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.delegate?.itemControllerDidAppear(self)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.delegate?.itemControllerWillDisappear(self)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = self.view.bounds
        
        if let size = itemView.imageView.image?.size , size != CGSize.zero {
            itemView.bounds.size = size
            scrollView.contentSize = itemView.bounds.size
            itemView.center = scrollView.boundsCenter
        }
        itemView.imageHeightConstraint?.constant = itemView.imageView.pv_heightForImageView()
        
    }
    
    // MARK: - Scroll View delegate methods
    
    @objc func scrollViewDidSwipeToDismiss(_ recognizer: UIPanGestureRecognizer) {
        
        /// A deliberate UX decision...you have to zoom back in to scale 1 to be able to swipe to dismiss. It is difficult for the user to swipe to dismiss from images larger then screen bounds because almost all the time it's not swiping to dismiss but instead panning a zoomed in picture on the canvas.
        guard scrollView.zoomScale == scrollView.minimumZoomScale else { return }
        
        let currentVelocity = recognizer.velocity(in: self.view)
        let currentTouchPoint = recognizer.translation(in: view)
        
        if swipingToDismiss == nil { swipingToDismiss = (abs(currentVelocity.x) > abs(currentVelocity.y)) ? .horizontal : .vertical }
        guard let swipingToDismissInProgress = swipingToDismiss else { return }
        
        switch recognizer.state {
            
        case .began:
            swipeToDismissTransition = GallerySwipeToDismissTransition(scrollView: self.scrollView)
            
            
        case .changed:
            self.handleSwipeToDismissInProgress(swipingToDismissInProgress, forTouchPoint: currentTouchPoint)
            
        case .ended:
            self.handleSwipeToDismissEnded(swipingToDismissInProgress, finalVelocity: currentVelocity, finalTouchPoint: currentTouchPoint)
            
        default:
            break
        }
    }
    
    // MARK: - Swipe To Dismiss
    
    func handleSwipeToDismissInProgress(_ swipeOrientation: SwipeToDismiss, forTouchPoint touchPoint: CGPoint) {
        
        switch (swipeOrientation, index) {
            
        case (.horizontal, 0) where self.itemCount != 1:
            
            /// edge case horizontal first index - limits the swipe to dismiss to HORIZONTAL RIGHT direction.
            swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: min(0, -touchPoint.x))
            
        case (.horizontal, self.itemCount - 1) where self.itemCount != 1:
            
            /// edge case horizontal last index - limits the swipe to dismiss to HORIZONTAL LEFT direction.
            swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: max(0, -touchPoint.x))
            
        case (.horizontal, _):
            
            swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: -touchPoint.x) // all the rest
            
        case (.vertical, _):
            
            swipeToDismissTransition?.updateInteractiveTransition(verticalOffset: -touchPoint.y) // all the rest
        }
    }
    
    func handleSwipeToDismissEnded(_ swipeOrientation: SwipeToDismiss, finalVelocity velocity: CGPoint, finalTouchPoint touchPoint: CGPoint) {
        
        let maxIndex = self.itemCount - 1
        
        let swipeToDismissCompletionBlock = { [weak self] in
            
            UIApplication.applicationWindow.windowLevel = UIWindow.Level.normal
            self?.swipingToDismiss = nil
            self?.delegate?.itemControllerDidFinishSwipeToDismissSuccessfully()
        }
        
        switch (swipeOrientation, index) {
            
            /// Any item VERTICAL UP direction
        case (.vertical, _) where velocity.y < -thresholdVelocity:
            
            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation,
                                                                  touchPoint: touchPoint.y,
                                                                  targetOffset: (view.bounds.height / 2) + (itemView.bounds.height / 2),
                                                                  escapeVelocity: velocity.y,
                                                                  completion: swipeToDismissCompletionBlock)
            /// Any item VERTICAL DOWN direction
        case (.vertical, _) where thresholdVelocity < velocity.y:
            
            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation,
                                                                  touchPoint: touchPoint.y,
                                                                  targetOffset: -(view.bounds.height / 2) - (itemView.bounds.height / 2),
                                                                  escapeVelocity: velocity.y,
                                                                  completion: swipeToDismissCompletionBlock)
            /// First item HORIZONTAL RIGHT direction
        case (.horizontal, 0) where thresholdVelocity < velocity.x:
            
            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation,
                                                                  touchPoint: touchPoint.x,
                                                                  targetOffset: -(view.bounds.width / 2) - (itemView.bounds.width / 2),
                                                                  escapeVelocity: velocity.x,
                                                                  completion: swipeToDismissCompletionBlock)
            /// Last item HORIZONTAL LEFT direction
        case (.horizontal, maxIndex) where velocity.x < -thresholdVelocity:
            
            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation,
                                                                  touchPoint: touchPoint.x,
                                                                  targetOffset: (view.bounds.width / 2) + (itemView.bounds.width / 2),
                                                                  escapeVelocity: velocity.x,
                                                                  completion: swipeToDismissCompletionBlock)
            
            ///If none of the above select cases, we cancel.
        default:
            
            swipeToDismissTransition?.cancelTransition() { [weak self] in
                self?.swipingToDismiss = nil
            }
        }
    }
    
    func animateDisplacedImageToOriginalPosition(_ duration: TimeInterval, completion: ((Bool) -> Void)?) {
        
        guard (self.isAnimating == false) else { return }
        isAnimating = true
        
        UIView.animate(withDuration: duration, animations: {  [weak self] in
            
            //self?.scrollView.zoomScale = self!.scrollView.minimumZoomScale
            
            if UIApplication.isPortraitOnly {
                self?.itemView.transform = windowRotationTransform().inverted()
            }
            
        }, completion: { [weak self] finished in
            
            completion?(finished)
            
            if finished {
                
                UIApplication.applicationWindow.windowLevel = UIWindow.Level.normal
                
                self?.isAnimating = false
            }
        })
    }
    
    // MARK: - Present/Dismiss transitions
    
    public func presentItem(alongsideAnimation: () -> Void, completion: @escaping () -> Void) {
        
        //TODO:egemen
        //itemView.leading(to: scrollView, offset: 10, relation: .equal, priority: .required, isActive: true)
        //itemView.trailing(to: scrollView, offset: -10, relation: .equal, priority: .required, isActive: true)
        
        guard isAnimating == false else { return }
        isAnimating = true
        
        alongsideAnimation()
        
        if var displacedView = displacedViewsDataSource?.provideDisplacementItem(atIndex: index),
           let image = displacedView.image {
            
            if presentationStyle == .displacement {
                
                //Prepare the animated imageView
                let animatedImageView = displacedView.imageView()
                
                //rotate the imageView to starting angle
                if UIApplication.isPortraitOnly == true {
                    animatedImageView.transform = deviceRotationTransform()
                }
                
                //position the image view to starting center
                animatedImageView.center = displacedView.convert(displacedView.boundsCenter, to: self.view)
                
                animatedImageView.clipsToBounds = true
                self.view.addSubview(animatedImageView)
                
                if displacementKeepOriginalInPlace == false {
                    displacedView.isHidden = true
                }
                
                UIView.animate(withDuration: displacementDuration, delay: 0, usingSpringWithDamping: displacementSpringBounce, initialSpringVelocity: 1, options: .curveEaseIn, animations: { [weak self] in
                    
                    if UIApplication.isPortraitOnly == true {
                        animatedImageView.transform = CGAffineTransform.identity
                    }
                    /// Animate it into the center (with optionally rotating) - that basically includes changing the size and position
                    
                    animatedImageView.bounds.size = image.size
                    animatedImageView.center = self?.view.boundsCenter ?? CGPoint.zero
                    
                }, completion: { [weak self] _ in
                    
                    self?.itemView.isHidden = false
                    displacedView.isHidden = false
                    animatedImageView.removeFromSuperview()
                    
                    self?.isAnimating = false
                    completion()
                })
            }
        }
        
        else {
            
            
            
            
            
            itemView.alpha = 0
            itemView.isHidden = false
            
            UIView.animate(withDuration: itemFadeDuration, animations: { [weak self] in
                
                self?.itemView.alpha = 1
                
            }, completion: { [weak self] _ in
                
                completion()
                self?.isAnimating = false
            })
        }
    }
    
    
    
    func findVisibleDisplacedView() -> DisplaceableView? {
        
        guard let displacedView = displacedViewsDataSource?.provideDisplacementItem(atIndex: index) else { return nil }
        
        let displacedViewFrame = displacedView.frameInCoordinatesOfScreen()
        let validAreaFrame = self.view.frame.insetBy(dx: displacementInsetMargin, dy: displacementInsetMargin)
        let isVisibleEnough = displacedViewFrame.intersects(validAreaFrame)
        
        return isVisibleEnough ? displacedView : nil
    }
    
    public func dismissItem(alongsideAnimation: () -> Void, completion: @escaping () -> Void) {
        
        guard isAnimating == false else { return }
        isAnimating = true
        
        alongsideAnimation()
        
        switch presentationStyle {
            
        case .displacement:
            
            if var displacedView = self.findVisibleDisplacedView() {
                
                if displacementKeepOriginalInPlace == false {
                    displacedView.isHidden = true
                }
                
                UIView.animate(withDuration: reverseDisplacementDuration, animations: { [weak self] in
                    
                    //self?.scrollView.zoomScale = 1
                    
                    //rotate the image view
                    if UIApplication.isPortraitOnly == true {
                        self?.itemView.transform = deviceRotationTransform()
                    }
                    
                    //position the image view to starting center
                    self?.itemView.bounds = displacedView.bounds
                    self?.itemView.center = displacedView.convert(displacedView.boundsCenter, to: self!.view)
                    self?.itemView.clipsToBounds = true
                    //TODO:egemen
                    //self?.itemView.contentMode = displacedView.contentMode
                    
                }, completion: { [weak self] _ in
                    
                    self?.isAnimating = false
                    displacedView.isHidden = false
                    
                    completion()
                })
            }
            
            else { fallthrough }
            
        case .fade:
            
            UIView.animate(withDuration: itemFadeDuration, animations: {  [weak self] in
                
                self?.itemView.alpha = 0
                
            }, completion: { [weak self] _ in
                
                self?.isAnimating = false
                completion()
            })
        }
    }
    
    // MARK: - Arcane stuff
    
    /// This resolves which of the two pan gesture recognizers should kick in. There is one built in the GalleryViewController (as it is a UIPageViewController subclass), and another one is added as part of item controller. When we pan, we need to decide whether it constitutes a horizontal paging gesture, or a horizontal swipe-to-dismiss gesture.
    /// All the logic is from the perspective of SwipeToDismissRecognizer - should it kick in (or let the paging recognizer page)?
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        /// We only care about the swipe to dismiss gesture recognizer, not the built-in pan recognizer that handles paging.
        guard gestureRecognizer == swipeToDismissRecognizer else { return false }
        
        /// The velocity vector will help us make the right decision
        let velocity = swipeToDismissRecognizer.velocity(in: swipeToDismissRecognizer.view)
        ///A bit of paranoia
        guard velocity.orientation != .none else { return false }
        
        /// We continue if the swipe is horizontal, otherwise it's Vertical and it is swipe to dismiss.
        guard velocity.orientation == .horizontal else { return swipeToDismissMode.contains(.vertical) }
        
        /// A special case for horizontal "swipe to dismiss" is when the gallery has carousel mode OFF, then it is possible to reach the beginning or the end of image set while paging. Paging will stop at index = 0 or at index.max. In this case we allow to jump out from the gallery also via horizontal swipe to dismiss.
        if (self.index == 0 && velocity.direction == .right) || (self.index == self.itemCount - 1 && velocity.direction == .left) {
            
            return (pagingMode == .standard && swipeToDismissMode.contains(.horizontal))
        }
        
        return false
    }
    
    // Reports the continuous progress of Swipe To Dismiss to the Gallery View Controller
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let swipingToDismissInProgress = swipingToDismiss else { return }
        guard keyPath == "contentOffset" else { return }
        
        let distanceToEdge: CGFloat
        let percentDistance: CGFloat
        
        switch swipingToDismissInProgress {
            
        case .horizontal:
            
            distanceToEdge = (scrollView.bounds.width / 2) + (itemView.bounds.width / 2)
            percentDistance = abs(scrollView.contentOffset.x / distanceToEdge)
            
        case .vertical:
            
            distanceToEdge = (scrollView.bounds.height / 2) + (itemView.bounds.height / 2)
            percentDistance = abs(scrollView.contentOffset.y / distanceToEdge)
        }
        
        if let delegate = self.delegate {
            delegate.itemController(self, didSwipeToDismissWithDistanceToEdge: percentDistance)
        }
    }
    
    public func closeDecorationViews(_ duration: TimeInterval) {
        // stub
    }
}
