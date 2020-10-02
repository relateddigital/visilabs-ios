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
    
    var stories = [VisilabsStory]()
    var extendedProperties = VisilabsStoryActionExtendedProperties()
    var clickQueryString = ""
    var storiesLoaded = false
    
    func loadStoryAction(_ storyAction: VisilabsStoryAction){
        self.stories = storyAction.stories
        self.extendedProperties = storyAction.extendedProperties
        self.clickQueryString = storyAction.clickQueryString
        self.storiesLoaded = true
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storiesLoaded ? stories.count : 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if !storiesLoaded {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisilabsStoryHomeViewCell.reuseIdentifier,for: indexPath) as? VisilabsStoryHomeViewCell else { fatalError() }
            cell.setAsLoadingCell()
            //cell.contentView.isUserInteractionEnabled = false
            return cell
        }else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisilabsStoryHomeViewCell.reuseIdentifier,for: indexPath) as? VisilabsStoryHomeViewCell else { fatalError() }
            cell.story = self.stories[indexPath.row]
            cell.setProperties(extendedProperties)
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
        if self.stories.count == 0 {
            return
        }
        if self.clickQueryString.count > 0 {
            let qsArr = self.clickQueryString.components(separatedBy: "&")
            var properties = [String: String]()
            //properties["OM.domain"] =  "\(self.visilabsProfile.dataSource)_IOS" // TODO: OM.domain ne için gerekiyor?
            properties["OM.zn"] = qsArr[0].components(separatedBy: "=")[1]
            properties["OM.zpc"] = qsArr[1].components(separatedBy: "=")[1]
            Visilabs.callAPI().customEvent("OM_evt.gif", properties: properties)
        }
        let story = self.stories[indexPath.row]
        if let storyLink = story.link, let storyUrl = URL(string: storyLink) {
            VisilabsLogger.info("opening CTA URL: \(storyUrl)")
            VisilabsInstance.sharedUIApplication()?.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: storyUrl, waitUntilDone: true)
        }
        
        
        
        print(indexPath.row)
    }
 
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
}
