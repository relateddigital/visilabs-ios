//
//  VisilabsStoryPreviewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 7.10.2020.
//

import UIKit

final class VisilabsStoryPreviewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Private Vars
    private var _view: VisilabsStoryPreviewView {return view as? VisilabsStoryPreviewView
        ?? VisilabsStoryPreviewView(frame: view.frame)}
    private var viewModel: VisilabsStoryPreviewModel?

    private(set) var stories: [VisilabsStory]
    /** This index will tell you which Story, user has picked*/
    private(set) var handPickedStoryIndex: Int // starts with(i)
    /** This index will tell you which Snap, user has picked*/
    private(set) var handPickedSnapIndex: Int // starts with(i)
    /** This index will help you simply iterate the story one by one*/

    private var nStoryIndex: Int = 0 // iteration(i+1)
    private var storyCopy: VisilabsStory?
    private(set) var layoutType: VisilabsLayoutType
    private(set) var executeOnce = false

    // check whether device rotation is happening or not
    private(set) var isTransitioning = false

    private let dismissGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .down
        return gesture
    }()

    weak var storyUrlDelegate: VisilabsStoryURLDelegate?

    // MARK: - Overriden functions
    override func loadView() {
        super.loadView()
        view = VisilabsStoryPreviewView.init(layoutType: self.layoutType)
        viewModel = VisilabsStoryPreviewModel(self.stories)
        _view.snapsCollectionView.decelerationRate = .fast
        dismissGesture.delegate = self
        dismissGesture.addTarget(self, action: #selector(didSwipeDown(_:)))
        _view.snapsCollectionView.addGestureRecognizer(dismissGesture)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        if UIDevice.current.userInterfaceIdiom == .phone {
            // TO_DO: AppDelegate e ulaşamadığım için bunu yapamıyorum
            // IGAppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        }
        if !executeOnce {
            DispatchQueue.main.async {
                self._view.snapsCollectionView.delegate = self
                self._view.snapsCollectionView.dataSource = self
                let indexPath = IndexPath(item: self.handPickedStoryIndex, section: 0)
                self._view.snapsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                self.handPickedStoryIndex = 0
                self.executeOnce = true
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            // Don't forget to reset when view is being removed
            // TO_DO: AppDelegate e ulaşamadığım için bunu yapamıyorum
            // IGAppUtility.lockOrientation(.all)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isTransitioning = true
        _view.snapsCollectionView.collectionViewLayout.invalidateLayout()
    }
    init(layout: VisilabsLayoutType = .parallax,
         stories: [VisilabsStory],
         handPickedStoryIndex: Int,
         handPickedSnapIndex: Int = 0) {
        self.layoutType = layout
        self.stories = stories
        self.handPickedStoryIndex = handPickedStoryIndex
        self.handPickedSnapIndex = handPickedSnapIndex
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var prefersStatusBarHidden: Bool { return true }

    // MARK: - Selectors
    @objc func didSwipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extension|UICollectionViewDataSource
extension VisilabsStoryPreviewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = viewModel else {return 0}
        return model.numberOfItemsInSection(section)
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                    VisilabsStoryPreviewCell.reuseIdentifier, for: indexPath)
                as? VisilabsStoryPreviewCell else {
            return UICollectionViewCell()
        }
        let story = viewModel?.cellForItemAtIndexPath(indexPath)
        cell.story = story
        cell.delegate = self
        cell.storyUrlDelegate = self.storyUrlDelegate
        nStoryIndex = indexPath.item
        return cell
    }
}

// MARK: - Extension|UICollectionViewDelegate
extension VisilabsStoryPreviewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? VisilabsStoryPreviewCell else {
            return
        }

        // Taking Previous(Visible) cell to store previous story
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? VisilabsStoryPreviewCell
        if let vCell = visibleCell {
            vCell.story?.isCompletelyVisible = false
            vCell.pauseSnapProgressors(with: (vCell.story?.lastPlayedSnapIndex)!)
            storyCopy = vCell.story
        }
        // Prepare the setup for first time story launch
        if storyCopy == nil {
            cell.willDisplayCellForZerothIndex(with: cell.story?.lastPlayedSnapIndex ?? 0,
                                               handpickedSnapIndex: handPickedSnapIndex)
            return
        }
        if indexPath.item == nStoryIndex {
            let story = stories[nStoryIndex+handPickedStoryIndex]
            cell.willDisplayCell(with: story.lastPlayedSnapIndex)
        }
        /// Setting to 0, otherwise for next story snaps,
        ///  it will consider the same previous story's handPickedSnapIndex.
        /// It will create issue in starting the snap progressors.
        handPickedSnapIndex = 0
    }
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? VisilabsStoryPreviewCell
        guard let vCell = visibleCell else {return}
        guard let vCellIndexPath = _view.snapsCollectionView.indexPath(for: vCell) else {
            return
        }
        vCell.story?.isCompletelyVisible = true

        if vCell.story == storyCopy {
            nStoryIndex = vCellIndexPath.item
            if vCell.longPressGestureState == nil {
                vCell.resumePreviousSnapProgress(with: (vCell.story?.lastPlayedSnapIndex)!)
            }
            if (vCell.story?.items[vCell.story?.lastPlayedSnapIndex ?? 0])?.kind == .video {
                vCell.resumePlayer(with: vCell.story?.lastPlayedSnapIndex ?? 0)
            }
            vCell.longPressGestureState = nil
        } else {
            if let cell = cell as? VisilabsStoryPreviewCell {
                cell.stopPlayer()
            }
            vCell.startProgressors()
        }
        if vCellIndexPath.item == nStoryIndex {
            vCell.didEndDisplayingCell()
        }
    }
}

