//
//  VideoMetaDataView.swift
//  TikTokClone
//
//  Created by Mohammed Elamin on 27/09/2024.
//

import SwiftUI
import AVFoundation

struct VideoMetaDataView: View {
    var isPlaying: Bool
    var currentTime: CMTime = .zero
    var duration: CMTime = .zero
    var videoProgress: Double = 0.0 // State to track video progress
    
    
    var body: some View {
        if !isPlaying {
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.black.opacity(0.02)]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 160) // Adjust height of the gradient to your preference
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Introduction to financial markets ")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.white)
                        Spacer()
                    }.padding(.vertical,1)
                    Text("To achieve a gradient effect from black to transparent at the bottom part of your UI, you can use SwiftUI’s LinearGradient.")
                        .font(.caption2)
                        .foregroundColor(.white)
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(formattedTime(currentTime)) / \(formattedTime(duration))")
                                .font(.caption2)
                                .foregroundColor(.white)
                            
                        }
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geometry.size.width, height: 8)
                                    .foregroundColor(.gray.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Rectangle()
                                    .frame(width: CGFloat(self.videoProgress) * geometry.size.width, height: 4)
                                    .foregroundColor(.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .frame(height: 4)
                        .padding(.bottom, 10)
                    }.padding(.vertical,4)
                    
                    Spacer()
                    
                }
                .padding()
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: 160)
            }.ignoresSafeArea(.all)
        }
    }
}

extension VideoMetaDataView {
    // Format CMTime to "mm:ss" string
    func formattedTime(_ time: CMTime) -> String {
        let totalSeconds = Int(CMTimeGetSeconds(time))
        
        guard totalSeconds > 60 else {
            return "00:\(totalSeconds)"
        }
        
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VideoMetaDataView(isPlaying: false)
}
