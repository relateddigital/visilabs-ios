//
//  BannerView.swift
//  CleanyModal
//
//  Created by Orhun Akmil on 1.05.2022.
//

import UIKit

public class BannerView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var currentPageView: UIView!
    @IBOutlet weak var currentPageLabel: UILabel!
    @IBOutlet weak var pageControlView: UIPageControl!
    @IBOutlet weak var pageControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!

    var bannerViewModel: BannerViewModel?
    var timer = Timer()
    var currentPage = 1
    var model: AppBannerResponseModel!
    var viewDidLoad = true
    public var delegate:BannerDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func layoutSubviews() {
        DispatchQueue.main.async { [self] in

            if self.viewDidLoad {

                viewDidLoad = false
                bannerViewModel = BannerViewModel()
                bannerViewModel?.pageCount = model.app_banners.count
                if model.transition == "swipe" {
                    bannerViewModel?.passAction = .swipe
                } else {
                    bannerViewModel?.passAction = .slide
                }
                bannerViewModel?.appBanners = model.app_banners

                self.currentPageLabel.text = "\(1)/\(bannerViewModel?.pageCount ?? 10)"
                self.currentPageView.layer.cornerRadius = 15
                self.currentPageView.backgroundColor = UIColor.black.withAlphaComponent(0.65)
                configureCollectionViewLayout()

                if bannerViewModel?.passAction == .slide {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.startTimer()
                    }
                }
            }
        }
    }

    func configureCollectionViewLayout() {
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "bannerCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        self.collectionView.isPagingEnabled = true
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: self.frame.width, height: self.frame.height - (self.pageControlHeightConstraint.constant ))
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = layout

        if bannerViewModel?.pageControlHidden == true {
            self.pageControlView.isHidden = true
            self.pageControlHeightConstraint.constant = 0.0
        }
        self.pageControlView.numberOfPages = bannerViewModel?.pageCount ?? 0
    }

    @objc func scrollToNextCell() {

        let collectionView = self.collectionView
        let cellSize = CGSize(width: self.frame.width, height: self.frame.height - (self.pageControlHeightConstraint.constant ))

        if currentPage == bannerViewModel?.pageCount ?? 10 + 1 {
            collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: cellSize.width, height: cellSize.height), animated: true)
            currentPage = 1
            self.pageControlView.currentPage = 0
            self.currentPageLabel.text = "\(currentPage)/\(bannerViewModel?.pageCount ?? 10)"
        } else {
            let contentOffset = collectionView?.contentOffset
            collectionView?.scrollRectToVisible(CGRect(x: contentOffset!.x + cellSize.width, y: contentOffset!.y, width: cellSize.width, height: cellSize.height), animated: true)
            self.currentPageLabel.text = "\(currentPage+1)/\(bannerViewModel?.pageCount ?? 10)"
            self.pageControlView.currentPage = currentPage
            currentPage += 1
        }

    }

    func startTimer() {
        self.collectionView.isScrollEnabled = false
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(scrollToNextCell), userInfo: nil, repeats: true)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerViewModel?.pageCount ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bannerCell", for: indexPath)
        cell.contentMode = .center
        cell.backgroundColor = .clear
        let cellTemp: BannerCollectionViewCell = UIView.fromNib()
        cellTemp.imageView.setImage(withUrl: bannerViewModel?.appBanners[indexPath.row].img ?? "")
        cell.addSubview(cellTemp)
        cellTemp.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([cellTemp.topAnchor.constraint(equalTo: cell.topAnchor, constant: 0),
                                     cellTemp.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 0),
                                     cellTemp.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -1),
                                     cellTemp.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: 0)])

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.width, height: self.height - (self.pageControlHeightConstraint.constant ))
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControlView.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        self.currentPageLabel.text = "\(Int(scrollView.contentOffset.x) / Int(scrollView.frame.width) + 1)/\(bannerViewModel?.pageCount ?? 10)"
    }

    @objc func tap(sender: UITapGestureRecognizer) {

        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            let selectedUrl = bannerViewModel?.appBanners[indexPath.row].ios_lnk
            if let url = URL(string: selectedUrl ?? "") {
                UIApplication.shared.open(url)
            }
            delegate?.bannerItemClickListener(url: selectedUrl ?? "")

            print("you can do something with the cell or index path here")
        } else {
            print("collection view was tapped")
        }
    }

}

struct BannerViewModel {
    var pageControlHidden = false
    var pageCount = 5
    var passAction: PassAction? = .slide
    var appBanners = [AppBannerModel]()

}

enum PassAction {
    case swipe
    case slide
}


public protocol BannerDelegate {
    func bannerItemClickListener(url:String)
}
