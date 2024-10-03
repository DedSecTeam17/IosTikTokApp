//
//  VideoCacheManager.swift
//  TikTokClone
//
//  Created by Mohammed Elamin on 27/09/2024.
//

import Foundation


class VideoCacheManager {
    static let shared = VideoCacheManager()

    private var cache = URLCache(memoryCapacity: 100 * 1024 * 1024, diskCapacity: 500 * 1024 * 1024, diskPath: "videoCache")

    // Method to retrieve video data from the cache or download if not available
    func cachedVideoURL(for url: URL, completion: @escaping (URL?) -> Void) {
        let request = URLRequest(url: url)

        // Check if the video data exists in the cache
        if let cachedResponse = cache.cachedResponse(for: request) {
            let cachedURL = getLocalURL(for: url)
            do {
                try cachedResponse.data.write(to: cachedURL)
                completion(cachedURL)
            } catch {
                print("Failed to write cached data to disk: \(error)")
                completion(nil)
            }
        } else {
            // If not cached, download the video
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, let response = response else {
                    print("Failed to download video: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                    return
                }

                // Cache the downloaded video
                let cachedResponse = CachedURLResponse(response: response, data: data)
                self.cache.storeCachedResponse(cachedResponse, for: request)

                // Save video data to disk
                let localURL = self.getLocalURL(for: url)
                do {
                    try data.write(to: localURL)
                    completion(localURL)
                } catch {
                    print("Failed to save video to disk: \(error)")
                    completion(nil)
                }
            }.resume()
        }
    }

    // Method to generate a local file URL for cached video
    private func getLocalURL(for url: URL) -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cacheDirectory.appendingPathComponent(url.lastPathComponent)
    }
}
