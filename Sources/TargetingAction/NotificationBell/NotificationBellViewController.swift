//
//  NotificationBellViewController.swift
//  CleanyModal
//
//  Created by Orhun Akmil on 8.09.2025.
//

import Foundation
import UIKit

// MARK: - Passthrough Window: panel kapalıyken yalnızca zil alanında hit-test al
final class PassthroughWindow: UIWindow {
    var shouldReceiveTouchAtPoint: ((CGPoint) -> Bool)?

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let decide = shouldReceiveTouchAtPoint {
            return decide(point)
        }
        return super.point(inside: point, with: event)
    }
}

// MARK: - Main VC (Bell button + panel)
final class NotificationBellViewController: VisilabsBaseNotificationViewController, UIGestureRecognizerDelegate {

    private let bellButton = UIButton(type: .custom)
    private let bellImageView = UIImageView()
    private let panel = NotificationBellPanelView()
    private var panelBottomToBellTop: NSLayoutConstraint!
    private var isPanelVisible = false

    private let model: NotificationBellModel

    init(model: NotificationBellModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupBellButton()
        setupPanel()
        applyModel()
    }

    // MARK: - Visilabs show/hide (window management) + PASSTHROUGH
    override func show(animated: Bool) {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else { return }
        if #available(iOS 13.0, *) {
            let scene = sharedUIApplication.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
            if let ws = scene {
                // PassthroughWindow kullan
                window = PassthroughWindow(frame: ws.coordinateSpace.bounds)
                window?.windowScene = ws
            }
        } else {
            window = PassthroughWindow(frame: UIScreen.main.bounds)
        }

        if let window = window as? PassthroughWindow {
            window.alpha = 0
            window.windowLevel = .alert
            window.rootViewController = self
            window.isHidden = false

            // Passthrough kuralı:
            // - Panel AÇIKSA: tüm dokunuşlar bu window'a (arka plan dokunuşu paneli kapatsın)
            // - Panel KAPALIYSA: sadece zil butonu bölgesi bu window'a; diğer her yer alttaki app'e geçsin
            window.shouldReceiveTouchAtPoint = { [weak self] p in
                guard let self = self else { return false }
                if self.isPanelVisible {
                    return true
                } else {
                    let bellFrameInWindow = self.bellButton.convert(self.bellButton.bounds, to: self.view)
                    return bellFrameInWindow.contains(p)
                }
            }
        }

        let duration = animated ? 0.25 : 0
        UIView.animate(withDuration: duration) { self.window?.alpha = 1 }
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

    private func close() {
        dismiss(animated: true) {
            self.delegate?.notificationShouldDismiss(
                controller: self,
                callToActionURL: nil,
                shouldTrack: false,
                additionalTrackingProperties: nil
            )
        }
    }

