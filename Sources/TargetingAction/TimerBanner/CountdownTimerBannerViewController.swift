
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
    private var topC: NSLayoutConstraint?
    private var bottomC: NSLayoutConstraint?
    
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
        
        // Alta yapışırken ekranın en dibine değil, host uygulamanın alt menüsünün
        // (tab bar) ya da home indicator alanının üstünde duracak şekilde
        // konumlandırılır. Alt kısıt, ekran (view) altına göre hesaplanır.
        if #available(iOS 11.0, *) {
            topC = bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        } else {
            topC = bannerView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0)
        }
        bottomC = bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: resolveBottomConstant())
        topC?.isActive = isTop
        bottomC?.isActive = !isTop
        
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
        // Sürükleme sırasında banner'a tıklama (kapanma) tetiklenmesin.
        bannerView.requirePanToFail(gesture)
    }
    
    private func resolveTargetDate() -> Date {
        if let date = Self.parsedCounterDate(for: model) {
            return date
        }

        // Scenario 2: waitingTime (seconds)
        if model.waitingTime > 0 {
             return Date().addingTimeInterval(TimeInterval(model.waitingTime))
        }
        
        return Date()
    }

    // Modelin counter_Date/counter_Time alanından hedef tarihi çözer (yoksa nil).
    static func parsedCounterDate(for model: CountdownTimerBannerModel) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let dateStr = (model.counter_Date ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let timeStr = (model.counter_Time ?? "00:00:00").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !dateStr.isEmpty else { return nil }

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
            if let date = formatter.date(from: combinedStr) { return date }
        }

        let dateFormats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd",
            "dd.MM.yyyy",
            "MM/dd/yyyy"
        ]
        for format in dateFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateStr) { return date }
        }

        return nil
    }

    // Geri sayım süresi dolmuşsa banner gösterilmemelidir.
    static func isExpired(model: CountdownTimerBannerModel) -> Bool {
        guard let target = parsedCounterDate(for: model) else { return false }
        return target <= Date()
    }
    
    // Banner alta yapışırken bırakılacak alt boşluğu (view altına göre, negatif)
    // hesaplar: host uygulamada görünür bir tab bar varsa onun üstünde, yoksa
    // home indicator üstünde durur.
    private func resolveBottomConstant() -> CGFloat {
        let gap: CGFloat = 8
        let screenH = UIScreen.main.bounds.height
        if let tabBar = hostTabBar(), tabBar.frame.height > 0 {
            let tabTop = tabBar.convert(tabBar.bounds, to: nil).minY
            return -(screenH - tabTop + gap)
        }
        var safeBottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            safeBottom = hostWindow()?.safeAreaInsets.bottom ?? 0
        }
        return -(safeBottom + 16)
    }

    private func hostWindow() -> UIWindow? {
        guard let app = VisilabsInstance.sharedUIApplication() else { return nil }
        var windows: [UIWindow] = []
        if #available(iOS 13.0, *) {
            windows = app.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
        } else {
            windows = app.windows
        }
        let hosts = windows.filter { !($0 is PassthroughWindow) && $0 !== window }
        return hosts.first(where: { $0.isKeyWindow }) ?? hosts.first
    }

    private func hostTabBar() -> UITabBar? {
        guard let root = hostWindow()?.rootViewController else { return nil }
        return findTabBar(in: root)
    }

    private func findTabBar(in vc: UIViewController) -> UITabBar? {
        if let tab = vc as? UITabBarController, !tab.tabBar.isHidden, tab.tabBar.alpha > 0.01 {
            return tab.tabBar
        }
        if let presented = vc.presentedViewController, let found = findTabBar(in: presented) {
            return found
        }
        for child in vc.children {
            if let found = findTabBar(in: child) { return found }
        }
        return nil
    }

    // Base sınıf (VisilabsBaseNotificationViewController) banner'a dokunulduğunda
    // arka plan tıklamasıyla kapatıyor. Bu nedenle sürüklemeye başlar başlamaz
    // banner kapanıyordu. Countdown banner kendi kapatma butonu, tıklama ve
    // sürükleme jestlerine sahip olduğundan bu davranışı devre dışı bırakıyoruz.
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Bilinçli olarak super çağrılmıyor.
    }

    // Banner'ı dikey olarak sürükler ve bırakıldığında ekranın üst/alt yarısına
    // göre tam üste veya tam alta yapıştırır.
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .changed:
            bannerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended, .cancelled, .failed:
            let predictedCenterY = bannerView.center.y + translation.y
            let snapTop = predictedCenterY < view.bounds.height / 2
            topC?.isActive = snapTop
            bottomC?.isActive = !snapTop
            UIView.animate(withDuration: 0.25) {
                self.bannerView.transform = .identity
                self.view.layoutIfNeeded()
            }
        default:
            break
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

        // Banner sürüklenip ekranın üst/alt yarısına yapışabilsin diye pencere
        // tüm ekranı kaplar. Banner dışındaki dokunuşlar passRectProvider ile
        // alttaki içeriğe geçer.
        var bounds: CGRect
        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first as? UIWindowScene
            bounds = windowScene?.coordinateSpace.bounds ?? UIScreen.main.bounds
            if let ws = windowScene {
                window = PassthroughWindow(frame: bounds)
                window?.windowScene = ws
            } else {
                window = PassthroughWindow(frame: bounds)
            }
        } else {
            bounds = UIScreen.main.bounds
            window = PassthroughWindow(frame: bounds)
        }

        window?.windowLevel = .alert
        window?.rootViewController = self
        window?.isHidden = false

        (window as? PassthroughWindow)?.passRectProvider = { [weak self] in
            guard let self = self else { return .zero }
            return self.bannerView.frame
        }

        // Slide-in animasyonu banner transform'u ile yapılır.
        let isTop = model.position == "top"
        view.layoutIfNeeded()
        let offset = bannerView.bounds.height + 40
        bannerView.transform = CGAffineTransform(translationX: 0, y: isTop ? -offset : offset)
        UIView.animate(withDuration: 0.5) {
            self.bannerView.transform = .identity
        }
    }
    
    override func hide(animated: Bool, completion: @escaping () -> Void) {
        let isTop = topC?.isActive ?? (model.position == "top")
        let offset = bannerView.bounds.height + 40

        UIView.animate(withDuration: 0.5, animations: {
            self.bannerView.transform = CGAffineTransform(translationX: 0, y: isTop ? -offset : offset)
        }) { _ in
            self.window = nil
            completion()
        }
    }
}
