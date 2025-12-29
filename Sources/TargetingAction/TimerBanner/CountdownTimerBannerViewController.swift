
import UIKit

final class CountdownTimerBannerViewController: VisilabsBaseNotificationViewController {
    
    final class PassthroughWindow: UIWindow {
        var passRectProvider: (() -> CGRect)?
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            guard let r = passRectProvider?() else { return super.point(inside: point, with: event) }
            return r.contains(point)
        }
    }
    
    private let model: CountdownTimerBannerModel
    private let bannerView = CountdownTimerBannerView()
    private var timer: Timer?
    
    init(model: CountdownTimerBannerModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear 
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        // Position based on model.position (top/bottom)
        let isTop = model.position == "top"
        
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        if isTop {
            if #available(iOS 11.0, *) {
                bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            } else {
                bannerView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
            }
        } else {
            if #available(iOS 11.0, *) {
                bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
            } else {
                bannerView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: 0).isActive = true
            }
        }
        
        let targetDate = resolveTargetDate()
        bannerView.configure(model: model, targetDate: targetDate)
        
        if let iconUrlStr = model.iconUrl, let url = URL(string: iconUrlStr) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.bannerView.iconImageView.image = img
                        self.bannerView.iconImageView.isHidden = false
                    }
                }
            }
        }
        
        bannerView.onClose = { [weak self] in
            guard let self = self else { return }
            // Notify delegate to dismiss. This ensures 'currentlyShowingTargetingAction' is cleared in VisilabsInAppNotifications.
            self.delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: false, additionalTrackingProperties: nil)
        }
        
        bannerView.onBannerClick = { [weak self] in
            guard let self = self else { return }
            print("Visilabs: Banner Clicked. ios_lnk: \(String(describing: self.model.ios_lnk))")
            
            if let iosLink = self.model.ios_lnk, let url = URL(string: iosLink) {
                print("Visilabs: Opening URL \(url)")
                // Call delegate to dismiss AND open URL
                self.delegate?.notificationShouldDismiss(controller: self, callToActionURL: url, shouldTrack: true, additionalTrackingProperties: nil)
            } else {
                print("Visilabs: Invalid or missing URL")
                self.delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: true, additionalTrackingProperties: nil)
            }
        }
        
        // Add Swipe
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        bannerView.addGestureRecognizer(gesture)
    }
    
    private func resolveTargetDate() -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // Default to current time as base
        
        var dateStr = model.counter_Date ?? ""
        var timeStr = model.counter_Time ?? "00:00:00"
        
        // Sanitize
        dateStr = dateStr.trimmingCharacters(in: .whitespacesAndNewlines)
        timeStr = timeStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !dateStr.isEmpty {
            // Attempt 1: Combined Date + Time (Most accurate)
            let combinedStr = "\(dateStr) \(timeStr)"
            
            let combinedFormats = [
                "yyyy-MM-dd HH:mm:ss",
                "yyyy-MM-dd HH:mm",
                "dd.MM.yyyy HH:mm:ss",
                "dd.MM.yyyy HH:mm",
                "MM/dd/yyyy HH:mm:ss",
                "MM/dd/yyyy HH:mm"
            ]
            
            for format in combinedFormats {
                formatter.dateFormat = format
                if let date = formatter.date(from: combinedStr) {
                    return date
                }
            }
            
            // Attempt 2: Date String Only (If combined failed, maybe dateStr has it all or we ignore time)
            let dateFormats = [
                "yyyy-MM-dd HH:mm:ss", // In case dateStr has time
                "yyyy-MM-dd",
                "dd.MM.yyyy",
                "MM/dd/yyyy"
            ]
            
            for format in dateFormats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateStr) {
                    return date
                }
            }
        }
        
        // Scenario 2: waitingTime (seconds)
        if model.waitingTime > 0 {
             return Date().addingTimeInterval(TimeInterval(model.waitingTime))
        }
        
        return Date()
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if gesture.state == .ended {
            if model.position == "top" && translation.y < -50 {
                dismiss(animated: true)
            } else if model.position == "bottom" && translation.y > 50 {
                dismiss(animated: true)
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc private func tick() {
        let targetDate = resolveTargetDate()
        bannerView.updateTimer(targetDate: targetDate)
        
        if Date() >= targetDate {
            timer?.invalidate()
        }
    }
    
    override func show(animated: Bool) {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else { return }
        
        var bounds: CGRect
        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first as? UIWindowScene
            bounds = windowScene?.coordinateSpace.bounds ?? UIScreen.main.bounds
        } else {
            bounds = UIScreen.main.bounds
        }
        
        let h: CGFloat = 75 + 20 // Height + Padding
        let y: CGFloat = (model.position == "top") ? 0 : bounds.height - h
        
        let frame = CGRect(x: 0, y: y, width: bounds.width, height: h)
        
        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first as? UIWindowScene
            
            if let ws = windowScene {
                window = PassthroughWindow(frame: frame)
                window?.windowScene = ws
            } else {
                window = PassthroughWindow(frame: frame)
            }
        } else {
            window = PassthroughWindow(frame: frame)
        }
        
        window?.windowLevel = .alert
        window?.rootViewController = self
        window?.isHidden = false
        
        (window as? PassthroughWindow)?.passRectProvider = { [weak self] in
            guard let self = self else { return .zero }
            return self.bannerView.frame
        }
        
        // Animation
        let startY = (model.position == "top") ? -h : bounds.height
        let endY = (model.position == "top") ? 0 : bounds.height - h
        
        window?.frame.origin.y = startY
        UIView.animate(withDuration: 0.5) {
            self.window?.frame.origin.y = endY
        }
    }
    
    override func hide(animated: Bool, completion: @escaping () -> Void) {
        let h: CGFloat = 75 + 20
        let endY = (model.position == "top") ? -h : UIScreen.main.bounds.height
        
        UIView.animate(withDuration: 0.5, animations: {
            self.window?.frame.origin.y = endY
        }) { _ in
            self.window = nil
            completion()
        }
    }
}
