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
     func playVideo(at index: Int) {
        print(index)
        player.replaceCurrentItem(with: AVPlayerItem(url: videoURLs[index]))
        player.seek(to: .zero)
        player.play()
    }
    
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
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate // 1.0 for playing, 0.0 for paused
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func updateNowPlayingInfo(isPlaying: Bool) {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        // Play command
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { event in
            if !self.isPlaying {
                self.player.play()
                self.isPlaying = true
                self.updateNowPlayingInfo(isPlaying: true)
                return .success
            }
            return .commandFailed
        }

        // Pause command
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { event in
            if self.isPlaying {
                self.player.pause()
                self.isPlaying = false
                self.updateNowPlayingInfo(isPlaying: false)
                return .success
            }
            return .commandFailed
        }

        // Stop command (if needed)
        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.addTarget { event in
            self.player.pause()
            self.isPlaying = false
            self.updateNowPlayingInfo(isPlaying: false)
            return .success
        }
    }
    
    // Method to load video from cache or download if not cached
     func loadAndPlayVideo(at index: Int) {
        let videoURL = videoURLs[index]
        VideoCacheManager.shared.cachedVideoURL(for: videoURL) { cachedURL in
            guard let cachedURL = cachedURL else { return }
            print(cachedURL)
            player.replaceCurrentItem(with: AVPlayerItem(url: cachedURL))
            player.seek(to: .zero)
            player.volume = 1.0  // Ensure the player volume is set correctly
            player.isMuted = false // Ensure audio is not muted
            player.play()
            isPlaying = true
            if let duration = player.currentItem?.asset.duration {
                self.duration = duration
                self.setupNowPlayingInfo(title: "Video Title", duration: duration.seconds)
            }
        }
    }
     func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
         withAnimation {
             isPlaying.toggle()
         } // Toggle the isPlaying state
    }
    
     func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            guard let currentItem = self.player.currentItem else { return }
            self.currentTime = time
            print(currentTime)
            let innerDuration = currentItem.duration.seconds
            if innerDuration.isFinite {
                self.videoProgress = time.seconds / innerDuration
            }
        }
    }
}
