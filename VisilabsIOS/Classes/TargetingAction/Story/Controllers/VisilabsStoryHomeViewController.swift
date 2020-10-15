//
//  VisilabsStoryHomeViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 28.09.2020.
//

import Foundation
import UIKit

public class VisilabsStoryHomeViewController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    var storyAction : VisilabsStoryAction!
    var storiesLoaded = false
    
    func loadStoryAction(_ storyAction: VisilabsStoryAction) {
        self.storyAction = storyAction
        self.storiesLoaded = true
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storiesLoaded ? storyAction.stories.count : 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if !storiesLoaded {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisilabsStoryHomeViewCell.reuseIdentifier,for: indexPath) as? VisilabsStoryHomeViewCell else { fatalError() }
            cell.setAsLoadingCell()
            //cell.contentView.isUserInteractionEnabled = false
            return cell
        }else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisilabsStoryHomeViewCell.reuseIdentifier,for: indexPath) as? VisilabsStoryHomeViewCell else { fatalError() }
            cell.story = self.storyAction.stories[indexPath.row]
            cell.setProperties(self.storyAction.extendedProperties)
            //cell.contentView.isUserInteractionEnabled = false
            return cell
        }

        /*
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisilabsStoryHomeViewCell.reuseIdentifier, for: indexPath) as? VisilabsStoryHomeViewCell else { fatalError() }
            cell.userDetails = ("Your story","https://avatars2.githubusercontent.com/u/32802714?s=200&v=4")
            return cell
        }else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisilabsStoryHomeViewCell.reuseIdentifier,for: indexPath) as? VisilabsStoryHomeViewCell else { fatalError() }
            let story = viewModel.cellForItemAt(indexPath: indexPath)
            cell.story = story
            return cell
        }
         */
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.storyAction.stories.count == 0 {
            return
        }
        
        if self.storyAction.storyTemplate == .SkinBased {
            DispatchQueue.main.async {
                let storyPreviewScene = VisilabsStoryPreviewController.init(stories: self.storyAction.stories, handPickedStoryIndex: indexPath.row, handPickedSnapIndex: 0)
                VisilabsInstance.sharedUIApplication()?.keyWindow?.rootViewController?.present(storyPreviewScene, animated: true, completion: nil) //TODO: burada keywindow rootViewController yaklaşımı uygun mu?
            }            
        } else {
            
            if self.storyAction.clickQueryString.count > 0 {
                let qsArr = self.storyAction.clickQueryString.components(separatedBy: "&")
                var properties = [String: String]()
                //properties["OM.domain"] =  "\(self.visilabsProfile.dataSource)_IOS" // TODO: OM.domain ne için gerekiyor?
                properties["OM.zn"] = qsArr[0].components(separatedBy: "=")[1]
                properties["OM.zpc"] = qsArr[1].components(separatedBy: "=")[1]
                Visilabs.callAPI().customEvent("OM_evt.gif", properties: properties)
            }
            let story = self.storyAction.stories[indexPath.row]
            if let storyLink = story.link, let storyUrl = URL(string: storyLink) {
                VisilabsLogger.info("opening CTA URL: \(storyUrl)")
                VisilabsInstance.sharedUIApplication()?.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: storyUrl, waitUntilDone: true)
            }
        }
    }
 
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
}