// MARK: - Extension|UICollectionViewDelegateFlowLayout
extension VisilabsStoryPreviewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        /* During device rotation, invalidateLayout gets call to make cell width and height proper.
         * InvalidateLayout methods call this UICollectionViewDelegateFlowLayout method,
         and the scrollView content offset moves to (0, 0). Which is not the expected result.
         * To keep the contentOffset to that same position adding the below code
         which will execute after 0.1 second because need time for collectionView adjusts its width and height.
         * Adjusting preview snap progressors width to Holder view width because
         when animation finished in portrait orientation, when we switch to landscape orientation,
         we have to update the progress view width for preview snap progressors also.
         * Also, adjusting progress view width to updated frame width when the progress view animation is executing.
         */
        if isTransitioning {
            let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
            let visibleCell = visibleCells.first as? VisilabsStoryPreviewCell
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                guard let strongSelf = self,
                    let vCell = visibleCell,
                    let progressIndicatorView = vCell.getProgressIndicatorView(with: vCell.snapIndex),
                    let progress = vCell.getProgressView(with: vCell.snapIndex) else {
                        fatalError("Visible cell or progressIndicatorView or progressView is nil")
                }
                vCell.scrollview.setContentOffset(CGPoint(x: CGFloat(vCell.snapIndex) * collectionView.frame.width,
                                                          y: 0), animated: false)
                vCell.adjustPreviousSnapProgressorsWidth(with: vCell.snapIndex)

                if progress.state == .running {
                    progress.widthConstraint?.constant = progressIndicatorView.frame.width
                }
                strongSelf.isTransitioning = false
            }
        }
        if #available(iOS 11.0, *) {
            return CGSize(width: _view.snapsCollectionView.safeAreaLayoutGuide.layoutFrame.width,
                          height: _view.snapsCollectionView.safeAreaLayoutGuide.layoutFrame.height)
        } else {
            return CGSize(width: _view.snapsCollectionView.frame.width, height: _view.snapsCollectionView.frame.height)
        }
    }
}

// MARK: - Extension|UIScrollViewDelegate<CollectionView>
extension VisilabsStoryPreviewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let vCell = _view.snapsCollectionView.visibleCells.first as? VisilabsStoryPreviewCell else {return}
        vCell.pauseSnapProgressors(with: (vCell.story?.lastPlayedSnapIndex)!)
        vCell.pausePlayer(with: (vCell.story?.lastPlayedSnapIndex)!)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let sortedVCells = _view.snapsCollectionView.visibleCells.sortedArrayByPosition()
        guard let firstCell = sortedVCells.first as? VisilabsStoryPreviewCell else {return}
        guard let lastCell = sortedVCells.last as? VisilabsStoryPreviewCell else {return}
        let firstIndexPath = _view.snapsCollectionView.indexPath(for: firstCell)
        let lastIndexPath = _view.snapsCollectionView.indexPath(for: lastCell)
        let numberOfItems = collectionView(_view.snapsCollectionView, numberOfItemsInSection: 0)-1
        if lastIndexPath?.item == 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                self.dismiss(animated: true, completion: nil)
            }
        } else if firstIndexPath?.item == numberOfItems {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - StoryPreview Protocol implementation
extension VisilabsStoryPreviewController: VisilabsStoryPreviewProtocol {
    func didCompletePreview() {
        let number = handPickedStoryIndex+nStoryIndex+1
        if number < stories.count {
            // Move to next story
            storyCopy = stories[nStoryIndex+handPickedStoryIndex]
            nStoryIndex += 1
            let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
            // _view.snapsCollectionView.layer.speed = 0;
            _view.snapsCollectionView.scrollToItem(at: nIndexPath, at: .right, animated: true)
            /**@Note:
             Here we are navigating to next snap explictly, So we need to handle the isCompletelyVisible.
             With help of this Bool variable we are requesting snap.
             Otherwise cell wont get Image as well as the Progress move :P
             */
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func moveToPreviousStory() {
        // let n = handPickedStoryIndex+nStoryIndex+1
        let number = nStoryIndex+1
        if number <= stories.count && number > 1 {
            storyCopy = stories[nStoryIndex+handPickedStoryIndex]
            nStoryIndex -= 1
            let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
            _view.snapsCollectionView.scrollToItem(at: nIndexPath, at: .left, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func didTapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension Array {
     func sortedArrayByPosition() -> [Element] {
        return sorted(by: { (obj1: Element, obj2: Element) -> Bool in

            let view1 = obj1 as? UIView ?? UIView()
            let view2 = obj2 as? UIView ?? UIView()

            let x1Point = view1.frame.minX
            let y1Point = view1.frame.minY
            let x2Point = view2.frame.minX
            let y2Point = view2.frame.minY

            if y1Point != y2Point {
                return y1Point < y2Point
            } else {
                return x1Point < x2Point
            }
        })
    }
}
