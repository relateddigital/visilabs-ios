//
//  VisilabsStoryHomeViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 28.09.2020.
//

import Foundation
import UIKit

public class VisilabsStoryHomeViewController: NSObject,
                                              UICollectionViewDataSource,
                                              UICollectionViewDelegate,
                                              UICollectionViewDelegateFlowLayout {
    
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    public weak var urlDelegate: VisilabsStoryURLDelegate?
    
    var storyAction: VisilabsStoryAction!
    var storiesLoaded = false
    
    func loadStoryAction(_ storyAction: VisilabsStoryAction) {
        self.storyAction = storyAction
        self.storiesLoaded = true
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storiesLoaded ? storyAction.stories.count : 1
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !storiesLoaded {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                                    VisilabsStoryHomeViewCell.reuseIdentifier, for: indexPath)
                    as? VisilabsStoryHomeViewCell else {
                        return UICollectionViewCell()
                    }
            cell.setAsLoadingCell()
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                                    VisilabsStoryHomeViewCell.reuseIdentifier, for: indexPath)
                    as? VisilabsStoryHomeViewCell else {
                        return UICollectionViewCell()
                    }
            if self.storyAction.extendedProperties.moveShownToEnd {
                self.storyAction.stories = sortStories(stories: self.storyAction.stories)
            }
            cell.story = self.storyAction.stories[indexPath.row]
            cell.setProperties(self.storyAction.extendedProperties, self.storyAction.actionId)
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.storyAction.stories.count == 0 {
            return
        }
        let title = self.storyAction.stories[indexPath.row].title ?? ""
        let actid = self.storyAction.actionId
        self.setStoryShown(title: title, actid: actid)
        
        if self.storyAction.storyTemplate == .skinBased {
            DispatchQueue.main.async {
                for index in self.storyAction.stories.indices {
                    self.storyAction.stories[index].lastPlayedSnapIndex = 0
                    self.storyAction.stories[index].isCompletelyVisible = false
                    self.storyAction.stories[index].isCancelledAbruptly = false
                }
                let storyPreviewScene = VisilabsStoryPreviewController.init(stories: self.storyAction.stories,
                                                                            handPickedStoryIndex: indexPath.row, handPickedSnapIndex: 0)
                storyPreviewScene.storyUrlDelegate = self.urlDelegate
                storyPreviewScene.modalPresentationStyle = .fullScreen
                self.getRootViewController()?.present(storyPreviewScene, animated: true, completion: collectionView.reloadData)
            }
        } else {
            
            if self.storyAction.clickQueryItems.count > 0 {
                Visilabs.callAPI().customEvent(VisilabsConstants.omEvtGif, properties: self.storyAction.clickQueryItems)
            }
            let story = self.storyAction.stories[indexPath.row]
            if let storyLink = story.link, let storyUrl = URL(string: storyLink) {
                VisilabsLogger.info("opening CTA URL: \(storyUrl)")
                let app = VisilabsInstance.sharedUIApplication()
                app?.performSelector(onMainThread: NSSelectorFromString("openURL:"),
                                     with: storyUrl, waitUntilDone: true)
                collectionView.reloadData()
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
    
    // First not shown stories
    private func sortStories(stories: [VisilabsStory]) -> [VisilabsStory] {
        
        var shownStories: [VisilabsStory] = []
        var notShownStories: [VisilabsStory] = []
        for story in stories {
            var shown = false
            // check story has shown
            if let shownStories = UserDefaults.standard.dictionary(forKey: VisilabsConstants.shownStories) as? [String: [String]] {
                if let shownStoriesWithAction = shownStories["\(self.storyAction.actionId)"], shownStoriesWithAction.contains(story.title ?? "-") {
                    shown = true
                }
            }
            if shown {
                shownStories.append(story)
            } else {
                notShownStories.append(story)
            }
        }
        return notShownStories + shownStories
    }
    
    private func setStoryShown(title: String, actid: Int) {
        // Save UserDefaults as shown
        var shownStories = UserDefaults.standard.dictionary(forKey: VisilabsConstants.shownStories)
        as? [String: [String]] ?? [String: [String]]()
        if shownStories["\(actid)"] == nil {
            shownStories["\(actid)"] = [title]
        } else if let st = shownStories["\(actid)"], !st.contains(title) {
            shownStories["\(actid)"]?.append(title)
        }
        UserDefaults.standard.setValue(shownStories, forKey: VisilabsConstants.shownStories)
    }
    
    func getRootViewController() -> UIViewController? {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else {
            return nil
        }
        if let rootViewController = sharedUIApplication.keyWindow?.rootViewController {
            return getVisibleViewController(rootViewController)
        }
        return nil
    }
    
    private func getVisibleViewController(_ vc: UIViewController?) -> UIViewController? {
        if vc is UINavigationController {
            return getVisibleViewController((vc as? UINavigationController)?.visibleViewController)
        } else if vc is UITabBarController {
            return getVisibleViewController((vc as? UITabBarController)?.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return getVisibleViewController(pvc.presentedViewController)
            } else {
                return vc
            }
        }
    }
    
}

@objc
public protocol VisilabsStoryURLDelegate: NSObjectProtocol {
    @objc
    func urlClicked( _ url: URL)
}
