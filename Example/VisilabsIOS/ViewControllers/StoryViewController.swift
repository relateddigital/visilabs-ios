//
//  StoryViewController.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 25.08.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import VisilabsIOS

class StoryViewController: UIViewController {
    
    
    var stackView = UIStackView()
    var storyButton = UIButton()
    var storyHomeView : VisilabsStoryHomeView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureStackView()
        //addStoryButton()
    }
    
    private func configureStackView(){
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 20
        setStackViewConstraints()
        stackView.alignment = .fill
        view.addSubview(stackView)
        addStoryButton()
    }
    
    
    private func setStackViewConstraints(){
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: view.saferAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.saferAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.saferAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }
    
    
    private func addStoryButton(){
        //storyButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        storyButton.backgroundColor = UIColor.red
        storyButton.setTitle("Show Story", for: .normal)
        storyButton.addTarget(self, action: #selector(showStory), for: .touchUpInside)
        self.stackView.addArrangedSubview(storyButton)
    }
    
    @objc func showStory(sender: UIButton!) {
        storyHomeView?.removeFromSuperview()
        storyHomeView = Visilabs.callAPI().getStoryView()
        self.stackView.addArrangedSubview(storyHomeView!)
        print(self.stackView.subviews.count)
        print("Button tapped")
     }
    
}

extension UIView {
    var saferAreaLayoutGuide: UILayoutGuide {
        get {
            if #available(iOS 11.0, *) {
                return self.safeAreaLayoutGuide
            } else {
                return self.layoutMarginsGuide
            }
        }
    }
}
