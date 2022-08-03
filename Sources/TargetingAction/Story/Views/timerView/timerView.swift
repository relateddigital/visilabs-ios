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
    
    @IBOutlet weak var week1digitLabelView: UIView!
    @IBOutlet weak var week2digitLabelView: UIView!
    @IBOutlet weak var day1digitLabelView: UIView!
    @IBOutlet weak var day2digitLabelView: UIView!
    @IBOutlet weak var hour1digitLabelView: UIView!
    @IBOutlet weak var hour2digitLabelView: UIView!
    @IBOutlet weak var minute1digitLabelView: UIView!
    @IBOutlet weak var minute2digitLabelView: UIView!
    @IBOutlet weak var second1digitLabelView: UIView!
    @IBOutlet weak var second2digitLabelView: UIView!
    
    @IBOutlet weak var week1digitLabel: UILabel!
    @IBOutlet weak var week2digitLabel: UILabel!
    @IBOutlet weak var day1digitLabel: UILabel!
    @IBOutlet weak var day2digitLabel: UILabel!
    @IBOutlet weak var hour1digitLabel: UILabel!
    @IBOutlet weak var hour2digitLabel: UILabel!
    @IBOutlet weak var minute1digitLabel: UILabel!
    @IBOutlet weak var minute2digitLabel: UILabel!
    @IBOutlet weak var second1digitLabel: UILabel!
    @IBOutlet weak var second2digitLabel: UILabel!
    
    @IBOutlet weak var minutePointLabel: UILabel!
    @IBOutlet weak var dayPointLabel: UILabel!
    @IBOutlet weak var countDownTimerView: UIView!
    @IBOutlet weak var gifImageView: UIImageView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    

}
