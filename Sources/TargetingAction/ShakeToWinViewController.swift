//
//  ShakeToWinViewController.swift
//  VisilabsIOS
//
//  Created by Said Alır on 5.04.2021.
//

import UIKit
import AVFoundation

public class ShakeToWinViewController: UIViewController {
    
    lazy var model: ShakeToWinViewModel? = createDummyModel()
    let scrollView = UIScrollView()
    weak var player: AVPlayer? = nil
    var openedSecondPage = false {
        didSet {
            self.deviceDidntShake()
        }
    }
    
    var didShake = false {
        didSet {
            self.openThirdPage(self.model?.secondPage.waitSeconds ?? 0)
        }
    }

    lazy var mainButton: UIButton = {
        let button = UIButton()
        button.setTitle(model?.firstPage.buttonText, for: .normal)
        button.backgroundColor = model?.firstPage.buttonBgColor
        button.titleLabel?.font = model?.firstPage.buttonFont
        button.titleLabel?.textColor = model?.firstPage.buttonTextColor
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(scrollView)
    }
    
    public override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake && openedSecondPage && !didShake {
            self.didShake = true
        }
    }
    
    public override func viewDidLayoutSubviews() {
        scrollView.frame = self.view.frame
        if scrollView.subviews.count == 2 {
            configureScrollView()
        }
    }
    
    func configureScrollView() {
        scrollView.contentSize = CGSize(width: view.frame.width*3, height: view.frame.height)
        scrollView.isPagingEnabled = false
        scrollView.isScrollEnabled = false
        
        scrollView.addSubview(prepareFirstPage())
        scrollView.addSubview(prepareSecondPage())
        scrollView.addSubview(prepareThirdPage())
    }
    
    @objc func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getUIImage(named: String) -> UIImage? {
        let bundle = Bundle(identifier: "com.relateddigital.visilabs")
        return UIImage(named: named, in: bundle, compatibleWith: nil)!.resized(withPercentage: CGFloat(0.75))
    }
    
    func deviceDidntShake() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            if self.didShake == false {
                self.openThirdPage(0)
            }
        })
    }
    
    func openThirdPage(_ delay: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(delay)) {
            self.scrollView.setContentOffset(CGPoint(x: self.view.frame.size.width*2, y: 0.0), animated: true)
            if let p = self.player {
                p.pause()
                self.player = nil
            }
        }
    }
    
    func prepareFirstPage() -> UIView {
        let page = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: view.frame.width,
                                        height: view.frame.height))
        
        var imageView = UIImageView(frame: .zero)
        
        if let firstPage = model?.firstPage {
            var imageAdded = false
            if let img = firstPage.image {
                imageView = UIImageView(frame: .zero)
                imageView.image = img
                page.addSubview(imageView)
                imageView.top(to: page, offset: 20)
                imageView.centerX(to: page)
                imageView.height(imageView.image?.size.height ?? 0.0)
                imageView.width(imageView.image?.size.width ?? 0.0)
                page.bringSubviewToFront(imageView)
                imageAdded = true
            }
            let title = UILabel(frame: .zero)
            title.text = model?.firstPage.title
            title.textColor = model?.firstPage.titleColor
            title.font = model?.firstPage.titleFont
            title.numberOfLines = 0
            page.addSubview(title)
            title.height(40.0)
            title.centerX(to: page)
            if imageAdded {
                title.topToBottom(of: imageView, offset: 10)
            } else {
                title.top(to: page, offset: 20)
            }
            
            let message = UILabel(frame: .zero)
            message.text = model?.firstPage.message
            message.textColor = model?.firstPage.messageColor
            message.font = model?.firstPage.messageFont
            message.numberOfLines = 0
            page.addSubview(message)
            
            message.centerX(to: page)
            message.topToBottom(of: title, offset: 5)
            message.height(40.0)
            
            let button = UIButton(frame: .zero)
            button.setTitle(model?.firstPage.buttonText, for: .normal)
            button.setTitleColor(model?.firstPage.buttonTextColor, for: .normal)
            button.titleLabel?.font = model?.firstPage.buttonFont
            button.backgroundColor = model?.firstPage.buttonBgColor
            page.addSubview(button)
            
            button.height(60.0)
            button.centerX(to: page)
            button.topToBottom(of: message, offset: 10)
            button.bottom(to: page, offset: -20)
            button.width(120.0)
            
            button.addTarget(self, action: #selector(goSecondPage), for: .touchUpInside)
        }
        
        page.backgroundColor = .red
        let close = getCloseButton(.black)
        page.addSubview(close)
        close.top(to: page, offset: 40)
        close.trailing(to: page, offset: -20)
        close.width(40)
        close.height(40)
        
        return page
    }
    
    func prepareSecondPage() -> UIView {
        let page = UIView(frame: CGRect(x: view.frame.width,
                                        y: 0,
                                        width: view.frame.width,
                                        height: view.frame.height))
        
    
        page.backgroundColor = .green
        let close = getCloseButton(.white)
        page.addSubview(close)
        close.top(to: page, offset: 40)
        close.trailing(to: page, offset: -20)
        close.width(40)
        close.height(40)
        close.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        
        if let videoUrl = model?.secondPage.videoURL {
            let player = AVPlayer(url: videoUrl)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = page.bounds
            page.layer.addSublayer(playerLayer)
            self.player = player
        }
        return page
    }
    
    func prepareThirdPage() -> UIView {
        let page = UIView(frame: CGRect(x: view.frame.width*2,
                                        y: 0,
                                        width: view.frame.width,
                                        height: view.frame.height))
        page.backgroundColor = .blue
        let close = getCloseButton(.white)
        page.addSubview(close)
        close.top(to: page, offset: 40)
        close.trailing(to: page, offset: -20)
        close.width(40)
        close.height(40)
        return page
    }
}

