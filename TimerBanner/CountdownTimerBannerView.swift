import UIKit

final class CounterTileView: UIView {
    private let valueLabel = UILabel()
    private let unitLabel  = UILabel()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 6

        valueLabel.font = .monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        valueLabel.textAlignment = .center
        valueLabel.textColor = .white

        unitLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        unitLabel.textAlignment = .center
        unitLabel.textColor = .white.withAlphaComponent(0.9)

        let stack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        stack.axis = .vertical; stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(value: String, unit: String) {
        valueLabel.text = value
        unitLabel.text  = unit
    }
    func setColors(bg: UIColor, text: UIColor) {
        backgroundColor = bg
        valueLabel.textColor = text
        unitLabel.textColor  = text.withAlphaComponent(0.95)
    }
}

// Sayaç kapsülü (mor kutu)
final class CounterBadgeView: UIView {
    private let container = UIStackView()
    let day = CounterTileView()
    let hour = CounterTileView()
    let min = CounterTileView()
    let sec = CounterTileView()

    private var tileBG = UIColor.white
    private var textColor = UIColor.white

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 10
        clipsToBounds = true

        container.axis = .horizontal
        container.spacing = 6
        container.alignment = .center
        container.distribution = .fillEqually
        container.translatesAutoresizingMaskIntoConstraints = false

        [day, hour, min, sec].forEach { container.addArrangedSubview($0) }
        addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            container.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 160)
        ])

        // Varsayılan etiketler (TR)
        day.configure(value: "00", unit: "Gün")
        hour.configure(value: "00", unit: "Saat")
        min.configure(value: "00", unit: "Dk")
        sec.configure(value: "00", unit: "Sn")
        applyTileColors()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func applyTileColors() {
        [day, hour, min, sec].forEach { $0.setColors(bg: tileBG, text: textColor) }
    }

    func setColors(background: UIColor, tile: UIColor, text: UIColor) {
        self.backgroundColor = background
        self.tileBG = tile
        self.textColor = text
        applyTileColors()
    }

    func setValues(days: Int, hours: Int, minutes: Int, seconds: Int) {
        day.configure(value: String(format: "%02d", days), unit: "Gün")
        hour.configure(value: String(format: "%02d", hours), unit: "Saat")
        min.configure(value: String(format: "%02d", minutes), unit: "Dk")
        sec.configure(value: String(format: "%02d", seconds), unit: "Sn")
    }
}

// Banner (siyah oval + sol logo + orta metin + sağ sayaç + X)
final class CountdownTimerBannerView: UIControl {

    // Callbacks
    var onClose: (() -> Void)?
    var onTap: (() -> Void)?

    // Public parts (ikon yüklemek için)
    let iconView = UIImageView()

    // Private UI
    public let pill = UIView()
    public let textLabel = UILabel()
    public let counter = CounterBadgeView()
    public let closeButton = UIButton(type: .system)
    public let accentBlob = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildUI() {
        translatesAutoresizingMaskIntoConstraints = false

        // Arka accent (koyu sarımsı blob hissi istersen alpha ile)
        accentBlob.translatesAutoresizingMaskIntoConstraints = false
        accentBlob.backgroundColor = UIColor.black.withAlphaComponent(0.0) 
        addSubview(accentBlob)

        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.backgroundColor = UIColor(white: 0.12, alpha: 1)
        pill.layer.cornerRadius = 16
        pill.layer.shadowColor = UIColor.black.cgColor
        pill.layer.shadowOpacity = 0.12
        pill.layer.shadowRadius = 10
        pill.layer.shadowOffset = CGSize(width: 0, height: 2)
        addSubview(pill)

        // icon
        iconView.layer.cornerRadius = 6
        iconView.layer.masksToBounds = true
        iconView.contentMode = .scaleAspectFill
        iconView.translatesAutoresizingMaskIntoConstraints = false

        // text
        textLabel.textColor = .white
        textLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        textLabel.numberOfLines = 2
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // close
        if #available(iOS 13.0, *) {
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        // İç layout
        pill.addSubview(iconView)
        pill.addSubview(textLabel)
        pill.addSubview(counter)
        pill.addSubview(closeButton)

        // Constraints
        NSLayoutConstraint.activate([
            // dış
            accentBlob.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            accentBlob.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            accentBlob.bottomAnchor.constraint(equalTo: bottomAnchor),
            accentBlob.heightAnchor.constraint(equalToConstant: 14),

            pill.leadingAnchor.constraint(equalTo: leadingAnchor),
            pill.trailingAnchor.constraint(equalTo: trailingAnchor),
            pill.topAnchor.constraint(equalTo: topAnchor),
            pill.bottomAnchor.constraint(equalTo: bottomAnchor),

            // içerik
            iconView.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),

            closeButton.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -10),
            closeButton.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),

            counter.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            counter.centerYAnchor.constraint(equalTo: pill.centerYAnchor),

            textLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(lessThanOrEqualTo: counter.leadingAnchor, constant: -10),
            textLabel.topAnchor.constraint(equalTo: pill.topAnchor, constant: 10),
            textLabel.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -10),

            heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
        ])

        // Tap to open
        addTarget(self, action: #selector(bannerTapped), for: .touchUpInside)
    }

    // Public API
    func setBody(_ text: String) { textLabel.text = text }
    func setBodyTextColor(_ c: UIColor) { textLabel.textColor = c }
    func setCloseColor(_ c: UIColor) { closeButton.tintColor = c }
    func setAccentColor(_ c: UIColor) { accentBlob.backgroundColor = c }
    func setPillColor(_ c: UIColor) { pill.backgroundColor = c }
    func setCounterColors(bg: UIColor, tile: UIColor, text: UIColor) { counter.setColors(background: bg, tile: tile, text: text) }

    func updateSegments(days: Int, hours: Int, minutes: Int, seconds: Int) {
        counter.setValues(days: days, hours: hours, minutes: minutes, seconds: seconds)
    }

    // Actions
    @objc private func closeTapped() { onClose?() }
    @objc private func bannerTapped() { onTap?() }
}
