//
//  VisilabsStoryPreviewCell.swift
//  VisilabsIOS
//
//  Created by Egemen on 7.10.2020.
//

import UIKit
import AVKit

protocol VisilabsStoryPreviewProtocol: AnyObject {
    func didCompletePreview()
    func moveToPreviousStory()
    func didTapCloseButton()
}
enum SnapMovementDirectionState {
    case forward
    case backward
}
// Identifiers
private let snapViewTagIndicator: Int = 8

// swiftlint:disable file_length type_body_length
final class VisilabsStoryPreviewCell: UICollectionViewCell, UIScrollViewDelegate {

    // MARK: - Delegate
    public weak var delegate: VisilabsStoryPreviewProtocol? {
        didSet { storyHeaderView.delegate = self }
    }

    weak var storyUrlDelegate: VisilabsStoryURLDelegate?
    //let timerView : timerView = UIView.fromNib()

    // MARK: - Private iVars
    private lazy var storyHeaderView: VisilabsStoryPreviewHeaderView = {
        let headerView = VisilabsStoryPreviewHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()

    private lazy var snapButton: UIButton = {
        let snapButton = UIButton()
        snapButton.isUserInteractionEnabled = true
        snapButton.layer.cornerRadius = 10
        snapButton.translatesAutoresizingMaskIntoConstraints = false
        snapButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        snapButton.addTarget(self, action: #selector(self.didTapLinkButton), for: .touchUpInside)
        return snapButton
    }()

    private lazy var longpressGesture: UILongPressGestureRecognizer = {
        let lpgr = UILongPressGestureRecognizer.init(target: self, action: #selector(didLongPress(_:)))
        lpgr.minimumPressDuration = 0.2
        lpgr.delegate = self
        return lpgr
    }()
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tpgr = UITapGestureRecognizer(target: self, action: #selector(didTapSnap(_:)))
        tpgr.cancelsTouchesInView = false
        tpgr.numberOfTapsRequired = 1
        tpgr.delegate = self
        return tpgr
    }()
    private var previousSnapIndex: Int {
        return snapIndex - 1
    }
    private var videoSnapIndex: Int = 0
    private var handpickedSnapIndex: Int = 0
    var retryBtn: VisilabsRetryLoaderButton!
    var longPressGestureState: UILongPressGestureRecognizer.State?

    // MARK: - Public iVars
    public var direction: SnapMovementDirectionState = .forward
    public let scrollview: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    public var getSnapIndex: Int {
        return snapIndex
    }
    public var snapIndex: Int = 0 {
        didSet {
            scrollview.isUserInteractionEnabled = true
            if let st = story {
                setStoryShown(story: st)
            }
            switch direction {
            case .forward:
                if snapIndex < story?.items.count ?? 0 {
                    if let snap = story?.items[snapIndex] {
                        if snap.kind != MimeType.video {
                            if let snapView = getSnapview() {
                                startRequest(snapView: snapView, with: snap.url)
                            } else {
                                let snapView = createSnapView()

                                startRequest(snapView: snapView, with: snap.url)
                            }
                        } else {
                            if let videoView = getVideoView(with: snapIndex) {
                                startPlayer(videoView: videoView, with: snap.url)
                            } else {
                                let videoView = createVideoView()
                                startPlayer(videoView: videoView, with: snap.url)
                            }
                        }
                    }
                }
            case .backward:
                if snapIndex < story?.items.count ?? 0 {
                    if let snap = story?.items[snapIndex] {
                        if snap.kind != MimeType.video {
                            if let snapView = getSnapview() {
                                self.startRequest(snapView: snapView, with: snap.url)
                            }
                        } else {
                            if let videoView = getVideoView(with: snapIndex) {
                                startPlayer(videoView: videoView, with: snap.url)                            } else {
                                let videoView = self.createVideoView()
                                self.startPlayer(videoView: videoView, with: snap.url)
                            }
                        }
                    }
                }
            }
        }
    }
    public var story: VisilabsStory? {
        didSet {
            storyHeaderView.story = story
            if let picture = story?.smallImg {
                storyHeaderView.snaperImageView.setImage(url: picture)
            }
        }
    }

    // MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollview.frame = bounds
        loadUIElements()
        installLayoutConstraints()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        direction = .forward
        clearScrollViewGarbages()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private functions
    private func loadUIElements() {
        scrollview.delegate = self
        scrollview.isPagingEnabled = true
        scrollview.backgroundColor = .black
        contentView.addSubview(scrollview)
        contentView.addSubview(storyHeaderView)
        contentView.addSubview(snapButton)
        scrollview.addGestureRecognizer(longpressGesture)
        scrollview.addGestureRecognizer(tapGesture)
        
//        timerView.translatesAutoresizingMaskIntoConstraints = false
//        timerView.isUserInteractionEnabled = false
//        contentView.addSubview(timerView)

        
    }
    private func installLayoutConstraints() {
        // Setting constraints for scrollview
        NSLayoutConstraint.activate([
            scrollview.igLeftAnchor.constraint(equalTo: contentView.igLeftAnchor),
            contentView.igRightAnchor.constraint(equalTo: scrollview.igRightAnchor),
            scrollview.igTopAnchor.constraint(equalTo: contentView.igTopAnchor),
            contentView.igBottomAnchor.constraint(equalTo: scrollview.igBottomAnchor),
            scrollview.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0),
            scrollview.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1.0)
        ])
        NSLayoutConstraint.activate([
            storyHeaderView.igLeftAnchor.constraint(equalTo: contentView.igLeftAnchor),
            contentView.igRightAnchor.constraint(equalTo: storyHeaderView.igRightAnchor),
            storyHeaderView.igTopAnchor.constraint(equalTo: contentView.igTopAnchor),
            storyHeaderView.heightAnchor.constraint(equalToConstant: 80)
        ])
        NSLayoutConstraint.activate([
            snapButton.igBottomAnchor.constraint(equalTo: scrollview.igBottomAnchor, constant: -50),
            snapButton.centerXAnchor.constraint(equalTo: scrollview.centerXAnchor)
        ])
        
//        NSLayoutConstraint.activate([timerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//                                     timerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//                                     timerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//                                     timerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//                                    ])
    }
    private func createSnapView() -> UIImageView {
        let snapView = UIImageView()
        snapView.translatesAutoresizingMaskIntoConstraints = false
        snapView.tag = snapIndex + snapViewTagIndicator

//         Delete if there is any snapview/videoview already present in that frame location.
//         Because of snap delete functionality, snapview/videoview
//         can occupy different frames(created in 2nd position(frame),
//         when 1st postion snap gets deleted, it will move to first position) which leads to weird issues.
//         - If only snapViews are there, it will not create any issues.
//         - But if story contains both image and video snaps, there will be a chance in same position
//         both snapView and videoView gets created.
//         - That's why we need to remove if any snap exists on the same position.
//
        scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first?.removeFromSuperview()

        scrollview.addSubview(snapView)

        // Setting constraints for snap view.
        NSLayoutConstraint.activate([

            // snapButton.igBottomAnchor.constraint(equalTo: scrollview.igBottomAnchor, constant: -50),
            // snapButton.centerXAnchor.constraint(equalTo: scrollview.centerXAnchor),

            snapView.leadingAnchor.constraint(equalTo: (snapIndex == 0) ?
            scrollview.leadingAnchor : scrollview.subviews[previousSnapIndex].trailingAnchor),
            snapView.igTopAnchor.constraint(equalTo: scrollview.igTopAnchor),
            snapView.widthAnchor.constraint(equalTo: scrollview.widthAnchor),
            snapView.heightAnchor.constraint(equalTo: scrollview.heightAnchor),
            scrollview.igBottomAnchor.constraint(equalTo: snapView.igBottomAnchor)
        ])
        if snapIndex != 0 {
            NSLayoutConstraint.activate([
                snapView.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor,
                                                  constant: CGFloat(snapIndex)*scrollview.width)
            ])
        }
        return snapView
    }
    private func getSnapview() -> UIImageView? {
        let view = scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first
        if let imageView = view as? UIImageView {
            return imageView
        }
        return nil
    }
    private func createVideoView() -> VisilabsPlayerView {
        let videoView = VisilabsPlayerView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.tag = snapIndex + snapViewTagIndicator
        videoView.playerObserverDelegate = self

//         Delete if there is any snapview/videoview already present in that frame location.
//         Because of snap delete functionality, snapview/videoview
//         can occupy different frames(created in 2nd position(frame),
//         when 1st postion snap gets deleted, it will move to first position) which leads to weird issues.
//         - If only snapViews are there, it will not create any issues.
//         - But if story contains both image and video snaps, there will be a chance
//         in same position both snapView and videoView gets created.
//         - That's why we need to remove if any snap exists on the same position.

        scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first?.removeFromSuperview()

        scrollview.addSubview(videoView)
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: (snapIndex == 0)
            ? scrollview.leadingAnchor : scrollview.subviews[previousSnapIndex].trailingAnchor),
            videoView.igTopAnchor.constraint(equalTo: scrollview.igTopAnchor),
            videoView.widthAnchor.constraint(equalTo: scrollview.widthAnchor),
            videoView.heightAnchor.constraint(equalTo: scrollview.heightAnchor),
            scrollview.igBottomAnchor.constraint(equalTo: videoView.igBottomAnchor)
        ])
        if snapIndex != 0 {
            NSLayoutConstraint.activate([
                videoView.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor,
                                                   constant: CGFloat(snapIndex)*scrollview.width)
            ])
        }
        return videoView
    }
    private func getVideoView(with index: Int) -> VisilabsPlayerView? {
        let view = scrollview.subviews.filter({$0.tag == index + snapViewTagIndicator}).first
        if let videoView = view as? VisilabsPlayerView {
            return videoView
        }
        return nil
    }

    private func startRequest(snapView: UIImageView, with url: String) {
        snapView.setImage(url: url, style: .squared) { result in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return}
                switch result {
                case .success:
                    // Start progressor only if handpickedSnapIndex matches with snapIndex
                    // and the requested image url should be matched with current snapIndex imageurl
                    if strongSelf.handpickedSnapIndex == strongSelf.snapIndex
                        && url == strongSelf.story!.items[strongSelf.snapIndex].url {
                        strongSelf.startProgressors()
                    }
                case .failure:
                    strongSelf.showRetryButton(with: url, for: snapView)
                }
            }
        }
        if let story = self.story, story.items.count > self.snapIndex {
            if story.impressionQueryItems.count > 0 {
                Visilabs.callAPI().customEvent(VisilabsConstants.omEvtGif, properties: story.impressionQueryItems)
            }
            if story.items[self.snapIndex].buttonText.count > 0 {
                let snap = story.items[self.snapIndex]
                snapButton.isHidden = false
                snapButton.setTitle(snap.buttonText, for: .normal)
                snapButton.backgroundColor = snap.buttonColor
                snapButton.setTitleColor(snap.buttonTextColor, for: .normal)
            } else {
                snapButton.isHidden = true
            }
        }
    }

    private func showRetryButton(with url: String, for snapView: UIImageView) {
        self.retryBtn = VisilabsRetryLoaderButton.init(withURL: url)
        self.retryBtn.translatesAutoresizingMaskIntoConstraints = false
        self.retryBtn.delegate = self
        self.isUserInteractionEnabled = true
        snapView.addSubview(self.retryBtn)
        NSLayoutConstraint.activate([
            self.retryBtn.igCenterXAnchor.constraint(equalTo: snapView.igCenterXAnchor),
            self.retryBtn.igCenterYAnchor.constraint(equalTo: snapView.igCenterYAnchor)
        ])
    }
    private func startPlayer(videoView: VisilabsPlayerView, with url: String) {
        if scrollview.subviews.count > 0 {
            if story?.isCompletelyVisible == true {
                videoView.startAnimating()
                VisilabsVideoCacheManager.shared.getFile(for: url) { [weak self] (result) in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let videoURL):
                        // Start progressor only if handpickedSnapIndex matches with snapIndex
                        if strongSelf.handpickedSnapIndex == strongSelf.snapIndex {
                            let videoResource = VideoResource(filePath: videoURL.absoluteString)
                            videoView.play(with: videoResource)
                        }
                    case .failure(let error):
                        videoView.stopAnimating()
                        debugPrint("Video error: \(error)")
                    }
                }
            }
        }
    }
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        longPressGestureState = sender.state
        if sender.state == .began ||  sender.state == .ended {
            if sender.state == .began {
                pauseEntireSnap()
            } else {
                resumeEntireSnap()
            }
        }
    }
    @objc private func didTapSnap(_ sender: UITapGestureRecognizer) {

        let touchLocation = sender.location(ofTouch: 0, in: self.scrollview)

        if let snapCount = story?.items.count {
            var snpIndex = snapIndex
            /*!
             * Based on the tap gesture(X) setting the direction to either forward or backward
             */
            if let snap = story?.items[snpIndex], snap.kind == .photo, getSnapview()?.image == nil {
                // Remove retry button if tap forward or backward if it exists
                if let snapView = getSnapview(), let btn = retryBtn, snapView.subviews.contains(btn) {
                    snapView.removeRetryButton()
                }
                fillupLastPlayedSnap(snpIndex)
            } else {
                // Remove retry button if tap forward or backward if it exists
                if let videoView = getVideoView(with: snpIndex), let btn = retryBtn, videoView.subviews.contains(btn) {
                    videoView.removeRetryButton()
                }
                if getVideoView(with: snpIndex)?.player?.timeControlStatus != .playing {
                    fillupLastPlayedSnap(snpIndex)
                }
            }
            if touchLocation.x < scrollview.contentOffset.x + (scrollview.frame.width/2) {
                direction = .backward
                if snapIndex >= 1 && snapIndex <= snapCount {
                    clearLastPlayedSnaps(snpIndex)
                    stopSnapProgressors(with: snpIndex)
                    snpIndex -= 1
                    resetSnapProgressors(with: snpIndex)
                    willMoveToPreviousOrNextSnap(index: snpIndex)
                } else {
                    delegate?.moveToPreviousStory()
                }
            } else {
                if snapIndex >= 0 && snapIndex <= snapCount {
                    // Stopping the current running progressors
                    stopSnapProgressors(with: snpIndex)
                    direction = .forward
                    snpIndex += 1
                    willMoveToPreviousOrNextSnap(index: snpIndex)
                }
            }
        }
    }
    @objc private func didEnterForeground() {
        if let snap = story?.items[snapIndex] {
            if snap.kind == .video {
                let videoView = getVideoView(with: snapIndex)
                startPlayer(videoView: videoView!, with: snap.url)
            } else {
                startSnapProgress(with: snapIndex)
            }
        }
    }
    @objc private func didEnterBackground() {
        if let snap = story?.items[snapIndex] {
            if snap.kind == .video {
                stopPlayer()
            }
        }
        resetSnapProgressors(with: snapIndex)
    }

    @objc private func didTapLinkButton() {
        if let story = story {
            if story.clickQueryItems.count > 0 {
                Visilabs.callAPI().customEvent(VisilabsConstants.omEvtGif, properties: story.clickQueryItems)
            }
            if let del = self.storyUrlDelegate, let url = URL(string: story.items[snapIndex].targetUrl) {
                del.urlClicked(url)
                VisilabsLogger.info("Opening Story URL is delegated!! Url: \(url)")
            } else if story.items[snapIndex].targetUrl.count > 0, let snapUrl = URL(string: story.items[snapIndex].targetUrl) {
                VisilabsLogger.info("opening CTA URL: \(snapUrl)")
                VisilabsInstance.sharedUIApplication()?.performSelector(onMainThread:
                                    NSSelectorFromString("openURL:"), with: snapUrl, waitUntilDone: true)
            }
            delegate?.didTapCloseButton()
        }
    }
    
    private func timerConfiguration() {
        
    }
    
    private func calculateRemainingTime() {
        
    }
    
    private func mapRemainingTime(wantToEndTime:Date) -> [String] {
         
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let endDate = formatter.date(from: "2022/06/17 22:31")
        let startDate = Date()

        let differenceInSeconds = Int(endDate!.timeIntervalSince(startDate))
        
        let hourInSecond = 3600
        let minuteInSecond = 60
        
        let hourCount = differenceInSeconds / hourInSecond
        let minuteCount = (differenceInSeconds - (hourInSecond*hourCount)) / minuteInSecond
        let secondCount = (differenceInSeconds - (hourInSecond*hourCount) - (minuteInSecond*minuteCount))
        
        
        var hourCountStr = ""
        var minuteCountStr = ""
        var secondCountStr = ""
        
        if hourCount < 10 {
            hourCountStr = "0\(hourCount)"
        } else {
            hourCountStr = String(hourCount)
        }
        
        if minuteCount < 10 {
            minuteCountStr = "0\(minuteCount)"
        } else {
            minuteCountStr = String(minuteCount)
        }
        
        if secondCount < 10 {
            secondCountStr = "0\(secondCount)"
        } else {
            secondCountStr = String(secondCount)
        }
        
        var result = [String]()
        result.append("\(hourCountStr.first ?? "0")")
        result.append("\(hourCountStr.last ?? "0")")
        result.append("\(minuteCountStr.first ?? "0")")
        result.append("\(minuteCountStr.last ?? "0")")
        result.append("\(secondCountStr.first ?? "0")")
        result.append("\(secondCountStr.last ?? "0")")

        return result
    }

    private func willMoveToPreviousOrNextSnap(index: Int) {
        if let count = story?.items.count {
            if index < count {
                // Move to next or previous snap based on index n
                let xPoint = index.toFloat * frame.width
                let offset = CGPoint(x: xPoint, y: 0)
                scrollview.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = index
                handpickedSnapIndex = index
                snapIndex = index
            } else {
                delegate?.didCompletePreview()
            }
        }
    }
    @objc private func didCompleteProgress() {
        let index = snapIndex + 1
        if let count = story?.items.count {
            if index < count {
                // Move to next snap
                let xPoint = index.toFloat * frame.width
                let offset = CGPoint(x: xPoint, y: 0)
                scrollview.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = index
                direction = .forward
                handpickedSnapIndex = index
                snapIndex = index
            } else {
                stopPlayer()
                delegate?.didCompletePreview()
            }
        }
    }
    private func fillUpMissingImageViews(_ sIndex: Int) {
        if sIndex != 0 {
            for counter in 0 ..< sIndex {
                snapIndex = counter
            }
            let xValue = sIndex.toFloat * scrollview.frame.width
            scrollview.contentOffset = CGPoint(x: xValue, y: 0)
        }
    }
    // Before progress view starts we have to fill the progressView
    private func fillupLastPlayedSnap(_ sIndex: Int) {
        if let snap = story?.items[sIndex], snap.kind == .video {
            videoSnapIndex = sIndex
            stopPlayer()
        }
        if let holderView = self.getProgressIndicatorView(with: sIndex),
            let progressView = self.getProgressView(with: sIndex) {
            progressView.widthConstraint?.isActive = false
            progressView.widthConstraint = progressView.widthAnchor.constraint(equalTo: holderView.widthAnchor,
                                                                               multiplier: 1.0)
            progressView.widthConstraint?.isActive = true
        }
    }
    private func fillupLastPlayedSnaps(_ sIndex: Int) {
        // Coz, we are ignoring the first.snap
        if sIndex != 0 {
            for counter in 0..<sIndex {
                if let holderView = self.getProgressIndicatorView(with: counter),
                    let progressView = self.getProgressView(with: counter) {
                    progressView.widthConstraint?.isActive = false
                    progressView.widthConstraint = progressView.widthAnchor.constraint(equalTo: holderView.widthAnchor,
                                                                                       multiplier: 1.0)
                    progressView.widthConstraint?.isActive = true
                }
            }
        }
    }
    private func clearLastPlayedSnaps(_ sIndex: Int) {
        if self.getProgressIndicatorView(with: sIndex) != nil,
            let progressView = self.getProgressView(with: sIndex) {
            progressView.widthConstraint?.isActive = false
            progressView.widthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
            progressView.widthConstraint?.isActive = true
        }
    }
    private func clearScrollViewGarbages() {
        scrollview.contentOffset = CGPoint(x: 0, y: 0)
        if scrollview.subviews.count > 0 {
            var indicator = 0 + snapViewTagIndicator
            var snapViews = [UIView]()
            scrollview.subviews.forEach({ (imageView) in
                if imageView.tag == indicator {
                    snapViews.append(imageView)
                    indicator += 1
                }
            })
            if snapViews.count > 0 {
                snapViews.forEach({ (view) in
                    view.removeFromSuperview()
                })
            }
        }
    }
    private func gearupTheProgressors(type: MimeType, playerView: VisilabsPlayerView? = nil) {
        if let holderView = getProgressIndicatorView(with: snapIndex),
            let progressView = getProgressView(with: snapIndex) {
            progressView.storyIdentifier = self.story?.internalIdentifier
            progressView.snapIndex = snapIndex

            var timeInterval = TimeInterval(5)
            if let displayTime = self.story?.items[snapIndex].displayTime {
                timeInterval = TimeInterval(displayTime)
            }

            DispatchQueue.main.async {
                if type == .photo {
                    progressView.start(with: timeInterval,
                                       holderView: holderView,
                                       completion: {(_, snapIndex, isCancelledAbruptly) in
                        print("Completed snapindex: \(snapIndex)")
                        if isCancelledAbruptly == false {
                            self.didCompleteProgress()
                        }
                    })
                } else {
                    // Handled in delegate methods for videos
                }
            }
        }
    }

    // MARK: - Internal functions
    func startProgressors() {
        DispatchQueue.main.async {
            if self.scrollview.subviews.count > 0 {
                let view = self.scrollview.subviews.filter {view in view.tag == self.snapIndex
                    + snapViewTagIndicator}.first
                let imageView = view as? UIImageView
                if imageView?.image != nil && self.story?.isCompletelyVisible == true {
                    self.gearupTheProgressors(type: .photo)
                } else {
                    // Didend displaying will call this startProgressors method.
                    // After that only isCompletelyVisible get true.
                    // Then we have to start the video if that snap contains video.
                    if self.story?.isCompletelyVisible == true {
                        let view = self.scrollview.subviews.filter {view in view.tag == self.snapIndex
                            + snapViewTagIndicator}.first
                        let videoView = view as? VisilabsPlayerView
                        let snap = self.story?.items[self.snapIndex]
                        if let view = videoView, self.story?.isCompletelyVisible == true {
                            self.startPlayer(videoView: view, with: snap!.url)
                        }
                    }
                }
            }
        }
    }

    func getProgressView(with index: Int) -> VisilabsSnapProgressView? {
        let progressView = storyHeaderView.getProgressView
        if progressView.subviews.count > 0 {
            let prgView = getProgressIndicatorView(with: index)?.subviews.first as? VisilabsSnapProgressView
            guard let currentStory = self.story else {
                fatalError("story not found")
            }
            prgView?.story = currentStory
            return prgView
        }
        return nil
    }
    func getProgressIndicatorView(with index: Int) -> VisilabsSnapProgressIndicatorView? {
        let progressView = storyHeaderView.getProgressView
        let indicatorView = progressView.subviews.filter({view in view.tag == index+progressIndicatorViewTag}).first
            as? VisilabsSnapProgressIndicatorView
        return indicatorView ?? nil
    }
    func adjustPreviousSnapProgressorsWidth(with index: Int) {
        fillupLastPlayedSnaps(index)
    }

    // MARK: - Public functions
    public func willDisplayCellForZerothIndex(with sIndex: Int, handpickedSnapIndex: Int) {
        self.handpickedSnapIndex = handpickedSnapIndex
        story?.isCompletelyVisible = true
        willDisplayCell(with: handpickedSnapIndex)
    }
    public func willDisplayCell(with sIndex: Int) {
        // TO_DO:Make sure to move filling part and creating at one place
        // Clear the progressor subviews before the creating new set of progressors.
        storyHeaderView.clearTheProgressorSubviews()
        storyHeaderView.createSnapProgressors()
        fillUpMissingImageViews(sIndex)
        fillupLastPlayedSnaps(sIndex)
        snapIndex = sIndex

        // Remove the previous observors
        // swiftlint:disable notification_center_detachment
        NotificationCenter.default.removeObserver(self)

        // Add the observer to handle application from background to foreground
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    public func startSnapProgress(with sIndex: Int) {
        if let indicatorView = getProgressIndicatorView(with: sIndex),
            let prgView = getProgressView(with: sIndex) {
            var timeInterval = TimeInterval(5)
            if let displayTime = self.story?.items[sIndex].displayTime {
                timeInterval = TimeInterval(displayTime)
            }
            prgView.start(with: timeInterval, holderView: indicatorView, completion: { (_, _, isCancelledAbruptly) in
                if isCancelledAbruptly == false {
                    self.didCompleteProgress()
                }
            })
        }
    }
    public func pauseSnapProgressors(with sIndex: Int) {
        story?.isCompletelyVisible = false
        getProgressView(with: sIndex)?.pause()
    }
    public func stopSnapProgressors(with sIndex: Int) {
        getProgressView(with: sIndex)?.stop()
    }
    public func resetSnapProgressors(with sIndex: Int) {
        self.getProgressView(with: sIndex)?.reset()
    }
    public func pausePlayer(with sIndex: Int) {
        getVideoView(with: sIndex)?.pause()
    }
    public func stopPlayer() {
        let videoView = getVideoView(with: videoSnapIndex)
        if videoView?.player?.timeControlStatus != .playing {
            getVideoView(with: videoSnapIndex)?.player?.replaceCurrentItem(with: nil)
        }
        videoView?.stop()
        // getVideoView(with: videoSnapIndex)?.player = nil
    }
    public func resumePlayer(with sIndex: Int) {
        getVideoView(with: sIndex)?.play()
    }
    public func didEndDisplayingCell() {

    }
    public func resumePreviousSnapProgress(with sIndex: Int) {
        getProgressView(with: sIndex)?.resume()
    }
    public func pauseEntireSnap() {
        let progress = getProgressView(with: snapIndex)
        let view = scrollview.subviews.filter {view in view.tag == snapIndex + snapViewTagIndicator}.first
        let videoView = view as? VisilabsPlayerView
        if videoView != nil {
            progress?.pause()
            videoView?.pause()
        } else {
            progress?.pause()
        }
    }
    public func resumeEntireSnap() {
        let progress = getProgressView(with: snapIndex)
        let view = scrollview.subviews.filter {view in view.tag == snapIndex + snapViewTagIndicator}.first
        let videoView = view as? VisilabsPlayerView
        if videoView != nil {
            progress?.resume()
            videoView?.play()
        } else {
            progress?.resume()
        }
    }
    // Used the below function for image retry option
    public func retryRequest(view: UIView, with url: String) {
        if let imgView = view as? UIImageView {
            imgView.removeRetryButton()
            self.startRequest(snapView: imgView, with: url)
        } else if let playerView = view as? VisilabsPlayerView {
            playerView.removeRetryButton()
            self.startPlayer(videoView: playerView, with: url)
        }
    }

    private func setStoryShown(story: VisilabsStory) {
        var shownStories = UserDefaults.standard.dictionary(forKey: VisilabsConstants.shownStories)
            as? [String: [String]] ?? [String: [String]]()

        if shownStories["\(story.actid)"] == nil {
            shownStories["\(story.actid)"] = [story.title ?? ""]
        } else if let st = shownStories["\(story.actid)"], !st.contains(story.title ?? "-") {
            shownStories["\(story.actid)"]?.append(story.title ?? "")
        }
        UserDefaults.standard.setValue(shownStories, forKey: VisilabsConstants.shownStories)
    }
}

