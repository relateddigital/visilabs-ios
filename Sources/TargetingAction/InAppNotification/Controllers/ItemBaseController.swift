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
    //var swipingToDismiss: SwipeToDismiss?
    fileprivate var isAnimating = false
    fileprivate var fetchImageBlock: FetchImageBlock?
    
    //CONFIGURATION
    fileprivate var presentationStyle = GalleryPresentationStyle.displacement
    fileprivate var displacementDuration: TimeInterval = 0.1 // 0.55
    fileprivate var reverseDisplacementDuration: TimeInterval = 0.1 // 0.25
    fileprivate var itemFadeDuration: TimeInterval = 0.3
    fileprivate var displacementTimingCurve: UIView.AnimationCurve = .linear
    fileprivate var displacementSpringBounce: CGFloat = 0.7
    fileprivate var pagingMode: GalleryPagingMode = .standard
    fileprivate var thresholdVelocity: CGFloat = 500 // The speed of swipe needs to be at least this amount of pixels per second for the swipe to finish dismissal.
    fileprivate var displacementKeepOriginalInPlace = false
    fileprivate var displacementInsetMargin: CGFloat = 0

    // MARK: - Initializers
    
    public init(index: Int, itemCount: Int, fetchImageBlock: FetchImageBlock?, visilabsCarouselItemView: VisilabsCarouselItemView, isInitialController: Bool = false) {
        
        displacementKeepOriginalInPlace = false
        
        self.itemView = visilabsCarouselItemView
        
        self.index = index
        self.itemCount = itemCount
        self.isInitialController = isInitialController
        self.fetchImageBlock = fetchImageBlock
        
        displacementSpringBounce = 1
        
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom
        
        //TODO: egemen
        self.itemView.imageView.isHidden = isInitialController
        
        configureScrollView()
        
    }
    
    @available (*, unavailable)
    required public init?(coder aDecoder: NSCoder) { fatalError() }
    
    
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
    }
    
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
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
    
    @objc func closeButtonTapped(tapGestureRecognizer: UITapGestureRecognizer) {

        self.closeDecorationViews(0)
    }
    
    public func fetchImage() {
        
        fetchImageBlock? { [weak self] image, carouselItem in
            
            DispatchQueue.main.async {
                if let s = self {
                    s.itemView = VisilabsCarouselItemView(frame: .zero, visilabsCarouselItem: carouselItem)
                    s.scrollView.addSubview(s.itemView)
                    s.itemView.titleColor = carouselItem.titleColor
                    s.itemView.titleFont = carouselItem.titleFont
                    s.itemView.imageView.image = image
                    s.itemView.contentMode = .scaleAspectFill
                    s.itemView.centerYAnchor.constraint(equalTo: s.scrollView.centerYAnchor).isActive = true
                    s.itemView.imageHeightConstraint?.constant = s.itemView.imageView.pv_heightForImageView()
                    s.itemView.centerX(to: s.scrollView)
                    s.itemView.width(320.0)
                    s.itemView.isAccessibilityElement = true // TODO: egemen true idi
                    s.itemView.accessibilityLabel = UUID().uuidString // TODO: egemen önemi var mı?
                    s.itemView.accessibilityTraits = s.itemView.accessibilityTraits //TODO: egemen önemi var mı? image.accessibilityTraits
                    s.scrollView.minimumZoomScale = 1.0
                    s.scrollView.maximumZoomScale = 1.0
                    s.itemView.translatesAutoresizingMaskIntoConstraints = false
                    
                    
                    let closeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(s.closeButtonTapped(tapGestureRecognizer:)))
                    s.itemView.closeButton.isUserInteractionEnabled = true
                    s.itemView.closeButton.gestureRecognizers = []
                    s.itemView.closeButton.addGestureRecognizer(closeTapGestureRecognizer)
                    
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
        
        itemView.imageHeightConstraint?.constant = itemView.imageView.pv_heightForImageView()
        
        /*
        if let size = itemView.imageView.image?.size , size != CGSize.zero {
            itemView.bounds.size = size
            scrollView.contentSize = itemView.bounds.size
            itemView.center = scrollView.boundsCenter
        }
         */
        
        
    }

    // MARK: - Present/Dismiss transitions
    
    public func presentItem(alongsideAnimation: () -> Void, completion: @escaping () -> Void) {
        itemView.width(320.0)
        guard isAnimating == false else { return }
        isAnimating = true
        
        alongsideAnimation()
        
        if var displacedView = displacedViewsDataSource?.provideDisplacementItem(atIndex: index) {
            
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
                    
                    if let size = self?.itemView.bounds.size {
                        animatedImageView.bounds.size = size
                    }
                    
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
        
        return false

    }
    
    // Reports the continuous progress of Swipe To Dismiss to the Gallery View Controller
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        //guard let swipingToDismissInProgress = swipingToDismiss else { return }
        guard keyPath == "contentOffset" else { return }
        
        let distanceToEdge: CGFloat
        let percentDistance: CGFloat
        /*
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
         */
    }
    
    public func closeDecorationViews(_ duration: TimeInterval) {
 
    }
}
