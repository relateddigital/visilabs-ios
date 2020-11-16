//
//  VisilabsStoryHomeView.swift
//  VisilabsIOS
//
//  Created by Egemen on 22.09.2020.
//

import UIKit

public class VisilabsStoryHomeView: UIView {

    // MARK: - iVars
    lazy var layout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 80, height: 100)
        return flowLayout
    }()
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear // .orange // .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(VisilabsStoryHomeViewCell.self, forCellWithReuseIdentifier: VisilabsStoryHomeViewCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    // MARK: - Overridden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear // UIColor.white // UIColor.rgb(from: 0xEFEFF4)
        createUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    public var controller: VisilabsStoryHomeViewController?

    func setDelegates() {
        self.collectionView.delegate = controller
        self.collectionView.dataSource = controller
    }

    // MARK: - Private functions
    private func createUIElements() {
        addSubview(collectionView)
    }
    private func installLayoutConstraints() {
        NSLayoutConstraint.activate([
            igLeftAnchor.constraint(equalTo: collectionView.igLeftAnchor),
            igTopAnchor.constraint(equalTo: collectionView.igTopAnchor),
            collectionView.igRightAnchor.constraint(equalTo: igRightAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100)])
    }
}
