//
//  TikTokScrollView+Utils.swift
//  TikTokClone
//
//  Created by Mohammed Elamin on 27/09/2024.
//

import Foundation
import SwiftUI
import AVKit
import AVFoundation
import MediaPlayer

extension TikTokScrollView {
//     func playVideo(at index: Int) {
//        print(index)
//         queuePlayer.replaceCurrentItem(with: AVPlayerItem(url: videoURLs[index]))
//         queuePlayer.seek(to: .zero)
//         queuePlayer.play()
//    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up AVAudioSession: \(error)")
        }
    }
    
    func setupNowPlayingInfo(title: String, duration: Double) {
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = queuePlayer.currentTime().seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = queuePlayer.rate // 1.0 for playing, 0.0 for paused
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func updateNowPlayingInfo(isPlaying: Bool) {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = queuePlayer.currentTime().seconds
        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func withEaseOutAnimation(body: @escaping () -> Void) {
        withAnimation(.easeOut(duration: 1)) {
             body()
         }
    }
    
    func setupRemoteCommandCenter() {
//        let commandCenter = MPRemoteCommandCenter.shared()
//
//        // Play command
//        commandCenter.playCommand.isEnabled = true
//        commandCenter.playCommand.addTarget { event in
//            if !self.isPlaying {
//                self.player.play()
//                self.isPlaying = true
//                self.updateNowPlayingInfo(isPlaying: true)
//                return .success
//            }
//            return .commandFailed
//        }
//
//        // Pause command
//        commandCenter.pauseCommand.isEnabled = true
//        commandCenter.pauseCommand.addTarget { event in
//            if self.isPlaying {
//                self.player.pause()
//                self.isPlaying = false
//                self.updateNowPlayingInfo(isPlaying: false)
//                return .success
//            }
//            return .commandFailed
//        }
//
//        // Stop command (if needed)
//        commandCenter.stopCommand.isEnabled = true
//        commandCenter.stopCommand.addTarget { event in
//            self.player.pause()
//            self.isPlaying = false
//            self.updateNowPlayingInfo(isPlaying: false)
//            return .success
//        }
    }
    
    // Method to load video from cache or download if not cached
     func loadAndPlayVideo(at index: Int) {
        let videoURL = videoURLs[index]
//        VideoCacheManager.shared.cachedVideoURL(for: videoURL) { cachedURL in
//            guard let cachedURL = cachedURL else { return }
//            print(cachedURL)
         
         let playerItem = VideoAssetPreloader.shared.getPreloadedPlayerItem(for: videoURL)

            queuePlayer.replaceCurrentItem(with: playerItem)
            queuePlayer.seek(to: .zero)
            queuePlayer.volume = 1.0  // Ensure the player volume is set correctly
            queuePlayer.isMuted = false // Ensure audio is not muted
            queuePlayer.play()
            isPlaying = true
            if let duration = queuePlayer.currentItem?.asset.duration {
                self.duration = duration
                self.setupNowPlayingInfo(title: "Video Title", duration: duration.seconds)
            }
//        }
    }
     func togglePlayPause() {
//         queuePlayer.pause()

//         return
         print(isPlaying)
        if isPlaying {
            queuePlayer.pause()
        } else {
            queuePlayer.play()
        }
//         isPlaying = false
         
         withEaseOutAnimation {
             isPlaying.toggle()
         } // Toggle the isPlaying state
    }
    
     func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
         queuePlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            guard let currentItem = self.queuePlayer.currentItem else { return }
            self.currentTime = time
            print(currentTime)
            let innerDuration = currentItem.duration.seconds
            if innerDuration.isFinite {
                self.videoProgress = time.seconds / innerDuration
            }
        }
    }
    
    func setupQueuePlayer() {
        queuePlayer.automaticallyWaitsToMinimizeStalling = true

            // Clear existing items in queue
            queuePlayer.removeAllItems()
            
            // Add the first video to the queue
            let currentVideoItem = AVPlayerItem(url: videoURLs[currentPage])
            queuePlayer.insert(currentVideoItem, after: nil)
            
            // Preload the next video
            preloadNextVideo()
            
            queuePlayer.play()
            queuePlayer.seek(to: .zero)
            queuePlayer.volume = 1.0  // Ensure the player volume is set correctly
            queuePlayer.isMuted = false // Ensure audio is not muted
            queuePlayer.play()
            isPlaying = true
            if let duration = queuePlayer.currentItem?.asset.duration {
                self.duration = duration
                self.setupNowPlayingInfo(title: "Video Title", duration: duration.seconds)
            }
        }
    
    // Preload the next video in the queue
    func preloadNextVideo() {
        if currentPage < videoURLs.count - 1 {
            let nextVideoItem = AVPlayerItem(url: videoURLs[currentPage + 1])
            queuePlayer.insert(nextVideoItem, after: nil) // Preload next video
        }
    }

    // Preload the previous video in the queue
    func preloadPreviousVideo() {
        if currentPage > 0 {
            let previousVideoItem = AVPlayerItem(url: videoURLs[currentPage - 1])
            queuePlayer.insert(previousVideoItem, after: nil) // Preload previous video
        }
    }

    // Handle video change when swiping up or down
    func handleVideoChange(oldIndex: Int,newIndex: Int) {
        // Check if we are swiping to the next video
        if newIndex > oldIndex {
            // Move forward to the next video
            queuePlayer.advanceToNextItem() // Automatically switches to the next item
            withAnimation {
                isPlaying = true
            }
            if let duration = queuePlayer.currentItem?.asset.duration {
                self.duration = duration
            }
            
        } else if newIndex < oldIndex {
            // Move backward to the previous video
            setupQueuePlayer() // Re-setup the queue for the previous video
        }

        // Preload the adjacent videos again
        preloadPreviousVideo()
        preloadNextVideo()
    }
    
    func stopIfPlaying(){
        if isPlaying {
            queuePlayer.pause()
        }
    }
    
    func seek(with progress: Double) {
        stopIfPlaying()
        let time = CMTime(seconds: progress * duration.seconds, preferredTimescale: 600)
        queuePlayer.seek(to: time)
     
      }
    

}
