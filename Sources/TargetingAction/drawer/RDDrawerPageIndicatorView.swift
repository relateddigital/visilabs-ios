//
//  RDDrawerPageIndicatorView.swift
//  VisilabsIOS
//
//  Dot based indicator showing which drawer item is currently visible.
//

import UIKit

final class DrawerPageIndicatorView: UIView {

    var onIndexSelected: ((Int) -> Void)?

    private let dotSize: CGFloat
    private let stackView = UIStackView()
    private var dots: [UIView] = []

    /// Height of a horizontal indicator, so that callers can keep content clear of the dots.
    static func height(dotSize: CGFloat = 7.0, verticalPadding: CGFloat = 6.0) -> CGFloat {
        dotSize + verticalPadding * 2
    }

    init(numberOfPages: Int,
         axis: NSLayoutConstraint.Axis,
         dotSize: CGFloat = 7.0,
         dotSpacing: CGFloat = 5.0,
         horizontalPadding: CGFloat = 7.0,
         verticalPadding: CGFloat = 6.0) {
        self.dotSize = dotSize
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        stackView.axis = axis
        stackView.alignment = .center
        stackView.spacing = dotSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: verticalPadding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalPadding)
        ])

        for _ in 0..<numberOfPages {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.layer.cornerRadius = dotSize / 2
            dot.layer.borderWidth = 1.0
            dot.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize)
            ])
            stackView.addArrangedSubview(dot)
            dots.append(dot)
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        setCurrentIndex(0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCurrentIndex(_ index: Int) {
        for (dotIndex, dot) in dots.enumerated() {
            dot.backgroundColor = dotIndex == index ? .white : UIColor.white.withAlphaComponent(0.35)
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        // The dots themselves are too small to be reliable touch targets, so the dot
        // closest to the tap is selected instead of hit testing each one.
        let location = gesture.location(in: self)
        var selectedIndex: Int?
        var shortestDistance = CGFloat.greatestFiniteMagnitude

        for (index, dot) in dots.enumerated() {
            let dotCenter = convert(CGPoint(x: dot.bounds.midX, y: dot.bounds.midY), from: dot)
            let distance = hypot(dotCenter.x - location.x, dotCenter.y - location.y)
            if distance < shortestDistance {
                shortestDistance = distance
                selectedIndex = index
            }
        }

        if let selectedIndex = selectedIndex {
            onIndexSelected?(selectedIndex)
        }
    }
}
