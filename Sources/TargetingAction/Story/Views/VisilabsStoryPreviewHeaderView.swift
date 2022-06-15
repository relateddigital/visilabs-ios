//
//  VisilabsStoryPreviewHeaderView.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.10.2020.
//

import UIKit

protocol StoryPreviewHeaderProtocol: AnyObject {func didTapCloseButton()}

private let maxSnaps = 30

// Identifiers
public let progressIndicatorViewTag = 88
public let progressViewTag = 99

final class VisilabsStoryPreviewHeaderView: UIView {

    // MARK: - iVars
    public weak var delegate: StoryPreviewHeaderProtocol?
    fileprivate var snapsPerStory: Int = 0
    public var story: VisilabsStory? {
        didSet {
            snapsPerStory  = (story?.items.count)! < maxSnaps ? (story?.items.count)! : maxSnaps
        }
    }
    fileprivate var progressView: UIView?
    internal let snaperImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let detailView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let snaperNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        // TO_DO: server'dan siyah ya da beyaz seçeneği gelecek.
        if let closeButtonImage = VisilabsHelper.getUIImage(named: "VisilabsCloseButton") {
            button.setImage(closeButtonImage, for: .normal)
        }
        button.addTarget(self, action: #selector(didTapClose(_:)), for: .touchUpInside)
        return button
    }()
    public var getProgressView: UIView {
        if let progressView = self.progressView {
            return progressView
        }
        let progress = UIView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        self.progressView = progress
        self.addSubview(self.getProgressView)
        return progress
    }

    // MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        applyShadowOffset()
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

    
    
    // MARK: - Private functions
    private func loadUIElements() {
        backgroundColor = .clear
        addSubview(getProgressView)
        addSubview(snaperImageView)
        addSubview(detailView)
        setStoryTitleLabelProperties(fontFamily: storyCustomVariables.shared.fontFamily, customFont: storyCustomVariables.shared.customFontFamilyIos, labelColor: storyCustomVariables.shared.storyzLabelColor, labelStory: snaperNameLabel)
        detailView.addSubview(snaperNameLabel)
        addSubview(closeButton)
    }
    
