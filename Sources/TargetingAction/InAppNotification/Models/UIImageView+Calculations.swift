//
//  UIImageView+Calculations.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import AVFoundation
import UIKit

extension UIImageView {
    func pv_heightForImageView(isVideoExist: Bool) -> CGFloat {
        let root = rootSuperView()
        if isVideoExist {
            return root.height / 3
        }
        guard let image = image, image.size.height > 0 else {
            return 0.0
        }
        let width = bounds.size.width
        let ratio = image.size.height / image.size.width
        return width * ratio
    }

    func addVideoPlayer(urlString: String) -> AVPlayer? {
        var player: AVPlayer!
        var avPlayerLayer: AVPlayerLayer!

        if let url = URL(string: urlString) {
            player = AVPlayer(url: url)
            avPlayerLayer = AVPlayerLayer(player: player)
            // avPlayerLayer.videoGravity = AVLayerVideoGravity.resize
            layer.addSublayer(avPlayerLayer)
            avPlayerLayer.frame = layer.bounds
            player.play()
        }
        return player
    }
}

extension UIView {
    func rootSuperView() -> UIView {
        var view = self
        while let s = view.superview {
            view = s
        }
        return view
    }
}
