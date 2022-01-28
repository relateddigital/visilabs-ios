//
//  VisilabsCarouselCollectionController.swift
//  CleanyModal
//
//  Created by Umut Can Alparslan on 28.01.2022.
//

import UIKit

protocol VisilabsCarouselControllerInterface: AnyObject {
    
    var allowScroll: Bool { get set }
    
    func safeScrollTo(index: Int, animated: Bool)
}

class VisilabsCarouselCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout, VisilabsCarouselControllerInterface {
    
    // MARK: - Init
    
    init(childControllers: [UIViewController]) {
        self.childControllers = childControllers
        let layout = VisilabsCarouselCollectionFlowLayout()
        layout.minimumLineSpacing = .zero
        layout.minimumInteritemSpacing = .zero
        layout.scrollDirection = .horizontal
        super.init(collectionViewLayout: layout)
        
        for controller in childControllers {
            self.addChild(controller)
            controller.didMove(toParent: self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delaysContentTouches = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.layoutMargins = .zero
        collectionView.preservesSuperviewLayoutMargins = true
        if #available(iOS 11.0, *) {
            collectionView.insetsLayoutMarginsFromSafeArea = false
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VisilabsCarouselCollectionCell.self, forCellWithReuseIdentifier: VisilabsCarouselCollectionCell.id)
    }
    
    // MARK: - Layout
    
    private var cellLayoutMargins: UIEdgeInsets { collectionView.layoutMargins }
    private var layout: VisilabsCarouselCollectionFlowLayout { collectionViewLayout as! VisilabsCarouselCollectionFlowLayout }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.visibleCells.forEach({ $0.contentView.layoutMargins = cellLayoutMargins })
        
        let newItemSize = collectionView.frame.size
        if layout.itemSize != newItemSize {
            layout.itemSize = collectionView.frame.size
            layout.invalidateLayout()
        }
    }
    
    // MARK: - VisilabsCarouselControllerInterface
    
    var allowScroll: Bool {
        get { collectionView.isScrollEnabled }
        set { collectionView.isScrollEnabled = newValue }
    }
    
    func safeScrollTo(index: Int, animated: Bool) {
        if index > (childControllers.count - 1) {
            // Don't safe index.
            return
        }
        collectionView.scrollToItem(at: .init(row: index, section: .zero), at: .centeredVertically, animated: animated)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childControllers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisilabsCarouselCollectionCell.id, for: indexPath) as! VisilabsCarouselCollectionCell
        let controller = childControllers[indexPath.row]
        cell.setViewController(controller)
        cell.contentView.layoutMargins = cellLayoutMargins
        return cell
    }
    
    // MARK: - Internal
    
    /**
     VisilabsCarouselController: All controllers, which show in pages.
     */
    private var childControllers: [UIViewController]
}
