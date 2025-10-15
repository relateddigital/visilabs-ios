//
//  RDChooseFavoriteCodeBannerView.swift
//  RelatedDigitalIOS
//
//  Created by Orhun Akmil on 3.07.2024.
//


import UIKit

class RDCustomWebCodeBannerView: UIView {

    var customWebViewModel: CustomWebViewModel

    var horizontalStackView: UIStackView!
    var verticalStackViewLeft: UIStackView!
    var verticalStackViewRight: UIStackView!
    var bannerTextLabel: UILabel!
    var bannerButtonLabel: UILabel!
    var bannerCodeLabel: UILabel!
    var closeButton: UIButton!

    init(frame: CGRect, customWebViewModel: CustomWebViewModel) {
        self.customWebViewModel = customWebViewModel
        super.init(frame: frame)
        setupLabels()
        setFonts()
        setColors()
        setCloseButton()
        layoutContent()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabels() {
        
        horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillProportionally
        
        var topEdge = 20.0
        if BannerCodeManager.shared.sdkTypeForBanner == "reactnative"
        {
            topEdge = -20.0
        }
        
        horizontalStackView.layoutMargins = UIEdgeInsets(top: topEdge, left: 8, bottom: 20, right: 0)

        verticalStackViewLeft = UIStackView()
        verticalStackViewLeft.axis = .vertical
        verticalStackViewLeft.distribution = .equalSpacing
        verticalStackViewLeft.spacing = 5.0
        verticalStackViewLeft.alignment = .center

        verticalStackViewRight = UIStackView()
        verticalStackViewRight.axis = .vertical
        verticalStackViewRight.distribution = .equalSpacing
        verticalStackViewRight.spacing = 0.0
        verticalStackViewRight.alignment = .center
        
        let invisibleViewTop = UIView()
        invisibleViewTop.backgroundColor = .clear // Transparan görünüm
        invisibleViewTop.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            invisibleViewTop.heightAnchor.constraint(equalToConstant: 5)
         ])

        let invisibleViewBottom = UIView()
        invisibleViewBottom.backgroundColor = .clear // Transparan görünüm
        invisibleViewBottom.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            invisibleViewBottom.heightAnchor.constraint(equalToConstant: 5)
         ])
        
        bannerTextLabel = UILabel()
        bannerTextLabel.text = customWebViewModel.promocode_banner_text.removeEscapingCharacters()
        bannerTextLabel.numberOfLines = 0
        bannerTextLabel.textAlignment = .center
        bannerTextLabel.contentMode = .center
        bannerTextLabel.baselineAdjustment = .alignCenters

        bannerButtonLabel = UILabel()
        bannerButtonLabel.text = customWebViewModel.promocode_banner_button_label
        bannerButtonLabel.textAlignment = .center
        bannerButtonLabel.isHidden = true

        bannerCodeLabel = UILabel()
        bannerCodeLabel.text = BannerCodeManager.shared.getCustomWebViewCode()
        bannerCodeLabel.textAlignment = .center

        verticalStackViewLeft.addArrangedSubview(bannerTextLabel)

        verticalStackViewRight.addArrangedSubview(invisibleViewTop)
        verticalStackViewRight.addArrangedSubview(bannerButtonLabel)
        verticalStackViewRight.addArrangedSubview(bannerCodeLabel)
        verticalStackViewRight.addArrangedSubview(invisibleViewBottom)

        horizontalStackView.addArrangedSubview(verticalStackViewRight)
        horizontalStackView.addArrangedSubview(verticalStackViewLeft)

        addSubview(horizontalStackView)
    }

    private func setCloseButton() {
        closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.contentHorizontalAlignment = .right
        closeButton.clipsToBounds = false
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.setTitle("×", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 35.0, weight: .regular)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        closeButton.setTitleColor(customWebViewModel.close_button_color.lowercased() == "white" ? .white : .black, for: .normal)
        addSubview(closeButton)
    }

    private func layoutContent() {
        horizontalStackView.leading(to: self, offset: 0, relation: .equal, priority: .required)
        horizontalStackView.trailing(to: self, offset: 0, relation: .equal, priority: .required)
        horizontalStackView.centerX(to: self, priority: .required)
        horizontalStackView.isLayoutMarginsRelativeArrangement = true
        closeButton.top(to: self, offset: -5.0)
        closeButton.trailing(to: self, offset: -10.0)
        self.window?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
        self.window?.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        self.layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        verticalStackViewRight.setDashedBorderView()
    }

    private func setFonts() {
        let font = VisilabsHelper.getFont(fontFamily: customWebViewModel.font_family,
                                    fontSize: customWebViewModel.copybutton_text_size,
                                    style: .title2, customFont: customWebViewModel.custom_font_family_ios)
        bannerTextLabel.font = font
        bannerButtonLabel.font = font
        bannerCodeLabel.font = font
    }

    private func setColors() {
        self.backgroundColor = UIColor(hex: customWebViewModel.promocode_banner_background_color)
        horizontalStackView.backgroundColor = UIColor(hex: customWebViewModel.promocode_banner_background_color)
        bannerTextLabel.backgroundColor = UIColor(hex: customWebViewModel.promocode_banner_background_color)
        bannerButtonLabel.backgroundColor = UIColor(hex: customWebViewModel.promocode_banner_background_color)
        bannerCodeLabel.backgroundColor = UIColor(hex: customWebViewModel.promocode_banner_background_color)

        bannerTextLabel.textColor = UIColor(hex: customWebViewModel.promocode_banner_text_color)
        bannerButtonLabel.textColor = UIColor(hex: customWebViewModel.promocode_banner_text_color)
        bannerCodeLabel.textColor = UIColor(hex: customWebViewModel.promocode_banner_text_color)
    }

}
