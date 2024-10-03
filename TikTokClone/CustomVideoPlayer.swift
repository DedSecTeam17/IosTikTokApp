//
//  CustomVideoPlayer.swift
//  TikTokClone
//
//  Created by Mohammed Elamin on 27/09/2024.
//

import Foundation
import UIKit
import AVKit
import SwiftUI

struct CustomVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    let videoGravity: AVLayerVideoGravity
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false // Hide controls for TikTok-like UI
        controller.videoGravity = videoGravity   // Set the videoGravity for scaling
        controller.allowsPictureInPicturePlayback = true  
        controller.canStartPictureInPictureAutomaticallyFromInline = true // Auto start PiP
// Enable PiP
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Update the player in case it changes
        uiViewController.player = player
        uiViewController.videoGravity = videoGravity
    }
}
