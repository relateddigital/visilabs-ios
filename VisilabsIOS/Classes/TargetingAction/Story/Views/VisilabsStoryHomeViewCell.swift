//
//  VisilabsStoryHomeViewCell.swift
//  VisilabsIOS
//
//  Created by Egemen on 22.09.2020.
//

import UIKit

class VisilabsStoryHomeViewCell: UICollectionViewCell {
    
    func setAsLoadingCell(){
        self.profileNameLabel.text = "Loading"
        self.profileImageView.imageView.image = VisilabsHelper.getUIImage(named: "loading")
    }
    
    
    //MARK: - Public iVars
    var story: VisilabsStory? {
        didSet {
            self.profileNameLabel.text = story?.title
            if let picture = story?.smallImg {
                self.profileImageView.imageView.setImage(url: picture)
            }
        }
    }
    
    //MARK: -  Private ivars
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
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Private functions
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
