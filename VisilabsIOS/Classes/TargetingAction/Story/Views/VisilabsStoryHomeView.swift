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
        let colView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        colView.backgroundColor = .clear // .orange // .white
        colView.showsVerticalScrollIndicator = false
        colView.showsHorizontalScrollIndicator = false
        colView.register(VisilabsStoryHomeViewCell.self,
                         forCellWithReuseIdentifier: VisilabsStoryHomeViewCell.reuseIdentifier)
        colView.translatesAutoresizingMaskIntoConstraints = false
        return colView
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
