//
//  VisilabsStoryHomeViewCell.swift
//  VisilabsIOS
//
//  Created by Egemen on 22.09.2020.
//

import UIKit

class VisilabsStoryHomeViewCell: UICollectionViewCell {

    func setAsLoadingCell() {
        self.profileNameLabel.text = "Loading"
        self.profileImageView.imageView.image = VisilabsHelper.getUIImage(named: "loading")
    }

    func setProperties(_ properties: VisilabsStoryActionExtendedProperties, _ actId: Int) {
        self.profileNameLabel.textColor = properties.labelColor
        var shown = false
        //check story has shown
        if let shownStories = UserDefaults.standard.dictionary(forKey: VisilabsConstants.shownStories) as? [String: [String]] {
            if let shownStoriesWithAction = shownStories["\(actId)"], shownStoriesWithAction.contains(self.story?.title ?? "-") {
                shown = true
            }
        }

        let borderColor = shown ? UIColor.gray : properties.imageBorderColor

        self.profileImageView.setBorder(borderColor: borderColor,
                                        borderWidth: properties.imageBorderWidth,
                                        borderRadius: properties.imageBorderRadius)
        if properties.imageBoxShadow {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.5
            self.layer.shadowOffset = CGSize(width: 5, height: 5)
            self.layer.shadowRadius = 10
        }
    }

    // MARK: - Public iVars
    var story: VisilabsStory? {
        didSet {
            self.profileNameLabel.text = story?.title
            if let picture = story?.smallImg {
                self.profileImageView.imageView.setImage(url: picture)
            }
        }
    }

    // MARK: - Private ivars
    private let profileImageView: VisilabsStoryRoundedView = {
        let roundedView = VisilabsStoryRoundedView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        return roundedView
    }()

    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    // MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private functions
    private func loadUIElements() {
        addSubview(profileImageView)
        addSubview(profileNameLabel)
    }
    private func installLayoutConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 68),
            profileImageView.heightAnchor.constraint(equalToConstant: 68),
            profileImageView.igTopAnchor.constraint(equalTo: self.igTopAnchor, constant: 8),
            profileImageView.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor)])

        NSLayoutConstraint.activate([
            profileNameLabel.igLeftAnchor.constraint(equalTo: self.igLeftAnchor),
            profileNameLabel.igRightAnchor.constraint(equalTo: self.igRightAnchor),
            profileNameLabel.igTopAnchor.constraint(equalTo: self.profileImageView.igBottomAnchor, constant: 2),
            profileNameLabel.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor),
            self.igBottomAnchor.constraint(equalTo: profileNameLabel.igBottomAnchor, constant: 8)])

        layoutIfNeeded()
    }
}
