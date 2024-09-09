//
//  StarsViewController.swift
//  RelatedDigitalExample
//
//  Created by Orhun Akmil on 9.09.2024.
//

import UIKit

class StarsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let starsStackView = UIStackView()
        starsStackView.axis = .vertical
        starsStackView.alignment = .center
        starsStackView.spacing = 10
        
        for i in 1...10 {
            let starButton = UIButton(type: .system)
            starButton.setTitle("⭐️", for: .normal)
            starButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
            starButton.tag = i // Her butona bir tag veriyoruz
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starsStackView.addArrangedSubview(starButton)
        }
        
        view.addSubview(starsStackView)
        
        starsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            starsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func starTapped(_ sender: UIButton) {
        let starIndex = sender.tag
        print("Yıldız \(starIndex) tıklandı!")

    }
}
