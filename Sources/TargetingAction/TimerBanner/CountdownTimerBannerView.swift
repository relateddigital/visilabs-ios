
import UIKit

final class CountdownTimerBannerView: UIView {
    
    // MARK: - Subviews
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    // Icon view
    let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()
    
    // Close button (X)
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        // Large X icon
        btn.setTitle("✕", for: .normal)
        // Larger font for "vertically centered" look if it's large
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold) 
        return btn
    }()
    
    private let messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.numberOfLines = 2
        return lbl
    }()
    
    // MARK: - Unified Timer Components
    
    private let timerContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 8
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.white.cgColor
        v.clipsToBounds = true
        return v
    }()
    
    private let timerNumbersStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        s.distribution = .fillProportionally
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private let timerLabelsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        s.distribution = .fillProportionally
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // Labels for numbers
    private let daysVal = UILabel()
    private let hoursVal = UILabel()
    private let minsVal = UILabel()
    
    // Labels for texts
    private let daysKey = UILabel()
    private let hoursKey = UILabel()
    private let minsKey = UILabel()
    
    var onClose: (() -> Void)?
    var onBannerClick: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        addSubview(containerView)
        // Hierarchy
        containerView.addSubview(contentStack)
        containerView.addSubview(closeButton)
        
        // Timer Labels Setup
        [daysVal, hoursVal, minsVal].forEach {
            $0.font = .monospacedDigitSystemFont(ofSize: 16, weight: .bold)
            $0.textColor = .white
            $0.textAlignment = .center
        }
        
        [daysKey, hoursKey, minsKey].forEach {
            $0.font = .systemFont(ofSize: 10, weight: .medium)
            $0.textColor = .white
            $0.textAlignment = .center
        }

        // Timer Layout:
        // Inside timerContainer -> Vertical Stack (Numbers / Labels)
        let vStack = UIStackView(arrangedSubviews: [timerNumbersStack, timerLabelsStack])
        vStack.axis = .vertical
        vStack.spacing = 2
        vStack.alignment = .center
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        timerContainer.addSubview(vStack)
        
        // Fill container
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: timerContainer.topAnchor, constant: 4),
            vStack.bottomAnchor.constraint(equalTo: timerContainer.bottomAnchor, constant: -4),
            vStack.leadingAnchor.constraint(equalTo: timerContainer.leadingAnchor, constant: 8),
            vStack.trailingAnchor.constraint(equalTo: timerContainer.trailingAnchor, constant: -8)
        ])
        
        // Add items to horizontal stacks
        timerNumbersStack.addArrangedSubview(daysVal)
        timerNumbersStack.addArrangedSubview(hoursVal)
        timerNumbersStack.addArrangedSubview(minsVal)
        
        timerLabelsStack.addArrangedSubview(daysKey)
        timerLabelsStack.addArrangedSubview(hoursKey)
        timerLabelsStack.addArrangedSubview(minsKey)
        
        // Add content to main stack
        contentStack.addArrangedSubview(iconImageView)
        contentStack.addArrangedSubview(messageLabel)
        contentStack.addArrangedSubview(timerContainer)
        
        // View Layout
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 75),
            
            // Timer Container Width Constraint (Prevent stretching)
            timerContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 120),
            
            // Close Button: Vertically Centered on the Right
            closeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // StackView
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            contentStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        // Timer Container Content Hugging - Keep it compact
        timerContainer.setContentHuggingPriority(.required, for: .horizontal)
        timerContainer.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Message Label should expand to fill space
        messageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBannerClick))
        tap.delegate = self
        tap.cancelsTouchesInView = false // Allow button to receive touches
        containerView.addGestureRecognizer(tap)
        
        // Important: Ensure close button doesn't trigger banner click
        closeButton.isUserInteractionEnabled = true
        containerView.isUserInteractionEnabled = true
    }
    
    @objc private func handleClose() {
        onClose?()
    }
    
    @objc private func handleBannerClick() {
        onBannerClick?()
    }
    
    func configure(model: CountdownTimerBannerModel, targetDate: Date) {
        // Background Color
        if let bgHex = model.background {
            containerView.backgroundColor = UIColor(hex: bgHex)
        } else {
            containerView.backgroundColor = .black
        }
        
        // Text Color
        if let textHex = model.textColor {
            messageLabel.textColor = UIColor(hex: textHex)
            closeButton.setTitleColor(UIColor(hex: textHex), for: .normal)
        } else {
            messageLabel.textColor = .white
            closeButton.setTitleColor(.white, for: .normal)
        }
        
        messageLabel.text = model.message ?? model.title
        
        // Timer Colors
        let tileBgColor = UIColor(hex: model.scratchColor) ?? .orange
        let tileTxtColor = UIColor(hex: model.counterColor) ?? .white
        
        timerContainer.backgroundColor = tileBgColor
        
        daysVal.textColor = tileTxtColor
        hoursVal.textColor = tileTxtColor
        minsVal.textColor = tileTxtColor
        
        daysKey.textColor = tileTxtColor
        hoursKey.textColor = tileTxtColor
        minsKey.textColor = tileTxtColor

        
        updateTimer(targetDate: targetDate)
    }
    
    func updateTimer(targetDate: Date) {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: targetDate) // No Second
        
        let d = max(0, components.day ?? 0)
        let h = max(0, components.hour ?? 0)
        let m = max(0, components.minute ?? 0)
        
        daysVal.text = String(format: "%02d", d)
        hoursVal.text = String(format: "%02d", h)
        minsVal.text = String(format: "%02d", m)
        
        daysKey.text = "Gün"
        hoursKey.text = "Saat"
        minsKey.text = "Dk" // Shortened for space
    }
}

extension CountdownTimerBannerView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // If the touch is on the close button, the banner gesture should NOT receive it.
        if touch.view == closeButton {
            return false
        }
        return true
    }
}
