//
//  ModalViewController.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 17.06.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Colorful
import Eureka

class ModalViewController: UIViewController {

    var selectedColor = UIColor.black
    var headerText = "Header"
    var textRow: TextRow!

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var colorPickerView: ColorPicker!
    @IBOutlet weak var selectButton: UIButton!

    var colorSpace: HRColorSpace = .sRGB

    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.clipsToBounds = true
        popupView.layer.cornerRadius = 6
        super.viewDidLoad()
        colorPickerView.addTarget(self, action: #selector(self.handleColorChanged(picker:)), for: .valueChanged)
        colorPickerView.set(color: selectedColor, colorSpace: colorSpace)
        headerLabel.text = headerText
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func handleSelect(_ sender: Any) {
        self.textRow.value = colorPickerView.color.toHexString()
        self.textRow.updateCell()
        self.dismiss(animated: true, completion: nil)
    }

    @objc func handleColorChanged(picker: ColorPicker) {
        //let color = picker.color
    }
}
