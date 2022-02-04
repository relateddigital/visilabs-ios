//
//  VisilabsCarouselNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Said Alır on 30.03.2021.
//

import UIKit

class RelatedDigitalCarouselNotificationViewController: RelatedDigitalBaseNotificationViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    private let PGCONTROLHEIGHT: CGFloat = 50
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 5
        return pc
    }()
    
    let scrollView = UIScrollView()
    var pages: [CarouselViewModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(pageControl)
        self.view.addSubview(scrollView)
        pageControl.addTarget(self, action: #selector(pageDidChange(_:)), for: .valueChanged)
        
        scrollView.delegate = self
        view.bringSubviewToFront(closeButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageControl.frame = CGRect(x: 20, y: view.frame.size.height - PGCONTROLHEIGHT + 10, width: view.frame.size.width-40, height: PGCONTROLHEIGHT - 20)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - PGCONTROLHEIGHT)
        
        if let pgs = self.pages, scrollView.subviews.count == 2 {
            configureScrollView(pgs.count)
        }
    }

    convenience init(notification: RelatedDigitalInAppNotification) {
        self.init(notification: notification,
                  nameOfClass: String(describing: RelatedDigitalCarouselNotificationViewController.notificationXibToLoad()))
    }

    static func notificationXibToLoad() -> String {
        let xibName = String(describing: RelatedDigitalCarouselNotificationViewController.self)
        guard RelatedDigitalInstance.sharedUIApplication() != nil else {
            return xibName
        }
        return xibName
    }

    override func show(animated: Bool) {
        guard let sharedUIApplication = RelatedDigitalInstance.sharedUIApplication() else {
            return
        }
        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first
            if let windowScene = windowScene as? UIWindowScene {
                window = UIWindow(frame: windowScene.coordinateSpace.bounds)
                window?.windowScene = windowScene
            }
        } else {
            window = UIWindow(frame: CGRect(x: 0,
                                            y: 0,
                                            width: UIScreen.main.bounds.size.width,
                                            height: UIScreen.main.bounds.size.height))
        }
        if let window = window {
            window.alpha = 0
            window.windowLevel = UIWindow.Level.alert
            window.rootViewController = self
            window.isHidden = false
        }

        let duration = animated ? 0.25 : 0
        UIView.animate(withDuration: duration, animations: {
            self.window?.alpha = 1
            }, completion: { _ in
        })
    }

    override func hide(animated: Bool, completion: @escaping () -> Void) {
        let duration = animated ? 0.25 : 0
        UIView.animate(withDuration: duration, animations: {
            self.window?.alpha = 0
            }, completion: { _ in
                self.window?.isHidden = true
                self.window?.removeFromSuperview()
                self.window = nil
                completion()
        })
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: false, additionalTrackingProperties: nil)
    }
    
    @objc func pageDidChange(_ sender: UIPageControl) {
        let current = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: CGFloat(current) * self.view.frame.size.width, y: 0), animated: true)
    }
    
    func configureScrollView(_ count: Int) {
        scrollView.contentSize = CGSize(width: self.view.frame.size.width * CGFloat(count), height: self.view.frame.size.height - PGCONTROLHEIGHT)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        let colors: [UIColor] = [.blue, .red, .systemGreen, .systemTeal, .magenta]
        
        for i in 0..<count {
            let page = configurePage(i)
            page.backgroundColor = colors[i]
            scrollView.addSubview(page)
        }
    }
    
    func configurePage(_ count: Int) -> UIView {
        guard let pgs = self.pages else { return UIView() }
        guard count < pgs.count else { return UIView() }
        let currentPage = pgs[count]
        let page = UIView(frame: CGRect(x: CGFloat(count) * view.frame.size.width, y: 0, width: view.frame.size.width, height: scrollView.frame.size.height))
    
        let title = UILabel(frame: .zero)
        title.text = currentPage.title
        title.font = currentPage.titleFont
        title.textColor = currentPage.titleColor ?? .black
        
        let message = UILabel(frame: .zero)
        message.text = currentPage.message
        message.font = currentPage.messageFont
        message.textColor = currentPage.messageColor ?? .black
        
        page.addSubview(title)
        page.addSubview(message)
        
        title.leading(to: page, offset: 20)
        title.trailing(to: page, offset: -20)
        title.centerY(to: page)
        title.height(30.0)
        
        message.topToBottom(of: title, offset: 20)
        message.leading(to: page, offset: 20)
        message.trailing(to: page, offset: -20)
        message.height(30.0)
    
        if let img = currentPage.image {
            let imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: view.frame.size.width - 20, height: 300.0))
            imageView.image = img
            page.addSubview(imageView)
            
            title.topToBottom(of: imageView, offset: 20, priority: .required)
        }
        
        if let _ = currentPage.buttonLink {
            let button = UIButton(frame: .zero)
            button.addSubview(page)
            button.titleLabel?.font = currentPage.buttonFont
            button.titleLabel?.textColor = currentPage.buttonTextColor
            button.titleLabel?.textAlignment = .center
            button.setTitle(currentPage.buttonText, for: .normal)
            button.backgroundColor = currentPage.buttonBgColor
            
            button.topToBottom(of: message, offset: 20, relation: .equalOrGreater)
            button.bottom(to: page, offset: 20, relation: .equal)
            button.leading(to: page, offset: 50)
            button.trailing(to: page, offset: -50)
            button.height(80.0)
            
            button.tag = count
            button.addTarget(self, action: #selector(openButtonUrl(sender:)), for: .touchUpInside)
        }
        
        return page
    }
    
    @objc func openButtonUrl(sender: UIButton) {
        let tag = sender.tag
        guard let pgs = self.pages, let url = pgs[tag].buttonLink else { return }
        let app = RelatedDigitalInstance.sharedUIApplication()
        app?.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: url, waitUntilDone: true)
    }
}

extension RelatedDigitalCarouselNotificationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame.size.width != 0 else {
            return
        }
        pageControl.currentPage = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.size.width)))
    }
}