// MARK: - Extension|StoryPreviewHeaderProtocol
extension VisilabsStoryPreviewCell: StoryPreviewHeaderProtocol {
    func didTapCloseButton() {
        delegate?.didTapCloseButton()
    }
}

// MARK: - Extension|RetryBtnDelegate
extension VisilabsStoryPreviewCell: RetryBtnDelegate {
    func retryButtonTapped() {
        self.retryRequest(view: retryBtn.superview!, with: retryBtn.contentURL!)
    }
}

// MARK: - Extension|IGPlayerObserverDelegate
extension VisilabsStoryPreviewCell: VisilabsPlayerObserver {

    func didStartPlaying() {
        if let videoView = getVideoView(with: snapIndex), videoView.currentTime <= 0 {
            if videoView.error == nil && (story?.isCompletelyVisible)! == true {
                if let holderView = getProgressIndicatorView(with: snapIndex),
                    let progressView = getProgressView(with: snapIndex) {
                    progressView.storyIdentifier = self.story?.internalIdentifier
                    progressView.snapIndex = snapIndex
                    if let duration = videoView.currentItem?.asset.duration {
                        if Float(duration.value) > 0 {
                            progressView.start(with: duration.seconds,
                                               holderView: holderView,
                                               completion: {(_, snapIndex, isCancelledAbruptly) in
                                if isCancelledAbruptly == false {
                                    self.videoSnapIndex = snapIndex
                                    self.stopPlayer()
                                    self.didCompleteProgress()
                                } else {
                                    self.videoSnapIndex = snapIndex
                                    self.stopPlayer()
                                }
                            })
                        } else {
                            debugPrint("Player error: Unable to play the video")
                        }
                    }
                }
            }
        }
    }
    func didFailed(withError error: String, for url: URL?) {
        debugPrint("Failed with error: \(error)")
        if let videoView = getVideoView(with: snapIndex), let videoURL = url {
            self.retryBtn = VisilabsRetryLoaderButton(withURL: videoURL.absoluteString)
            self.retryBtn.translatesAutoresizingMaskIntoConstraints = false
            self.retryBtn.delegate = self
            self.isUserInteractionEnabled = true
            videoView.addSubview(self.retryBtn)
            NSLayoutConstraint.activate([
                self.retryBtn.igCenterXAnchor.constraint(equalTo: videoView.igCenterXAnchor),
                self.retryBtn.igCenterYAnchor.constraint(equalTo: videoView.igCenterYAnchor)
            ])
        }
    }
    func didCompletePlay() {
        // Video completed
    }

}

extension VisilabsStoryPreviewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            return true
        }
        return false
    }
}
