//
//  ContentView.swift
//  TikTokClone
//
//  Created by Mohammed Elamin on 27/09/2024.
//

import SwiftUI
import AVKit
import Combine

struct VideoPlayerView: View {
    var player = AVPlayer()
    
    init(player: AVPlayer = AVPlayer()) {
        self.player = player
    }
    
    var body: some View {
        ZStack {
            CustomVideoPlayer(player: player, videoGravity: .resize)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
            
        }
    }
}

struct TikTokScrollView: View {
    let videoURLs: [URL]
    @State  var currentPage: Int
    
    @State private var previousPage = 0
    
    
//    @State  var player = AVPlayer() // Single AVPlayer for all videos
    
    @State  var isPlaying = true // State to track if video is playing
    
    @State  var videoProgress: Double = 0.0 // State to track video progress
    
    @State  var currentTime: CMTime = .zero
    // To track current time
    @State  var duration: CMTime = .zero  
    
    // To track total duration
    
    @State private var currentVideoIndex = 0
    @State  var queuePlayer = AVQueuePlayer()
    @State private var playerLooper: AVPlayerLooper? = nil

    @State private var shouldShowMetaData = true
    

    
    init(videoURLs: [URL], currentPage: Int = 0) {
        self.videoURLs = videoURLs
        self.currentPage = currentPage
    }
    

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .topTrailing){
                VerticalPager(
                    pageCount: videoURLs.count,
                    currentIndex: $currentPage,
                    pageChanged: { oldIndex, newIndex in
//                        handleVideoChange(oldIndex: oldIndex, newIndex: newIndex)
                        loadAndPlayVideo(at: newIndex)
                        withEaseOutAnimation {
                            shouldShowMetaData = true
                        }
                        WorkItemManager.shared.startWork {
                            withEaseOutAnimation {
                                shouldShowMetaData = false
                            }
                        }

                    },
                    onPageChanging: {
                        WorkItemManager.shared.cancelWork()
                        withEaseOutAnimation {
                            shouldShowMetaData = false

                        }

                    }
                ) {
                    ForEach(0..<videoURLs.count, id: \.self) { index in
                        ZStack(alignment: .center) {
                            VideoPlayerView(player: queuePlayer)
                                .onTapGesture {
                                    togglePlayPause()
                                }
                            if !isPlaying {
                                Image("play")
                                    .frame(width: 100, height: 100)
                                    .background(.black.opacity(0.7))
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        togglePlayPause()
                                    }
                            }
                        }
                    }
                }
                .onAppear {
                    configureAudioSession()
//                    setupRemoteCommandCenter()
                    loadAndPlayVideo(at: currentPage)
//                    setupQueuePlayer()
                    addPeriodicTimeObserver()
                    VideoAssetPreloader.shared.preloadVideos(from: videoURLs)
                }.ignoresSafeArea(.all)
                
                // X Button in the top-right corner
                        Button(action: {
                            // Dismiss the view when X button is tapped
//                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding()
                        }
               
            }
            VideoMetaDataView(
                isPlaying: isPlaying,
                shouldShowMetaData: shouldShowMetaData,
                currentTime: currentTime,
                duration: duration,
                videoProgress: videoProgress,
                onDragging: { progress in
                    seek(with: progress)
                },
                onDraggingEnd: {
                    queuePlayer.play()
                    withEaseOutAnimation {
                        isPlaying = true
                    }
                }
            ).onAppear {
                WorkItemManager.shared.startWork {
                    withEaseOutAnimation {
                        shouldShowMetaData = false
                    }
                }
//                addPeriodicTimeObserver()
//                setupQueuePlayer()
            }
        }
        .ignoresSafeArea(.all)
    
    }
    
    private func checkForPageChange() {
        if currentPage != previousPage {
            previousPage = currentPage
            loadAndPlayVideo(at: currentPage)
        }
    }
    
}

struct ContentView: View {
    let videoURLs: [URL] = [
        URL(string: "https://cmspt.emiratesnbd.com/-/media/enbd/uae/video/mobile-video/theme1_en_mq.mp4")!,
        URL(string: "https://cmspt.emiratesnbd.com/-/media/enbd/uae/video/mobile-video/theme2_en_mq.mp4")!,
        URL(string: "https://cmspt.emiratesnbd.com/-/media/enbd/uae/video/mobile-video/theme3_en_mq.mp4")!,
        URL(string: "https://cmspt.emiratesnbd.com/-/media/enbd/uae/video/mobile-video/theme4_en_mq.mp4")!,
        URL(string: "https://cmspt.emiratesnbd.com/-/media/enbd/uae/video/mobile-video/theme5_en_mq.mp4")!,
    ]
    
    var body: some View {
        TikTokScrollView(videoURLs: videoURLs,currentPage: 0)
    }
}



#Preview {
    ContentView()
        .background(.black)
}



import Foundation

class WorkItemManager {
    static let shared = WorkItemManager()
    private init() {
    }
    private var workItem: DispatchWorkItem?

    // Function to start the work item
    func startWork(onHideMetaDataView: @escaping () -> Void) {
        // Create the work item
        workItem = DispatchWorkItem {
            onHideMetaDataView()
        }

        // Execute the work item on a background queue
        if let workItem = workItem {
            DispatchQueue.global().asyncAfter(deadline: .now()+5,execute: workItem)
        }
    }

    // Function to cancel the work item
    func cancelWork() {
        workItem?.cancel()
        print("Work cancelled.")
    }
}



class VideoAssetPreloader {
    static let shared = VideoAssetPreloader()
    private init() {}
    
    private var preloadedItems: [URL: AVPlayerItem] = [:]
    
    // Preload a single video asset
    func preloadVideo(from url: URL) {
        let asset = AVAsset(url: url)
        let keys = ["playable"]
        
        asset.loadValuesAsynchronously(forKeys: keys) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            
            switch status {
            case .loaded:
                // Asset is loaded and ready to be used
                let playerItem = AVPlayerItem(asset: asset)
                self.preloadedItems[url] = playerItem
            case .failed, .cancelled:
                print("Failed to load asset: \(String(describing: error))")
            default:
                break
            }
        }
    }
    
    // Preload a list of video assets
    func preloadVideos(from urls: [URL]) {
        for url in urls {
            preloadVideo(from: url)
        }
    }
    
    // Retrieve preloaded AVPlayerItem or create a new one if not found
    func getPreloadedPlayerItem(for url: URL) -> AVPlayerItem {
        if let playerItem = preloadedItems[url] {
            return playerItem
        } else {
            // If the URL is not found in preloaded items, create a new AVPlayerItem
            let newPlayerItem = AVPlayerItem(url: url)
            preloadedItems[url] = newPlayerItem  // Optionally cache this new item
            return newPlayerItem
        }
    }
}

// Usage Example
let videoURL1 = URL(string: "https://path_to_your_video1.mp4")!
let videoURL2 = URL(string: "https://path_to_your_video2.mp4")!
let videoURL3 = URL(string: "https://path_to_your_video3.mp4")!

// Preload multiple videos
//VideoAssetPreloader.shared.preloadVideos(from: [videoURL1, videoURL2, videoURL3])
//
//// Retrieve and use the preloaded player item
//let playerItem = VideoAssetPreloader.shared.getPreloadedPlayerItem(for: videoURL1)
//let queuePlayer = AVQueuePlayer()
//queuePlayer.replaceCurrentItem(with: playerItem)
//queuePlayer.play()