    func setStoryTitleLabelProperties(fontFamily: String?,customFont:String? = "",labelColor:String?,labelStory:UILabel?) {

        if let color = UIColor(hex: labelColor) {
            labelStory?.textColor = color
        } else {
            labelStory?.textColor = .black
        }
        var finalFont = labelStory?.font
        if let font = fontFamily {
            if #available(iOS 13.0, *) {
                if font.lowercased() == "serif" || font.lowercased() == "sansserif" {
                    finalFont = UIFont(descriptor: (labelStory?.font.fontDescriptor.withDesign(.serif))!, size: labelStory?.font.pointSize ?? 8)
                } else if font.lowercased() == "monospace" {
                    finalFont = UIFont(descriptor: (labelStory?.font.fontDescriptor.withDesign(.monospaced))!, size: labelStory?.font.pointSize ?? 8)
                }
            } else {
                if font.lowercased() == "serif" || font.lowercased() == "sansserif" {
                    if let fontTemp = UIFont(name: "GillSans-Bold", size: labelStory?.font.pointSize ?? 8) {
                        finalFont = fontTemp
                    }
                    if font.lowercased() == "sansserif" {
                        if let fontTemp = UIFont(name: "GillSans", size: labelStory?.font.pointSize ?? 8) {
                            finalFont = fontTemp
                        }
                    }
                } else if font.lowercased() == "monospace" {
                    if let fontTemp = UIFont(name: "CourierNewPS-BoldMT", size: labelStory?.font.pointSize ?? 8) {
                        finalFont = fontTemp
                    } else {
                        if let fontTemp = UIFont(name: "CourierNewPSMT", size: labelStory?.font.pointSize ?? 8) {
                            finalFont = fontTemp
                        }
                    }
                }
            }

            if let uiCustomFont = UIFont(name: customFont ?? "", size:labelStory?.font.pointSize ?? 8) {
                labelStory?.font = uiCustomFont
                return
            }
       }
        labelStory?.font = finalFont
    }
    private func installLayoutConstraints() {
        // Setting constraints for progressView
        let prgView = getProgressView
        NSLayoutConstraint.activate([
            prgView.igLeftAnchor.constraint(equalTo: self.igLeftAnchor),
            prgView.igTopAnchor.constraint(equalTo: self.igTopAnchor, constant: 8),
            self.igRightAnchor.constraint(equalTo: prgView.igRightAnchor),
            prgView.heightAnchor.constraint(equalToConstant: 10)
            ])

        // Setting constraints for snapperImageView
        NSLayoutConstraint.activate([
            snaperImageView.widthAnchor.constraint(equalToConstant: 40),
            snaperImageView.heightAnchor.constraint(equalToConstant: 40),
            snaperImageView.igLeftAnchor.constraint(equalTo: self.igLeftAnchor, constant: 10),
            snaperImageView.igCenterYAnchor.constraint(equalTo: self.igCenterYAnchor),
            detailView.igLeftAnchor.constraint(equalTo: snaperImageView.igRightAnchor, constant: 10)
            ])
        layoutIfNeeded() // To make snaperImageView round. Adding this to somewhere else will create constraint warnings.

        // Setting constraints for detailView
        NSLayoutConstraint.activate([
            detailView.igLeftAnchor.constraint(equalTo: snaperImageView.igRightAnchor, constant: 10),
            detailView.igCenterYAnchor.constraint(equalTo: snaperImageView.igCenterYAnchor),
            detailView.heightAnchor.constraint(equalToConstant: 40),
            closeButton.igLeftAnchor.constraint(equalTo: detailView.igRightAnchor, constant: 10)
            ])

        // Setting constraints for closeButton
        NSLayoutConstraint.activate([
            closeButton.igLeftAnchor.constraint(equalTo: detailView.igRightAnchor, constant: 10),
            closeButton.igCenterYAnchor.constraint(equalTo: self.igCenterYAnchor),
            closeButton.igRightAnchor.constraint(equalTo: self.igRightAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 60),
            closeButton.heightAnchor.constraint(equalToConstant: 80)
            ])

        // Setting constraints for snapperNameLabel
        NSLayoutConstraint.activate([
            snaperNameLabel.igLeftAnchor.constraint(equalTo: detailView.igLeftAnchor),
            snaperNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            snaperNameLabel.igCenterYAnchor.constraint(equalTo: detailView.igCenterYAnchor)
            ])
    }
    private func applyShadowOffset() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
    }
    private func applyProperties<T: UIView>(_ view: T, with tag: Int? = nil, alpha: CGFloat = 1.0) -> T {
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        if let tagValue = tag {
            view.tag = tagValue
        }
        return view
    }

    // MARK: - Selectors
    @objc func didTapClose(_ sender: UIButton) {
        delegate?.didTapCloseButton()
    }

    // MARK: - Public functions
    public func clearTheProgressorSubviews() {
        getProgressView.subviews.forEach { view in
            view.subviews.forEach {view in (view as? VisilabsSnapProgressView ?? VisilabsSnapProgressView())
                .stop()}
            view.removeFromSuperview()
        }
    }
    public func clearAllProgressors() {
        clearTheProgressorSubviews()
        getProgressView.removeFromSuperview()
        self.progressView = nil
    }
    public func clearSnapProgressor(at index: Int) {
        getProgressView.subviews[index].removeFromSuperview()
    }
    fileprivate func setConstraintsForIndicator(_ pvIndicatorArray: inout [VisilabsSnapProgressIndicatorView],
                                                _ padding: CGFloat, _ height: CGFloat) {
        // Setting Constraints for all progressView indicators
        for index in 0..<pvIndicatorArray.count {
            let pvIndicator = pvIndicatorArray[index]
            if index == 0 {
                pvIndicator.leftConstraiant =
                    pvIndicator.igLeftAnchor.constraint(equalTo: self.getProgressView.igLeftAnchor, constant: padding)
                NSLayoutConstraint.activate([
                    pvIndicator.leftConstraiant!,
                    pvIndicator.igCenterYAnchor.constraint(equalTo: self.getProgressView.igCenterYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height)
                ])
                if pvIndicatorArray.count == 1 {
                    pvIndicator.rightConstraiant =
                        self.getProgressView.igRightAnchor.constraint(equalTo: pvIndicator.igRightAnchor,
                                                                      constant: padding)
                    pvIndicator.rightConstraiant!.isActive = true
                }
            } else {
                let prePVIndicator = pvIndicatorArray[index-1]
                pvIndicator.widthConstraint =
                    pvIndicator.widthAnchor.constraint(equalTo: prePVIndicator.widthAnchor, multiplier: 1.0)
                pvIndicator.leftConstraiant =
                    pvIndicator.igLeftAnchor.constraint(equalTo: prePVIndicator.igRightAnchor, constant: padding)
                NSLayoutConstraint.activate([
                    pvIndicator.leftConstraiant!,
                    pvIndicator.igCenterYAnchor.constraint(equalTo: prePVIndicator.igCenterYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height),
                    pvIndicator.widthConstraint!
                ])
                if index == pvIndicatorArray.count-1 {
                    pvIndicator.rightConstraiant =
                        self.igRightAnchor.constraint(equalTo: pvIndicator.igRightAnchor, constant: padding)
                    pvIndicator.rightConstraiant!.isActive = true
                }
            }
        }
    }

    fileprivate func setConstraintsForProgress(_ pvArray: inout [VisilabsSnapProgressView],
                                               _ pvIndicatorArray: inout [VisilabsSnapProgressIndicatorView]) {
        // Setting Constraints for all progressViews
        for index in 0..<pvArray.count {
            let prgView = pvArray[index]
            let pvIndicator = pvIndicatorArray[index]
            prgView.widthConstraint = prgView.widthAnchor.constraint(equalToConstant: 0)
            NSLayoutConstraint.activate([
                prgView.igLeftAnchor.constraint(equalTo: pvIndicator.igLeftAnchor),
                prgView.heightAnchor.constraint(equalTo: pvIndicator.heightAnchor),
                prgView.igTopAnchor.constraint(equalTo: pvIndicator.igTopAnchor),
                prgView.widthConstraint!
            ])
        }
    }

    fileprivate func addIndicatorAndProgressViews(_ pvIndicatorArray: inout [VisilabsSnapProgressIndicatorView],
                                                  _ pvArray: inout [VisilabsSnapProgressView]) {
        // Adding all ProgressView Indicator and ProgressView to seperate arrays
        for counter in 0 ..< snapsPerStory {
            let pvIndicator = VisilabsSnapProgressIndicatorView()
            pvIndicator.translatesAutoresizingMaskIntoConstraints = false
            getProgressView.addSubview(applyProperties(pvIndicator, with: counter+progressIndicatorViewTag, alpha: 0.2))
            pvIndicatorArray.append(pvIndicator)

            let prgView = VisilabsSnapProgressView()
            prgView.translatesAutoresizingMaskIntoConstraints = false
            pvIndicator.addSubview(applyProperties(prgView))
            pvArray.append(prgView)
        }
    }

    public func createSnapProgressors() {
        print("Progressor count: \(getProgressView.subviews.count)")
        let padding: CGFloat = 8 // GUI-Padding
        let height: CGFloat = 3
        var pvIndicatorArray: [VisilabsSnapProgressIndicatorView] = []
        var pvArray: [VisilabsSnapProgressView] = []

        addIndicatorAndProgressViews(&pvIndicatorArray, &pvArray)
        setConstraintsForIndicator(&pvIndicatorArray, padding, height)
        setConstraintsForProgress(&pvArray, &pvIndicatorArray)
        snaperNameLabel.text = story?.title
    }
}
