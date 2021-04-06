//
//  ShakeToWinViewController.swift
//  VisilabsIOS
//
//  Created by Said Alır on 5.04.2021.
//

import UIKit

public class ShakeToWinViewController: UIViewController {
    
    lazy var model: ShakeToWinViewModel? = createDummyModel()
    let scrollView = UIScrollView()

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

    lazy var closeButton: UIButton = {
       let button = UIButton()
        button.setImage(getUIImage(named: "VisilabsCloseButton@3x"), for: .normal)
        return button
    }()
    
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
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
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
            
        }
    }
    
    func prepareFirstPage() -> UIView {
        let page = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: view.frame.width,
                                        height: view.frame.height))
        
        if let firstPage = model?.firstPage {
            var imageAdded = false
            if let img = firstPage.image {
                let imageView = UIImageView(frame: .zero)
                imageView.image = img
                imageView.top(to: page, offset: 20)
                imageView.centerX(to: page)
                imageAdded = true
            }
        }
        
        page.backgroundColor = .red
        page.addSubview(closeButton)
        closeButton.top(to: page, offset: 40)
        closeButton.trailing(to: page, offset: -40)
        closeButton.width(40)
        closeButton.height(40)
        
        return page
    }
}

extension ShakeToWinViewController {
    
    func createDummyModel() -> ShakeToWinViewModel? {
        return nil
    }
}
