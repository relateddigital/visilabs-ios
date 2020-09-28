//
//  VisilabsStoryHomeViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 28.09.2020.
//

import Foundation

public class VisilabsStoryHomeViewController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var stories = [VisilabsStory]()
    var storiesLoaded = false
    
    func loadStories(stories: [VisilabsStory]){
        self.stories = stories
        self.storiesLoaded = true
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storiesLoaded ? stories.count : 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if !storiesLoaded {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisilabsStoryHomeViewCell.reuseIdentifier,for: indexPath) as? VisilabsStoryHomeViewCell else { fatalError() }
            cell.setAsLoadingCell()
            return cell
        }else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisilabsStoryHomeViewCell.reuseIdentifier,for: indexPath) as? VisilabsStoryHomeViewCell else { fatalError() }
            cell.story = self.stories[indexPath.row]
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

    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
}
