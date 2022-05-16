//
//  VisilabsVideoCacheManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.10.2020.
//

import Foundation

class VisilabsVideoCacheManager {

    enum VideoError: Error, CustomStringConvertible {
        case downloadError
        case fileRetrieveError
        var description: String {
            switch self {
            case .downloadError:
                return "Can't download video"
            case .fileRetrieveError:
                return "File not found"
            }
        }
    }

    static let shared = VisilabsVideoCacheManager()
    private init() {}
    typealias Response = Result<URL, Error>

    private let fileManager = FileManager.default
    private lazy var mainDirectoryUrl: URL? = {
        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        return documentsUrl
    }()

    func getFile(for stringUrl: String, completionHandler: @escaping (Response) -> Void) {

        guard let file = directoryFor(stringUrl: stringUrl) else {
            completionHandler(Result.failure(VideoError.fileRetrieveError))
            return
        }

        // return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: file.path) else {
            completionHandler(Result.success(file))
            return
        }

        DispatchQueue.global().async {
            if let videoData = NSData(contentsOf: URL(string: stringUrl)!) {
                videoData.write(to: file, atomically: true)

                DispatchQueue.main.async {
                    completionHandler(Result.success(file))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(Result.failure(VideoError.downloadError))
                }
            }
        }
    }

    private func directoryFor(stringUrl: String) -> URL? {
        guard let fileURL = URL(string: stringUrl)?.lastPathComponent,
              let mainDirURL = self.mainDirectoryUrl else {
            return nil
        }
        let file = mainDirURL.appendingPathComponent(fileURL)
        return file
    }
}
