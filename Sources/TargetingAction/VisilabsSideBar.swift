//
//  VisilabsSideBar.swift
//  VisilabsIOS
//
//  Created by Orhun Akmil on 13.01.2022.
//

import Foundation

import UIKit

class visilabsSideBar {
    
    var addedView:UIView?
    
    func addSideBar() {
        
        let view: sideBarView = UIView.fromNib()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.addedView?.addSubview(view)
        let titleString = "üye ol!"
        view.titleLabel.text = setTextToLineByLine(text: titleString)
        view.titleLabel.font = view.titleLabel.font.withSize(50)
        view.titleLabel.textColor = .black
        view.backgroundColor = .red
        view.arrowImageView.tintColor = .white
        //view.titleLabel.font = UIFont(name: "", size: 25)
        //setLeft(view: view)
        setRight(view: view)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewClicked(_:)))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func viewClicked(_ sender: UITapGestureRecognizer? = nil) {
        print("view a basıldı")
    }
    
    func setTextToLineByLine(text:String) -> String {
        let characters = Array(text)
        var result : String = ""
        
        for element in characters {
            result += String(element) + "\n"
        }
        
        return result
    }
    
    func setLeft(view : sideBarView) {
        
        //saga bakan ok image ı set edilecek
        //view.arrowImageView.image = UIImage(named: <#T##String#>)
        
        NSLayoutConstraint.activate([view.centerYAnchor.constraint(equalTo: self.addedView!.centerYAnchor),view.leadingAnchor.constraint(equalTo: self.addedView!.leadingAnchor, constant: 0),view.widthAnchor.constraint(equalToConstant: 90)])
        
    }
    
    func setRight(view : UIView) {
        
        //sola bakan ok image ı set edilecek
        //view.arrowImageView.image = UIImage(named: <#T##String#>)

        NSLayoutConstraint.activate([view.centerYAnchor.constraint(equalTo: self.addedView!.centerYAnchor),view.trailingAnchor.constraint(equalTo: self.addedView!.trailingAnchor, constant: 0),view.widthAnchor.constraint(equalToConstant: 90)])
        
    }
}
