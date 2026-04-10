//
//  VisilabsCarouselFullscreenViewController.swift
//  VisilabsIOS
//

import UIKit

private enum CarouselFullscreenStyle {
    static let defaultTitle = UIColor(red: 0, green: 137 / 255, blue: 123 / 255, alpha: 1)
    static let defaultBody = UIColor(red: 117 / 255, green: 117 / 255, blue: 117 / 255, alpha: 1)
    static let defaultPrimaryFill = UIColor(red: 0, green: 137 / 255, blue: 123 / 255, alpha: 1)
    /// Watsons referansı: arkaplan görseli ekranın üst kısmını kaplar, altı beyaz.
    static let heroHeightFraction: CGFloat = 0.85
    /// Kartın üst banda bindirme miktarı (px); böylece kartın bir kısmı görselde, bir kısmı beyaz alanda kalır.
    static let cardOverlapIntoHero: CGFloat = 72
}

// MARK: - Cell

private final class VisilabsCarouselFullscreenCell: UICollectionViewCell {

    private let heroContainer = UIView()
    private let heroImageView = UIImageView()
    private let cardView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()

    private var heroTask: URLSessionDataTask?
    private var iconTask: URLSessionDataTask?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white

        heroContainer.backgroundColor = .white
        heroContainer.clipsToBounds = true
        heroContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(heroContainer)

        // Üst bandı tam genişlikte doldurur (Watsons); dikey görseller yanlardan taşarak kırpılabilir.
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        heroContainer.addSubview(heroImageView)

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 22
        cardView.layer.masksToBounds = true
        cardView.layer.borderWidth = 2.0 / max(UIScreen.main.scale, 1)
        cardView.layer.borderColor = UIColor.darkGray.cgColor
        if #available(iOS 13.0, *) {
            cardView.layer.cornerCurve = .continuous
        }
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 8
        iconImageView.layer.masksToBounds = true
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconImageView)

        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            heroContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroContainer.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: CarouselFullscreenStyle.heroHeightFraction),

            heroImageView.topAnchor.constraint(equalTo: heroContainer.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: heroContainer.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: heroContainer.trailingAnchor),
            heroImageView.bottomAnchor.constraint(equalTo: heroContainer.bottomAnchor),

            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.topAnchor.constraint(equalTo: heroContainer.bottomAnchor, constant: -CarouselFullscreenStyle.cardOverlapIntoHero),
            cardView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),

            iconImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 22),
            iconImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 64),
            iconImageView.heightAnchor.constraint(equalToConstant: 64),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            bodyLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            bodyLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        heroTask?.cancel()
        iconTask?.cancel()
        heroTask = nil
        iconTask = nil
        heroImageView.image = nil
        iconImageView.image = nil
        heroContainer.backgroundColor = .white
    }

    func configure(item: VisilabsCarouselItem) {
        titleLabel.text = item.title?.removeEscapingCharacters()
        titleLabel.font = item.titleFont
        titleLabel.textColor = item.titleColor ?? CarouselFullscreenStyle.defaultTitle

        bodyLabel.text = item.body?.removeEscapingCharacters()
        bodyLabel.font = item.bodyFont
        bodyLabel.textColor = item.bodyColor ?? CarouselFullscreenStyle.defaultBody

        heroContainer.backgroundColor = item.backgroundColor ?? .white

        loadImage(url: item.backgroundImageUrl, into: heroImageView, task: &heroTask)
        loadImage(url: item.imageUrl, into: iconImageView, task: &iconTask)
    }

    private func loadImage(url: URL?, into imageView: UIImageView, task: inout URLSessionDataTask?) {
        task?.cancel()
        task = nil
        imageView.image = nil
        guard let url = url else { return }
        let session = URLSession.shared
        task = session.dataTask(with: url) { [weak imageView] data, _, _ in
            DispatchQueue.main.async {
                guard let data = data, let img = UIImage(data: data) else { return }
                imageView?.image = img
            }
        }
        task?.resume()
    }
}

// MARK: - View controller

