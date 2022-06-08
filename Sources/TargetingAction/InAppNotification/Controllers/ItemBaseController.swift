//
//  ItemBaseController.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 8.02.2022.
//

import UIKit

public class ItemBaseController: UIViewController, ItemController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    public var itemView: VisilabsCarouselItemView
    public var visilabsInAppNotification: VisilabsInAppNotification!

    let scrollView = UIScrollView()
    public var footerView: UIPageControl?

    // DELEGATE / DATASOURCE
    public weak var delegate: ItemControllerDelegate?
    public weak var displacedViewsDataSource: GalleryDisplacedViewsDataSource?

    // STATE
    public let index: Int
    public var isInitialController = false
    fileprivate var isAnimating = false
    fileprivate var fetchImageBlock: FetchImageBlock?

    // CONFIGURATION
    fileprivate var displacementDuration: TimeInterval = 0.0 // 0.55
    fileprivate var reverseDisplacementDuration: TimeInterval = 0.0 // 0.25
    fileprivate var itemFadeDuration: TimeInterval = 0.3
    fileprivate var displacementSpringBounce: CGFloat = 0.7
    fileprivate var displacementKeepOriginalInPlace = false
    fileprivate var displacementInsetMargin: CGFloat = 0

    // MARK: - Initializers

    public init(index: Int, itemCount: Int, fetchImageBlock: FetchImageBlock?, visilabsCarouselItemView: VisilabsCarouselItemView
                , isInitialController: Bool = false, visilabsInAppNotification: VisilabsInAppNotification?) {
        self.visilabsInAppNotification = visilabsInAppNotification

        displacementKeepOriginalInPlace = false

        itemView = visilabsCarouselItemView

        self.index = index
        self.isInitialController = isInitialController
        self.fetchImageBlock = fetchImageBlock

        displacementSpringBounce = 1

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom

        // TODO: egemen
        itemView.imageView.isHidden = isInitialController

        configureScrollView()
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) { fatalError() }

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
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        view.addSubview(scrollView)
    }

    // MARK: - View Controller Lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()
        createViewHierarchy()
        fetchImage()
    }

    @objc func buttonTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        closeCarousel(shouldTrack: true, callToActionURL: itemView.visilabsCarouselItem?.linkUrl)
    }

    @objc func closeButtonTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        closeCarousel(shouldTrack: false, callToActionURL: nil)
    }

    public func fetchImage() {
        fetchImageBlock? { [weak self] image, backgroundImage, carouselItem in

            DispatchQueue.main.async { [self] in
                if let s = self {
                    s.itemView = VisilabsCarouselItemView(frame: .zero, visilabsCarouselItem: carouselItem)
                    s.scrollView.addSubview(s.itemView)

                    s.itemView.titleColor = carouselItem.titleColor
                    s.itemView.titleFont = carouselItem.titleFont
                    s.itemView.imageView.image = image
                    s.itemView.contentMode = .scaleAspectFill
                    s.itemView.centerYAnchor.constraint(equalTo: s.scrollView.centerYAnchor).isActive = true
                    if s.visilabsInAppNotification?.videourl?.count ?? 0 > 0 {
                        s.itemView.imageHeightConstraint?.constant = s.itemView.imageView.pv_heightForImageView(isVideoExist: true)
                    } else {
                        s.itemView.imageHeightConstraint?.constant = s.itemView.imageView.pv_heightForImageView(isVideoExist: false)
                    }
                    s.itemView.centerX(to: s.scrollView)
                    s.itemView.width(320.0)
                    s.itemView.isAccessibilityElement = true
                    s.scrollView.minimumZoomScale = 1.0
                    s.scrollView.maximumZoomScale = 1.0
                    s.itemView.translatesAutoresizingMaskIntoConstraints = false

                    if let bgColor = carouselItem.backgroundColor {
                        s.itemView.backgroundColor = bgColor
                    }

                    if let backgroundImage = backgroundImage {
                        s.itemView.backgroundColor = UIColor(patternImage: backgroundImage.aspectFittedToHeight(320.0))
                    }

                    if s.visilabsInAppNotification.closePopupActionType?.lowercased() != "backgroundclick" {
                        let closeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(s.closeButtonTapped(tapGestureRecognizer:)))
                        s.itemView.closeButton.isUserInteractionEnabled = true
                        s.itemView.closeButton.gestureRecognizers = []
                        s.itemView.closeButton.addGestureRecognizer(closeTapGestureRecognizer)
                    }

                    let buttonTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(s.buttonTapped(tapGestureRecognizer:)))
                    s.itemView.button.isUserInteractionEnabled = true
                    s.itemView.button.gestureRecognizers = []
                    s.itemView.button.addGestureRecognizer(buttonTapGestureRecognizer)

                    s.delegate?.fetchedImage(s)

                    self?.view.setNeedsLayout()
                    self?.view.layoutIfNeeded()
                }
            }
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.itemControllerWillAppear(self)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.itemControllerDidAppear(self)
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.itemControllerWillDisappear(self)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        if visilabsInAppNotification?.videourl?.count ?? 0 > 0 {
            itemView.imageHeightConstraint?.constant = itemView.imageView.pv_heightForImageView(isVideoExist: true)
        } else {
            itemView.imageHeightConstraint?.constant = itemView.imageView.pv_heightForImageView(isVideoExist: false)
        }
    }

    // MARK: - Present/Dismiss transitions

    public func presentItem(alongsideAnimation: () -> Void, completion: @escaping () -> Void) {
        itemView.width(320.0)
        guard isAnimating == false else { return }
        isAnimating = true

        alongsideAnimation()

        if var displacedView = displacedViewsDataSource?.provideDisplacementItem(atIndex: index) {
            // Prepare the animated imageView
            let animatedImageView = displacedView.getView()

            // rotate the imageView to starting angle
            if UIApplication.isPortraitOnly == true {
                animatedImageView.transform = deviceRotationTransform()
            }

            // position the image view to starting center
            animatedImageView.center = displacedView.convert(displacedView.boundsCenter, to: view)

            animatedImageView.clipsToBounds = true
            view.addSubview(animatedImageView)

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
        } else {
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
        let validAreaFrame = view.frame.insetBy(dx: displacementInsetMargin, dy: displacementInsetMargin)
        let isVisibleEnough = displacedViewFrame.intersects(validAreaFrame)
        return isVisibleEnough ? displacedView : nil
    }

    public func dismissItem(alongsideAnimation: () -> Void, completion: @escaping () -> Void) {
        guard isAnimating == false else { return }
        isAnimating = true
        alongsideAnimation()
        if var displacedView = findVisibleDisplacedView() {
            if displacementKeepOriginalInPlace == false {
                displacedView.isHidden = true
            }
            UIView.animate(withDuration: reverseDisplacementDuration, animations: { [weak self] in
                // rotate the image view
                if UIApplication.isPortraitOnly == true {
                    self?.itemView.transform = deviceRotationTransform()
                }
                self?.itemView.bounds = displacedView.bounds
                self?.itemView.center = displacedView.convert(displacedView.boundsCenter, to: self!.view)
                self?.itemView.clipsToBounds = true

            }, completion: { [weak self] _ in
                self?.isAnimating = false
                displacedView.isHidden = false
                completion()
            })
        }
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    public func closeCarousel(shouldTrack: Bool, callToActionURL: URL?) {
        delegate?.closeCarousel(shouldTrack: shouldTrack, callToActionURL: callToActionURL)
    }
}
