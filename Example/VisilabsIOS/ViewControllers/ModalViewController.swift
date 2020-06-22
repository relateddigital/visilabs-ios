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
    var textRow : TextRow!


    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var colorPickerView: ColorPicker!
    @IBOutlet weak var selectButton: UIButton!
    
    var colorSpace: HRColorSpace = .sRGB

    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.clipsToBounds = true
        popupView.layer.cornerRadius = 6

        /*
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
*/
    
        super.viewDidLoad()
        colorPickerView.addTarget(self, action: #selector(self.handleColorChanged(picker:)), for: .valueChanged)
        colorPickerView.set(color: selectedColor, colorSpace: colorSpace)
        headerLabel.text = headerText
        //updateColorSpaceText()
        //handleColorChanged(picker: popupView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.dismiss(animated: true, completion: nil)
        }
 */
    }

    /*
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
 */
    
    @IBAction func handleSelect(_ sender: Any) {
        self.textRow.value = colorPickerView.color.toHexString()
        self.textRow.updateCell()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleColorChanged(picker: ColorPicker) {
        let color = picker.color
        //label.text = picker.color.description
    }
    
    /*
    

    @IBAction func handleRedButtonAction(_ sender: UIButton) {
        colorPicker.set(color: .red, colorSpace: colorSpace)
        handleColorChanged(picker: colorPicker)
    }

    @IBAction func handlePurpleButtonAction(_ sender: UIButton) {
        colorPicker.set(color: .purple, colorSpace: colorSpace)
        handleColorChanged(picker: colorPicker)
    }

    @IBAction func handleYellowButtonAction(_ sender: UIButton) {
        colorPicker.set(color: .yellow, colorSpace: colorSpace)
        handleColorChanged(picker: colorPicker)
    }

    @IBAction func handleSwitchAction(_ sender: UISwitch) {
        colorSpace = sender.isOn ? .extendedSRGB : .sRGB
        colorPicker.set(color: colorPicker.color, colorSpace: colorSpace)
        updateColorSpaceText()
        handleColorChanged(picker: colorPicker)
    }

    func updateColorSpaceText() {
        switch colorSpace {
        case .extendedSRGB:
            colorSpaceLabel.text = "Extended sRGB"
        case .sRGB:
            colorSpaceLabel.text = "sRGB"
        }
    }
     */

}

