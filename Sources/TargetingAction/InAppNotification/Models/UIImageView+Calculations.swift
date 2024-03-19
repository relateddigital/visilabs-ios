//
//  UIImageView+Calculations.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import AVFoundation
import UIKit
import WebKit

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
    
    func addYoutubeVideoPlayer(urlString: String) -> WKWebView? {
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences = preferences
        
        if #available(iOS 10.0, *) {
            webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        } else {
            webConfiguration.requiresUserActionForMediaPlayback = false
        }
        
        webConfiguration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)

        if let videoID = urlString.extractYouTubeVideoID() {
            let embedHTML = """
                <style>
                    .iframe-container iframe {
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                    }
                </style>
                <div class="iframe-container">
                    <div id="player"></div>
                </div>
                <script>
                    var tag = document.createElement('script');
                    tag.src = "https://www.youtube.com/iframe_api";
                    var firstScriptTag = document.getElementsByTagName('script')[0];
                    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

                    var player;
                    var isPlaying = true;
                    function onYouTubeIframeAPIReady() {
                        player = new YT.Player('player', {
                            width: '100%',
                            videoId: '\(videoID)',
                            playerVars: { 'autoplay': 1, 'playsinline': 1, 'rel': 0 },
                            events: {
                                'onReady': function(event) {
                                    
                                    event.target.playVideo();
                                }
                            }
                        });
                    }
                
                    function watchPlayingState() {
                        if (isPlaying) {
                            player.playVideo();
                        } else {
                            player.pauseVideo();
                        }
                    }
                </script>
                """

            
            self.addSubview(webView)
            webView.frame = self.frame
            webView.loadHTMLString(embedHTML, baseURL: nil)
        } else {
            webView.isHidden = true
            print("Geçerli bir YouTube URL'si değil.")
        }
        
        return webView
    }
}



extension WKWebView {
    func stopPlayer() {
        self.evaluateJavaScript("player.pauseVideo();", completionHandler: nil)
    }
}


extension String {
    func extractYouTubeVideoID() -> String? {
        let pattern = "v=([a-zA-Z0-9_-]+)"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            
            if let match = matches.first {
                let range = match.range(at: 1)
                if let swiftRange = Range(range, in: self) {
                    return String(self[swiftRange])
                }
            }
        } catch {
            print("Error creating regular expression: \(error.localizedDescription)")
        }
        
        return nil
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
