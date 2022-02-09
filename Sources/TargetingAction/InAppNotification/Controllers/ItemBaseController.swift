//
//  ItemBaseController.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 8.02.2022.
//


import UIKit

public protocol ItemView {

    var image: UIImage? { get set }
}

open class ItemBaseController<T: UIView>: UIViewController, ItemController, UIGestureRecognizerDelegate, UIScrollViewDelegate where T: ItemView {

    //UI
    public var itemView = T()
    let scrollView = UIScrollView()
    let activityIndicatorView = UIActivityIndicatorView(style: .white)

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
    fileprivate var doubleTapToZoomDuration = 0.15
    fileprivate var displacementDuration: TimeInterval = 0.55
    fileprivate var reverseDisplacementDuration: TimeInterval = 0.25
    fileprivate var itemFadeDuration: TimeInterval = 0.3
    fileprivate var displacementTimingCurve: UIView.AnimationCurve = .linear
    fileprivate var displacementSpringBounce: CGFloat = 0.7
    fileprivate let minimumZoomScale: CGFloat = 1
    fileprivate var maximumZoomScale: CGFloat = 8
    fileprivate var pagingMode: GalleryPagingMode = .standard
    fileprivate var thresholdVelocity: CGFloat = 500 // The speed of swipe needs to be at least this amount of pixels per second for the swipe to finish dismissal.
    fileprivate var displacementKeepOriginalInPlace = false
    fileprivate var displacementInsetMargin: CGFloat = 50
    fileprivate var swipeToDismissMode = GallerySwipeToDismissMode.always
    fileprivate var toggleDecorationViewBySingleTap = true
    fileprivate var activityViewByLongPress = true

    /// INTERACTIONS
    fileprivate var singleTapRecognizer: UITapGestureRecognizer?
    fileprivate var longPressRecognizer: UILongPressGestureRecognizer?
    fileprivate let doubleTapRecognizer = UITapGestureRecognizer()
    fileprivate let swipeToDismissRecognizer = UIPanGestureRecognizer()

    // TRANSITIONS
    fileprivate var swipeToDismissTransition: GallerySwipeToDismissTransition?


    // MARK: - Initializers

