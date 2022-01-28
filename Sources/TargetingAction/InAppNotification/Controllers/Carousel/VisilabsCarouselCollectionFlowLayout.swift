//
//  VisilabsCarouselCollectionFlowLayout.swift
//  CleanyModal
//
//  Created by Umut Can Alparslan on 28.01.2022.
//

import UIKit

class VisilabsCarouselCollectionFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else { return .zero }
        let center = CGPoint(x: collectionView.contentOffset.x + (collectionView.frame.width / 2), y: (collectionView.frame.height / 2))
        guard let indexPath = collectionView.indexPathForItem(at: center) else { return .zero }
        let attributes =  collectionView.layoutAttributesForItem(at: indexPath)
        let newOriginForOldIndex = attributes?.frame.origin
        return newOriginForOldIndex ?? proposedContentOffset
    }
}