final class VisilabsCarouselFullscreenViewController: VisilabsBaseNotificationViewController,
    UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let carouselItems: [VisilabsCarouselItem]
    private var collectionView: UICollectionView!
    private let pageControl = UIPageControl()
    private let primaryButton = UIButton(type: .system)
    private let secondaryButton = UIButton(type: .system)
    private let buttonStack = UIStackView()
    private let closeButton = UIButton(type: .system)
    private let footerContainer = UIStackView()

    private var currentIndex: Int = 0

    var onButtonTap: ((_ notification: VisilabsInAppNotification, _ link: String?, _ button: VisilabsCarouselFullscreenButton, _ index: Int) -> Void)?

    init(notification: VisilabsInAppNotification, carouselItems: [VisilabsCarouselItem]) {
        self.carouselItems = carouselItems
        super.init(nibName: nil, bundle: nil)
        self.notification = notification
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VisilabsCarouselFullscreenCell.self, forCellWithReuseIdentifier: "fullscreenCarouselCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        pageControl.numberOfPages = carouselItems.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor(white: 0.88, alpha: 1)
        pageControl.currentPageIndicatorTintColor = CarouselFullscreenStyle.defaultTitle
        pageControl.isUserInteractionEnabled = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        styleActionButton(primaryButton, filled: true)
        styleActionButton(secondaryButton, filled: true)
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)

        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.alignment = .fill
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(primaryButton)
        buttonStack.addArrangedSubview(secondaryButton)

        footerContainer.axis = .vertical
        footerContainer.spacing = 16
        footerContainer.alignment = .center
        footerContainer.backgroundColor = .white
        footerContainer.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.addArrangedSubview(pageControl)
        footerContainer.addArrangedSubview(buttonStack)

        view.addSubview(footerContainer)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        if let closeImg = VisilabsHelper.getUIImage(named: "VisilabsCloseButton") {
            closeButton.setImage(closeImg.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            closeButton.setTitle("×", for: .normal)
            closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .light)
        }
        // Renkli hero üzerinde okunur olsun (Watsons); JSON ile override edilebilir.
        closeButton.tintColor = notification?.closeButtonColor ?? .white
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        let guide: UILayoutGuide
        if #available(iOS 11.0, *) {
            guide = view.safeAreaLayoutGuide
        } else {
            let g = UILayoutGuide()
            view.addLayoutGuide(g)
            NSLayoutConstraint.activate([
                g.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                g.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
                g.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                g.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            guide = g
        }

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            collectionView.topAnchor.constraint(equalTo: guide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: footerContainer.topAnchor, constant: -8),

            footerContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            footerContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
            footerContainer.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -12),

            buttonStack.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor),
            primaryButton.heightAnchor.constraint(equalToConstant: 52),
            secondaryButton.heightAnchor.constraint(equalToConstant: 52)
        ])

        updateFooter(for: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: false, additionalTrackingProperties: nil)
    }

    @objc private func primaryTapped() {
        handleButton(slot: .primary)
    }

    @objc private func secondaryTapped() {
        handleButton(slot: .secondary)
    }

    private func handleButton(slot: VisilabsCarouselFullscreenButton) {
        guard let notif = notification else { return }
        let item = carouselItems[currentIndex]
        let link: String?
        let function: String?
        switch slot {
        case .primary:
            link = item.linkString
            function = item.buttonFunction
        case .secondary:
            link = item.secondLinkString
            function = item.secondButtonFunction
        }

        if function == "redirect" {
            delegate?.notificationShouldDismiss(controller: self, callToActionURL: URL(string: "redirect"), shouldTrack: true, additionalTrackingProperties: nil)
        } else {
            let callback = onButtonTap
            delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: true, additionalTrackingProperties: nil)
            callback?(notif, link, slot, currentIndex)
        }
    }

    private func updateFooter(for index: Int) {
        guard index >= 0, index < carouselItems.count else { return }
        currentIndex = index
        pageControl.currentPage = index
        let item = carouselItems[index]

        pageControl.currentPageIndicatorTintColor = item.titleColor ?? CarouselFullscreenStyle.defaultTitle

        let radius = notification?.buttonBorderRadius ?? 14
        primaryButton.layer.cornerRadius = radius
        secondaryButton.layer.cornerRadius = radius

        let primaryFill = item.buttonColor ?? CarouselFullscreenStyle.defaultPrimaryFill
        let primaryText = item.buttonTextColor ?? .white
        primaryButton.setTitle(item.buttonText?.removeEscapingCharacters(), for: .normal)
        primaryButton.titleLabel?.font = item.buttonFont
        primaryButton.setTitleColor(primaryText, for: .normal)
        primaryButton.backgroundColor = primaryFill
        primaryButton.layer.borderWidth = 0

        let hasSecondary = !(item.secondButtonText ?? "").isEmptyOrWhitespace
        secondaryButton.isHidden = !hasSecondary
        if hasSecondary {
            let secFill = item.secondButtonColor ?? primaryFill
            let secText = item.secondButtonTextColor ?? .white
            secondaryButton.setTitle(item.secondButtonText?.removeEscapingCharacters(), for: .normal)
            secondaryButton.titleLabel?.font = item.secondButtonFont
            secondaryButton.setTitleColor(secText, for: .normal)
            secondaryButton.backgroundColor = secFill
            secondaryButton.layer.borderWidth = 0
            buttonStack.distribution = .fillEqually
        } else {
            buttonStack.distribution = .fill
        }
    }

    private func styleActionButton(_ button: UIButton, filled: Bool) {
        button.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            button.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    // MARK: - UICollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        carouselItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fullscreenCarouselCell", for: indexPath) as! VisilabsCarouselFullscreenCell
        cell.configure(item: carouselItems[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        syncPageFromScrollView(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        syncPageFromScrollView(scrollView)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }
        let page = Int(round(scrollView.contentOffset.x / pageWidth))
        if page >= 0, page < carouselItems.count, page != pageControl.currentPage {
            pageControl.currentPage = page
        }
    }

    private func syncPageFromScrollView(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }
        let page = Int(round(scrollView.contentOffset.x / pageWidth))
        if page >= 0, page < carouselItems.count {
            updateFooter(for: page)
        }
    }

    // MARK: - Presentation

    override func show(animated: Bool) {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else {
            return
        }
        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first
            if let windowScene = windowScene as? UIWindowScene {
                window = UIWindow(frame: windowScene.coordinateSpace.bounds)
                window?.windowScene = windowScene
            }
        } else {
            window = UIWindow(frame: CGRect(x: 0,
                                            y: 0,
                                            width: UIScreen.main.bounds.size.width,
                                            height: UIScreen.main.bounds.size.height))
        }
        if let window = window {
            window.alpha = 0
            window.windowLevel = UIWindow.Level.alert
            window.rootViewController = self
            window.isHidden = false
        }

        let duration = animated ? 0.25 : 0
        UIView.animate(withDuration: duration, animations: {
            self.window?.alpha = 1
        }, completion: nil)
    }

    override func hide(animated: Bool, completion: @escaping () -> Void) {
        let duration = animated ? 0.25 : 0
        UIView.animate(withDuration: duration, animations: {
            self.window?.alpha = 0
        }, completion: { _ in
            self.window?.isHidden = true
            self.window?.removeFromSuperview()
            self.window = nil
            completion()
        })
    }

    override var shouldAutorotate: Bool {
        false
    }
}
