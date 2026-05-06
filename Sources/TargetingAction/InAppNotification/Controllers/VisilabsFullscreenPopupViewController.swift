//
//  VisilabsFullscreenPopupViewController.swift
//  VisilabsIOS
//

import UIKit

final class VisilabsFullscreenPopupViewController: VisilabsBaseNotificationViewController {
    private let imageView = UIImageView()
    private let closeButton = UIButton(type: .system)
    private var imageTask: URLSessionDataTask?

    init(notification: VisilabsInAppNotification) {
        super.init(nibName: nil, bundle: nil)
        self.notification = notification
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupImageView()
        setupCloseButton()
        loadImage()
    }

    override func show(animated: Bool) {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else {
            return
        }

        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first as? UIWindowScene
            if let windowScene = windowScene {
                window = UIWindow(frame: windowScene.coordinateSpace.bounds)
                window?.windowScene = windowScene
            }
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
        }

        window?.windowLevel = .alert
        window?.rootViewController = self
        window?.makeKeyAndVisible()
    }

    override func hide(animated: Bool, completion: @escaping () -> Void) {
        let duration = animated ? 0.25 : 0
        UIView.animate(withDuration: duration, animations: {
            self.window?.alpha = 0
        }, completion: { _ in
            self.imageTask?.cancel()
            self.window?.isHidden = true
            self.window?.removeFromSuperview()
            self.window = nil
            completion()
        })
    }

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupCloseButton() {
        closeButton.setTitle("×", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 30, weight: .regular)
        closeButton.tintColor = notification?.closeButtonColor ?? .white
        closeButton.backgroundColor = .clear
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func loadImage() {
        guard let imageUrl = notification?.imageUrl else { return }
        imageTask = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        imageTask?.resume()
    }

    @objc private func imageTapped() {
        guard let notification = notification else { return }
        delegate?.notificationShouldDismiss(
            controller: self,
            callToActionURL: notification.callToActionUrl,
            shouldTrack: true,
            additionalTrackingProperties: nil
        )
        inappButtonDelegate?.didTapButton(notification)
    }

    @objc private func closeTapped() {
        delegate?.notificationShouldDismiss(
            controller: self,
            callToActionURL: nil,
            shouldTrack: false,
            additionalTrackingProperties: nil
        )
    }
}
