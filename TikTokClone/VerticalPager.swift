//
//  VerticalPager.swift
//  TikTokClone
//
//  Created by Mohammed Elamin on 27/09/2024.
//

import Foundation
import SwiftUI

struct VerticalPager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let content: Content
    var pageChanged: (Int,Int) -> Void
    var onPageChanging: () -> Void
    
    init(
        pageCount: Int,
        currentIndex: Binding<Int>,
        pageChanged: @escaping (Int,Int) -> Void,
        onPageChanging: @escaping () -> Void,
        @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
        self.pageChanged = pageChanged
        self.onPageChanging = onPageChanging
    }
    
    @GestureState private var translation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            LazyVStack(spacing: 0) {
                self.content.frame(width: geometry.size.width, height: geometry.size.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primary.opacity(0.000000001))
            .offset(y: -CGFloat(self.currentIndex) * geometry.size.height)
            .offset(y: self.translation)
            .animation(.interactiveSpring(response: 0.4), value: currentIndex)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture(minimumDistance: 1).updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }
                    .onChanged { value in
                        print("on change =====>")
                        onPageChanging()
                    }
                    .onEnded { value in
                    let offset = -Int(value.translation.height)
                    if abs(offset) > 20 {
                        let oldIndex = currentIndex
                        let newIndex = currentIndex + min(max(offset, -1), 1)
                        if newIndex >= 0 && newIndex < pageCount {
                        
                            self.currentIndex = newIndex
                        
                            DispatchQueue.global(qos: .userInitiated).async {
                                self.pageChanged(oldIndex, newIndex)
                            }
//                            self.pageChanged(oldIndex,newIndex)
                        }
                    }
                }
            )
        }
    }
}