    public init(index: Int, itemCount: Int, fetchImageBlock: @escaping FetchImageBlock, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        self.index = index
        self.itemCount = itemCount
        self.isInitialController = isInitialController
        self.fetchImageBlock = fetchImageBlock

        for item in configuration {

            switch item {

            case .swipeToDismissThresholdVelocity(let velocity):    thresholdVelocity = velocity
            case .doubleTapToZoomDuration(let duration):            doubleTapToZoomDuration = duration
            case .presentationStyle(let style):                     presentationStyle = style
            case .pagingMode(let mode):                             pagingMode = mode
            case .displacementDuration(let duration):               displacementDuration = duration
            case .reverseDisplacementDuration(let duration):        reverseDisplacementDuration = duration
            case .displacementTimingCurve(let curve):               displacementTimingCurve = curve
            case .maximumZoomScale(let scale):                      maximumZoomScale = scale
            case .itemFadeDuration(let duration):                   itemFadeDuration = duration
            case .displacementKeepOriginalInPlace(let keep):        displacementKeepOriginalInPlace = keep
            case .displacementInsetMargin(let margin):              displacementInsetMargin = margin
            case .swipeToDismissMode(let mode):                     swipeToDismissMode = mode
            case .toggleDecorationViewsBySingleTap(let enabled):    toggleDecorationViewBySingleTap = enabled
            case .activityViewByLongPress(let enabled):             activityViewByLongPress = enabled
            case .spinnerColor(let color):                          activityIndicatorView.color = color
            case .spinnerStyle(let style):                          activityIndicatorView.style = style

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

        self.itemView.isHidden = isInitialController

        configureScrollView()
        configureGestureRecognizers()

        activityIndicatorView.hidesWhenStopped = true
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
        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.contentOffset = CGPoint.zero
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = max(maximumZoomScale, aspectFillZoomScale(forBoundingSize: self.view.bounds.size, contentSize: itemView.bounds.size))

        scrollView.delegate = self

        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }

    func configureGestureRecognizers() {

        doubleTapRecognizer.addTarget(self, action: #selector(scrollViewDidDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)

        if toggleDecorationViewBySingleTap == true {

            let singleTapRecognizer = UITapGestureRecognizer()

            singleTapRecognizer.addTarget(self, action: #selector(scrollViewDidSingleTap))
            singleTapRecognizer.numberOfTapsRequired = 1
            scrollView.addGestureRecognizer(singleTapRecognizer)
            singleTapRecognizer.require(toFail: doubleTapRecognizer)

            self.singleTapRecognizer = singleTapRecognizer
        }

        if activityViewByLongPress == true {

          let longPressRecognizer = UILongPressGestureRecognizer()

          longPressRecognizer.addTarget(self, action: #selector(scrollViewDidLongPress))
          scrollView.addGestureRecognizer(longPressRecognizer)

          self.longPressRecognizer = longPressRecognizer
        }

        if swipeToDismissMode != .never {

            swipeToDismissRecognizer.addTarget(self, action: #selector(scrollViewDidSwipeToDismiss))
            swipeToDismissRecognizer.delegate = self
            view.addGestureRecognizer(swipeToDismissRecognizer)
            swipeToDismissRecognizer.require(toFail: doubleTapRecognizer)
        }
    }

    fileprivate func createViewHierarchy() {

        self.view.addSubview(scrollView)
        

        
        scrollView.addSubview(itemView)

        activityIndicatorView.startAnimating()
        view.addSubview(activityIndicatorView)
    }

    // MARK: - View Controller Lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()

        createViewHierarchy()

        fetchImage()
    }

    public func fetchImage() {

        fetchImageBlock { [weak self] image in

            if let image = image {

                DispatchQueue.main.async {
                    self?.activityIndicatorView.stopAnimating()

                    var itemView = self?.itemView
                    itemView?.image = image
                    itemView?.isAccessibilityElement = image.isAccessibilityElement
                    itemView?.accessibilityLabel = image.accessibilityLabel
                    itemView?.accessibilityTraits = image.accessibilityTraits

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

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = self.view.bounds
        activityIndicatorView.center = view.boundsCenter

        if let size = itemView.image?.size , size != CGSize.zero {

            let aspectFitItemSize = aspectFitSize(forContentOfSize: size, inBounds: self.scrollView.bounds.size)

            itemView.bounds.size = aspectFitItemSize
            scrollView.contentSize = itemView.bounds.size
            

            itemView.center = scrollView.boundsCenter
            
        }
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {

        return itemView
    }

    // MARK: - Scroll View delegate methods

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {

        itemView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
    }

    @objc func scrollViewDidSingleTap() {

        self.delegate?.itemControllerDidSingleTap(self)
    }

    @objc func scrollViewDidLongPress() {

        self.delegate?.itemControllerDidLongPress(self, in: itemView)
    }

    @objc func scrollViewDidDoubleTap(_ recognizer: UITapGestureRecognizer) {

        let touchPoint = recognizer.location(ofTouch: 0, in: itemView)
        let aspectFillScale = aspectFillZoomScale(forBoundingSize: scrollView.bounds.size, contentSize: itemView.bounds.size)

        if (scrollView.zoomScale == 1.0 || scrollView.zoomScale > aspectFillScale) {

            let zoomRectangle = zoomRect(ForScrollView: scrollView, scale: aspectFillScale, center: touchPoint)

            UIView.animate(withDuration: doubleTapToZoomDuration, animations: { [weak self] in

                self?.scrollView.zoom(to: zoomRectangle, animated: false)
                })
        }
        else  {
            UIView.animate(withDuration: doubleTapToZoomDuration, animations: {  [weak self] in

                self?.scrollView.setZoomScale(1.0, animated: false)
                })
        }
    }

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

            self?.scrollView.zoomScale = self!.scrollView.minimumZoomScale

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

                    animatedImageView.bounds.size = self?.displacementTargetSize(forSize: image.size) ?? image.size
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

    func displacementTargetSize(forSize size: CGSize) -> CGSize {

        let boundingSize = rotationAdjustedBounds().size

        return aspectFitSize(forContentOfSize: size, inBounds: boundingSize)
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

                    self?.scrollView.zoomScale = 1

                    //rotate the image view
                    if UIApplication.isPortraitOnly == true {
                        self?.itemView.transform = deviceRotationTransform()
                    }

                    //position the image view to starting center
                    self?.itemView.bounds = displacedView.bounds
                    self?.itemView.center = displacedView.convert(displacedView.boundsCenter, to: self!.view)
                    self?.itemView.clipsToBounds = true
                    self?.itemView.contentMode = displacedView.contentMode

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



class ThumbnailCell: UICollectionViewCell {

    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        imageView.frame = bounds
        super.layoutSubviews()
    }
}

class ThumbnailsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationBarDelegate {

    fileprivate let reuseIdentifier = "ThumbnailCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate var isAnimating = false
    fileprivate let rotationAnimationDuration = 0.2

    var onItemSelected: ((Int) -> Void)?
    let layout = UICollectionViewFlowLayout()
    weak var itemsDataSource: GalleryItemsDataSource!
    var closeButton: UIButton?
    var closeLayout: ButtonLayout?

    required init(itemsDataSource: GalleryItemsDataSource) {
        self.itemsDataSource = itemsDataSource

        super.init(collectionViewLayout: layout)

        NotificationCenter.default.addObserver(self, selector: #selector(rotate), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func rotate() {
        guard UIApplication.isPortraitOnly else { return }

        guard UIDevice.current.orientation.isFlat == false &&
            isAnimating == false else { return }

        isAnimating = true

        UIView.animate(withDuration: rotationAnimationDuration, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: { [weak self] () -> Void in
            self?.view.transform = windowRotationTransform()
            self?.view.bounds = rotationAdjustedBounds()
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()

            })
        { [weak self] finished  in
            self?.isAnimating = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let screenWidth = self.view.frame.width
        layout.sectionInset = UIEdgeInsets(top: 50, left: 8, bottom: 8, right: 8)
        layout.itemSize = CGSize(width: screenWidth/3 - 8, height: screenWidth/3 - 8)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4

        self.collectionView?.register(ThumbnailCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        addCloseButton()
    }

    fileprivate func addCloseButton() {
        guard let closeButton = closeButton, let closeLayout = closeLayout else { return }

        switch closeLayout {
        case .pinRight(let marginTop, let marginRight):
            closeButton.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
            closeButton.frame.origin.x = self.view.bounds.size.width - marginRight - closeButton.bounds.size.width
            closeButton.frame.origin.y = marginTop
        case .pinLeft(let marginTop, let marginLeft):
            closeButton.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
            closeButton.frame.origin.x = marginLeft
            closeButton.frame.origin.y = marginTop
        }

        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)

        self.view.addSubview(closeButton)
    }

    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsDataSource.itemCount()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThumbnailCell

        let item = itemsDataSource.provideGalleryItem((indexPath as NSIndexPath).row)

        switch item {

        case .image(let fetchImageBlock):

            fetchImageBlock() { image in

                if let image = image {

                    cell.imageView.image = image
                }
            }

        case .video(let fetchImageBlock, _):

            fetchImageBlock() { image in

                if let image = image {

                    cell.imageView.image = image
                }
            }

        case .custom(let fetchImageBlock, _):

            fetchImageBlock() { image in

                if let image = image {

                    cell.imageView.image = image
                }
            }
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onItemSelected?((indexPath as NSIndexPath).row)
        close()
    }
}


import AVFoundation


class VideoView: UIView {

    let previewImageView = UIImageView()
    var image: UIImage? { didSet { previewImageView.image = image } }
    var player: AVPlayer? {

        willSet {

            if newValue == nil {

                player?.removeObserver(self, forKeyPath: "status")
                player?.removeObserver(self, forKeyPath: "rate")
            }
        }

        didSet {

            if  let player = self.player,
                let videoLayer = self.layer as? AVPlayerLayer {

                videoLayer.player = player
                videoLayer.videoGravity = AVLayerVideoGravity.resizeAspect

                player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
                player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
            }
        }
    }

    override class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(previewImageView)

        previewImageView.contentMode = .scaleAspectFill
        previewImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        previewImageView.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {

        player?.removeObserver(self, forKeyPath: "status")
        player?.removeObserver(self, forKeyPath: "rate")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if let status = self.player?.status, let rate = self.player?.rate  {

            if status == .readyToPlay && rate != 0 {

                UIView.animate(withDuration: 0.3, animations: { [weak self] in

                    if let strongSelf = self {

                        strongSelf.previewImageView.alpha = 0
                    }
                })
            }
        }
    }
}



extension VideoView: ItemView {}

class VideoViewController: ItemBaseController<VideoView> {

    fileprivate let swipeToDismissFadeOutAccelerationFactor: CGFloat = 6

    let videoURL: URL
    let player: AVPlayer
    unowned let scrubber: VideoScrubber

    let fullHDScreenSizeLandscape = CGSize(width: 1920, height: 1080)
    let fullHDScreenSizePortrait = CGSize(width: 1080, height: 1920)
    let embeddedPlayButton = UIButton.circlePlayButton(70)
    
    private var autoPlayStarted: Bool = false
    private var autoPlayEnabled: Bool = false

    init(index: Int, itemCount: Int, fetchImageBlock: @escaping FetchImageBlock, videoURL: URL, scrubber: VideoScrubber, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        self.videoURL = videoURL
        self.scrubber = scrubber
        self.player = AVPlayer(url: self.videoURL)
        
        ///Only those options relevant to the paging VideoViewController are explicitly handled here, the rest is handled by ItemViewControllers
        for item in configuration {
            
            switch item {
                
            case .videoAutoPlay(let enabled):
                autoPlayEnabled = enabled
                
            default: break
            }
        }

        super.init(index: index, itemCount: itemCount, fetchImageBlock: fetchImageBlock, configuration: configuration, isInitialController: isInitialController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if isInitialController == true { embeddedPlayButton.alpha = 0 }

        embeddedPlayButton.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        self.view.addSubview(embeddedPlayButton)
        embeddedPlayButton.center = self.view.boundsCenter

        embeddedPlayButton.addTarget(self, action: #selector(playVideoInitially), for: UIControl.Event.touchUpInside)

        self.itemView.player = player
        self.itemView.contentMode = .scaleAspectFill
    }

    override func viewWillAppear(_ animated: Bool) {

        self.player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        self.player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)

        UIApplication.shared.beginReceivingRemoteControlEvents()

        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {

        self.player.removeObserver(self, forKeyPath: "status")
        self.player.removeObserver(self, forKeyPath: "rate")

        UIApplication.shared.endReceivingRemoteControlEvents()

        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        performAutoPlay()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.player.pause()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let isLandscape = itemView.bounds.width >= itemView.bounds.height
        itemView.bounds.size = aspectFitSize(forContentOfSize: isLandscape ? fullHDScreenSizeLandscape : fullHDScreenSizePortrait, inBounds: self.scrollView.bounds.size)
        itemView.center = scrollView.boundsCenter
    }

    @objc func playVideoInitially() {

        self.player.play()


        UIView.animate(withDuration: 0.25, animations: { [weak self] in

            self?.embeddedPlayButton.alpha = 0

        }, completion: { [weak self] _ in

            self?.embeddedPlayButton.isHidden = true
        })
    }

    override func closeDecorationViews(_ duration: TimeInterval) {

        UIView.animate(withDuration: duration, animations: { [weak self] in

            self?.embeddedPlayButton.alpha = 0
            self?.itemView.previewImageView.alpha = 1
        })
    }

    override func presentItem(alongsideAnimation: () -> Void, completion: @escaping () -> Void) {

        itemView.leading(to: self.view, offset: 10, relation: .equal, priority: .required, isActive: true)
        itemView.trailing(to: self.view, offset: -10, relation: .equal, priority: .required, isActive: true)
        
        let circleButtonAnimation = {

            UIView.animate(withDuration: 0.15, animations: { [weak self] in
                self?.embeddedPlayButton.alpha = 1
            })
        }

        super.presentItem(alongsideAnimation: alongsideAnimation) {

            circleButtonAnimation()
            completion()
        }
    }

    override func displacementTargetSize(forSize size: CGSize) -> CGSize {

        let isLandscape = itemView.bounds.width >= itemView.bounds.height
        return aspectFitSize(forContentOfSize: isLandscape ? fullHDScreenSizeLandscape : fullHDScreenSizePortrait, inBounds: rotationAdjustedBounds().size)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if keyPath == "rate" || keyPath == "status" {

            fadeOutEmbeddedPlayButton()
        }

        else if keyPath == "contentOffset" {

            handleSwipeToDismissTransition()
        }

        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

    func handleSwipeToDismissTransition() {

        guard let _ = swipingToDismiss else { return }

        embeddedPlayButton.center.y = view.center.y - scrollView.contentOffset.y
    }

    func fadeOutEmbeddedPlayButton() {

        if player.isPlaying() && embeddedPlayButton.alpha != 0  {

            UIView.animate(withDuration: 0.3, animations: { [weak self] in

                self?.embeddedPlayButton.alpha = 0
            })
        }
    }

    override func remoteControlReceived(with event: UIEvent?) {

        if let event = event {

            if event.type == UIEvent.EventType.remoteControl {

                switch event.subtype {

                case .remoteControlTogglePlayPause:

                    if self.player.isPlaying()  {

                        self.player.pause()
                    }
                    else {

                        self.player.play()
                    }

                case .remoteControlPause:

                    self.player.pause()

                case .remoteControlPlay:

                    self.player.play()

                case .remoteControlPreviousTrack:

                    self.player.pause()
                    self.player.seek(to: CMTime(value: 0, timescale: 1))
                    self.player.play()

                default:

                    break
                }
            }
        }
    }
    
    private func performAutoPlay() {
        guard autoPlayEnabled else { return }
        guard autoPlayStarted == false else { return }
        
        autoPlayStarted = true
        embeddedPlayButton.isHidden = true
        scrubber.play()
    }
}


extension UIImageView: ItemView {}

class ImageViewController: ItemBaseController<UIImageView> {
}
