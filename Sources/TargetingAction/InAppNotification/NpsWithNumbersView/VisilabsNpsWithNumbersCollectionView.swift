//
//  VisilabsNpsWithNumbersCollectionView.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 28.03.2023.
//

import Foundation
import UIKit

public class VisilabsNpsWithNumbersCollectionView: UIView {

    typealias NSLC = NSLayoutConstraint
    
    private func setBorderColorOfCell() -> UIColor {
        guard let bgColor = backgroundColor else { return .white }
        let red = bgColor.rgba.red
        let green = bgColor.rgba.green
        let blue = bgColor.rgba.blue
        let tot = red + green + blue
        if tot < 2.7 {
            return .white
        } else {
            return .black
        }
    }
    
    internal func baseSetup(_ notification: VisilabsInAppNotification) {
        if let bgColor = notification.backGroundColor {
            backgroundColor = bgColor
        }
        
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .brown
        imageView.isUserInteractionEnabled = true
        imageView.setImage(withUrl: notification.imageUrl)
        addSubview(imageView)

        titleLabel.text = notification.messageTitle?.removeEscapingCharacters()
        titleLabel.font = notification.messageTitleFont
        if let titleColor = notification.messageTitleColor {
            titleLabel.textColor = titleColor
        }
        messageLabel.text = notification.messageBody?.removeEscapingCharacters()
        messageLabel.font = notification.messageBodyFont
        if let bodyColor = notification.messageBodyColor {
            messageLabel.textColor = bodyColor
        }
        
        
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(numberRating)
        numberBorderColor = setBorderColorOfCell()
        guard let numberColors = inAppNotification?.numberColors else { return }
        guard let numberRange = inAppNotification?.numberRange else { return }
        if numberColors.count == 3 {
            colors = UIColor.getGradientColorArray(numberColors[0], numberColors[1], numberColors[2], numberRange)
        } else if numberColors.count == 2 {
            colors = UIColor.getGradientColorArray(numberColors[0], numberColors[1], numberRange)
        } else {
            numberBgColor = numberColors.first ?? .black
        }

        imageView.allEdges(to: self, excluding: .bottom)
        titleLabel.topToBottom(of: imageView, offset: 0.0)
        messageLabel.topToBottom(of: titleLabel, offset: 8.0)
        numberRating.topToBottom(of: messageLabel, offset: 10.0)
        numberRating.height(50.0)
        numberRating.leading(to: self, offset: 0)
        numberRating.trailing(to: self, offset: 0)
        numberRating.bottom(to: self, offset: -10.0)
        numberRating.backgroundColor = .magenta
        titleLabel.centerX(to: self)
        messageLabel.centerX(to: self)
        numberRating.delegate = self
        numberRating.dataSource = self
        
        if notification.videourl?.count ?? 0 > 0 {
            imageHeightConstraint?.constant = imageView.pv_heightForImageView(isVideoExist: true)
        } else {
            imageHeightConstraint?.constant = imageView.pv_heightForImageView(isVideoExist: false)
        }
        
    }


    internal func setTitleLabel() -> UILabel {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(white: 0.4, alpha: 1)
        titleLabel.font = .boldSystemFont(ofSize: 14)
        return titleLabel
    }
    
    internal func setMessageLabel() -> UILabel {
        let messageLabel = UILabel(frame: .zero)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = UIColor(white: 0.6, alpha: 1)
        messageLabel.font = .systemFont(ofSize: 14)
        return messageLabel
    }

    internal func setNumberRating() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 60.0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(RatingCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }

    // MARK: - VARIABLES

    internal var imageView: UIImageView!
    internal lazy var titleLabel = setTitleLabel()
    internal lazy var messageLabel = setMessageLabel()
    internal lazy var numberRating = setNumberRating()

    var colors: [[CGColor]] = []
    var numberBgColor: UIColor = .black
    var numberBorderColor: UIColor = .white
    var selectedNumber: Int?
    var expanded = false

    internal var imageHeightConstraint: NSLC?

    weak var inAppNotification: VisilabsInAppNotification?
    var consentCheckboxAdded = false
    weak var delegate: VisilabsNpsWithNumbersCollectionView?
    weak var npsDelegate: NPSDelegate?
    // MARK: - CONSTRUCTOR
    init(frame: CGRect, inAppNotification: VisilabsInAppNotification?) {
        self.inAppNotification = inAppNotification
        super.init(frame: frame)
        if self.inAppNotification != nil {
            setupViews()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func setupViews() {
        guard let notification = inAppNotification else {
            return
        }
        
        var constraints = [NSLC]()

        baseSetup(notification)

        imageHeightConstraint = NSLC(item: imageView,
            attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 0, constant: 0)

        if let imageHeightConstraint = imageHeightConstraint {
            constraints.append(imageHeightConstraint)
        }


        NSLC.activate(constraints)
    }

}

// MARK: - SliderStepDelegate

extension VisilabsNpsWithNumbersCollectionView: SliderStepDelegate {
    func didSelectedValue(sliderStep: VisilabsSliderStep, value: Float) {
        sliderStep.value = value
    }
}


extension VisilabsNpsWithNumbersCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberRange = inAppNotification?.numberRange
        var nWidth: CGFloat = 0.0
        if numberRange == "0-10" {
            nWidth = (numberRating.frame.width - 100) / 11
        } else {
            nWidth = (numberRating.frame.width - 100) / 10
        }

        return CGSize(width: nWidth, height: nWidth)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberRange = inAppNotification?.numberRange
        if numberRange == "0-10" {
            return 11
        } else {
            return 10
        }

    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RatingCollectionViewCell

        let numberRange = inAppNotification?.numberRange
        if numberRange == "0-10" {
            cell.rating = indexPath.row
        } else {
            cell.rating = indexPath.row + 1
        }

        cell.borderColor = numberBorderColor
        if colors.count == 11 || colors.count == 10 {
            cell.setGradient(colors: colors[indexPath.row])
        } else {
            cell.setBackgroundColor(numberBgColor)
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? RatingCollectionViewCell else {
            return
        }
        let numberRange = inAppNotification?.numberRange
        if cell.isSelected {
            if numberRange == "0-10" {
                selectedNumber = indexPath.row
            } else {
                selectedNumber = indexPath.row + 1
            }

            npsDelegate?.ratingSelected()
        } else {
            selectedNumber = 10
            npsDelegate?.ratingUnselected()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let numberRange = inAppNotification?.numberRange
        if numberRange == "0-10" {
            return 8
        } else {
            return 10
        }

    }
}