    // MARK: UI Build
    private func setupBellButton() {
        bellButton.translatesAutoresizingMaskIntoConstraints = false
        bellImageView.translatesAutoresizingMaskIntoConstraints = false
        bellImageView.contentMode = .scaleAspectFit
        bellButton.addSubview(bellImageView)

        if #available(iOS 13.0, *) { bellButton.backgroundColor = .secondarySystemBackground }
        bellButton.layer.cornerRadius = 26
        bellButton.layer.shadowColor = UIColor.black.cgColor
        bellButton.layer.shadowOpacity = 0.12
        bellButton.layer.shadowRadius = 8
        bellButton.layer.shadowOffset = CGSize(width: 0, height: 2)

        view.addSubview(bellButton)

        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                bellButton.widthAnchor.constraint(equalToConstant: 52),
                bellButton.heightAnchor.constraint(equalToConstant: 52),
                bellButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                bellButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

                bellImageView.centerXAnchor.constraint(equalTo: bellButton.centerXAnchor),
                bellImageView.centerYAnchor.constraint(equalTo: bellButton.centerYAnchor),
                bellImageView.widthAnchor.constraint(equalToConstant: 28),
                bellImageView.heightAnchor.constraint(equalToConstant: 28),
            ])
        }

        bellButton.addTarget(self, action: #selector(togglePanel), for: .touchUpInside)
    }

    private func setupPanel() {
        view.addSubview(panel)
        panel.translatesAutoresizingMaskIntoConstraints = false

        // Panel, zilin ÜSTÜNDE açılır
        panelBottomToBellTop = panel.bottomAnchor.constraint(equalTo: bellButton.topAnchor, constant: -12)

        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            panelBottomToBellTop,
            panel.heightAnchor.constraint(greaterThanOrEqualToConstant: 280)
        ])

        // Başlangıçta gizli (window kapanmıyor -> zil hep görünür)
        panel.alpha = 0
        panel.isHidden = true
        panel.transform = CGAffineTransform(scaleX: 0.98, y: 0.98).concatenating(.init(translationX: 0, y: 8))

        // Çarpı ile kapat
        panel.closeButton.addTarget(self, action: #selector(hidePanel), for: .touchUpInside)

        // Arka plan tık: sadece paneli kapat (zil kalır)
        let bgTap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        bgTap.cancelsTouchesInView = false
        bgTap.delegate = self
        view.addGestureRecognizer(bgTap)
    }

    private func applyModel() {
        if let url = model.bellIcon {
            ImageLoader.load(from: url, into: bellImageView)
        } else {
            if #available(iOS 13.0, *) { bellImageView.image = UIImage(systemName: "bell.fill") }
        }

        panel.titleLabel.text = model.notifTitle ?? ""
        panel.titleLabel.font = .boldSystemFont(ofSize: CGFloat(Double(model.title_text_size ?? "18") ?? 18) * 3)
        panel.titleLabel.textColor = UIColor(hex: model.title_text_color)

        panel.contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for el in (model.bellElems ?? []) {
            let row = BellRowView(text: el.text ?? "", link: el.ios_lnk,model: model)
            row.backgroundColor = .clear
            panel.contentStack.addArrangedSubview(row)
        }
    }

    // MARK: Animations (sadece panel)
    @objc private func togglePanel() {
        isPanelVisible ? hidePanel() : showPanel()
        // PassthroughWindow kuralı, isPanelVisible değişince otomatik uygulanacak
    }

    private func showPanel() {
        guard !isPanelVisible else { return }
        isPanelVisible = true
        panel.isHidden = false
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
            self.panel.alpha = 1
            self.panel.transform = .identity
        }
    }

    @objc private func hidePanel() {
        guard isPanelVisible else { return }
        isPanelVisible = false
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
            self.view.backgroundColor = .clear
            self.panel.alpha = 0
            self.panel.transform = CGAffineTransform(scaleX: 0.98, y: 0.98).concatenating(.init(translationX: 0, y: 8))
        } completion: { _ in
            self.panel.isHidden = true
        }
    }

    // MARK: - Background tap: zil/panel üstü hariç dokunuşu yakalayıp paneli kapat
    @objc private func backgroundTapped(_ g: UITapGestureRecognizer) {
        let p = g.location(in: view)
        if panel.frame.contains(p) || bellButton.frame.contains(p) { return }
        hidePanel()
    }

    // bgTap’ın zil/panel altındaki dokunuşları almamasını sağla
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let v = touch.view
        if v?.isDescendant(of: panel) == true { return false }
        if v?.isDescendant(of: bellButton) == true { return false }
        return true
    }
}

// MARK: - Helper: async image loader
final class ImageLoader {
    static func load(from urlString: String?, into imageView: UIImageView) {
        guard let s = urlString, let url = URL(string: s) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let d = data, let img = UIImage(data: d) else { return }
            DispatchQueue.main.async { imageView.image = img }
        }
        task.resume()
    }
}

// MARK: - Row (check + text + tap)
final class BellRowView: UIControl {
    private let iconView = UIImageView()
    private let label = UILabel()
    private var link: String?

    init(text: String, link: String?,model: NotificationBellModel) {
        super.init(frame: .zero)
        self.link = link

        iconView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 13.0, *) {
            iconView.image = UIImage(systemName: "checkmark.circle")
            iconView.tintColor = .systemGreen
        }
        iconView.contentMode = .scaleAspectFit

        label.text = text
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: CGFloat(Double(model.text_text_size ?? "15") ?? 15) * 3)
        label.textColor = UIColor(hex: model.text_text_color)

        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 10
        addSubview(stack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])

        addTarget(self, action: #selector(openLink), for: .touchUpInside)
    }

    @objc private func openLink() {
        guard
            let link = link,
            !link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let url = URL(string: link)
        else { return }
        UIApplication.shared.open(url)
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Panel (zilin üstünde duran kart)
final class NotificationBellPanelView: UIView {
    let titleLabel = UILabel()
    let closeButton = UIButton(type: .system)
    let contentStack = UIStackView()
    let scrollView = UIScrollView()
    let container = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 13.0, *) { backgroundColor = .secondarySystemBackground }
        layer.cornerRadius = 16
        if #available(iOS 11.0, *) {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: -2)

        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0

        if #available(iOS 13.0, *) {
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            closeButton.tintColor = .label
        }
        closeButton.accessibilityLabel = "Kapat"

        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        header.addSubview(titleLabel)
        header.addSubview(closeButton)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(header)
        addSubview(scrollView)
        scrollView.addSubview(container)
        container.addSubview(contentStack)

        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                header.leadingAnchor.constraint(equalTo: leadingAnchor),
                header.trailingAnchor.constraint(equalTo: trailingAnchor),
                header.topAnchor.constraint(equalTo: topAnchor),

                closeButton.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
                closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: 24),
                closeButton.heightAnchor.constraint(equalToConstant: 24),

                titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
                titleLabel.topAnchor.constraint(equalTo: header.topAnchor, constant: 16),
                titleLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -16),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -12),

                scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

                container.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                container.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                container.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
                container.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

                contentStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                contentStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
                contentStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                contentStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            ])
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
