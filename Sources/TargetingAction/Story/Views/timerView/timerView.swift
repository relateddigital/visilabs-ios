//
//  timerView.swift
//  CleanyModal
//
//  Created by Orhun Akmil on 15.06.2022.
//

import UIKit

class timerView: UIView {

    @IBOutlet weak var upLabel: UILabel!
    @IBOutlet weak var downLabel: UILabel!
    @IBOutlet weak var hour1digitLabel: UIView!
    @IBOutlet weak var hour2digitLabel: UIView!
    @IBOutlet weak var minute1digitLabel: UIView!
    @IBOutlet weak var minute2digitLabel: UIView!
    @IBOutlet weak var second1digitLabel: UIView!
    @IBOutlet weak var second2digitLabel: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    

}