extension ShakeToWinViewController {
    
    func createDummyModel() -> ShakeToWinViewModel? {
        var img: UIImage? = nil
        if let data = getImageDataOfUrl(URL(string: "https://placekitten.com/300/500")) {
            img = UIImage(data: data)
        }
        return ShakeToWinViewModel(firstPage: ShakeToWinFirstPage(image: img, title: "shtw first page", titleFont: .boldSystemFont(ofSize: 16), titleColor: .yellow, message: "shtw message \n message can be plural", messageColor: .white, messageFont: .systemFont(ofSize: 12), buttonText: "hit me for next", buttonTextColor: .blue, buttonFont: .boldSystemFont(ofSize: 16), buttonBgColor: .white, backgroundColor: .green, closeButtonColor: .white),
                                   secondPage: ShakeToWinSecondPage(waitSeconds: 8, videoURL: URL(string: "https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4"), closeButtonColor: .white),
                                   thirdPage: ShakeToWinThirdPage(image: nil, title: "third page", titleFont: .boldSystemFont(ofSize: 16), titleColor: .darkGray, message: "shtw message \n message can be plural", messageColor: .blue, messageFont: .italicSystemFont(ofSize: 12), buttonText: "finish", buttonTextColor: .white, buttonFont: .boldSystemFont(ofSize: 16), buttonBgColor: .black, backgroundColor: .systemPink, closeButtonColor: .white))
    }
    
    @objc func goSecondPage() {
        scrollView.setContentOffset(CGPoint(x: view.frame.size.width, y: 0.0), animated: true)
        self.openedSecondPage = true
        if let p = self.player {
            p.play()
        }
    }
    
    func getCloseButton(_ color: ButtonColor) -> UIButton  {
        let button = UIButton()
        button.setImage(getUIImage(named: "VisilabsCloseButton"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        if color == .black {
            button.setImage(getUIImage(named: "VisilabsCloseButtonBlack"), for: .normal)
        }
        return button
    }
    
    func getImageDataOfUrl(_ url: URL?) -> Data? {
        var data: Data? = nil
        if let iUrl = url {
            do {
                data = try Data(contentsOf: iUrl, options: [.mappedIfSafe])
            } catch {
                VisilabsLogger.error("image failed to load from url \(iUrl)")
            }
        }
        return data
    }
}
