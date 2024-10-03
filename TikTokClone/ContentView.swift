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
    
    
    @State  var player = AVPlayer() // Single AVPlayer for all videos
    
    @State  var isPlaying = true // State to track if video is playing
    
    @State  var videoProgress: Double = 0.0 // State to track video progress
    
    @State  var currentTime: CMTime = .zero
    // To track current time
    @State  var duration: CMTime = .zero    // To track total duration
    
    init(videoURLs: [URL], currentPage: Int = 0) {
        self.videoURLs = videoURLs
        self.currentPage = currentPage
        self.player = player
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VerticalPager(
                pageCount: videoURLs.count,
                currentIndex: $currentPage,
                pageChanged: {
                    loadAndPlayVideo(at: currentPage)
                }
            ) {
                ForEach(0..<videoURLs.count, id: \.self) { index in
                    ZStack(alignment: .center) {
                        VideoPlayerView(player: player)
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
                setupRemoteCommandCenter()
                loadAndPlayVideo(at: currentPage)
            }.ignoresSafeArea(.all)
            VideoMetaDataView(
                isPlaying: isPlaying,
                currentTime: currentTime,
                duration: duration,
                videoProgress: videoProgress
            ).onAppear {
                addPeriodicTimeObserver()
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
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!,
    ]
    
    var body: some View {
        TikTokScrollView(videoURLs: videoURLs,currentPage: 0)
    }
}


#Preview {
    ContentView()
        .background(.black)
}



