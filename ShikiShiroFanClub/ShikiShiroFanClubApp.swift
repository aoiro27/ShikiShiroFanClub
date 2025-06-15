//
//  ShikiShiroFanClubApp.swift
//  ShikiShiroFanClub
//
//  Created by aoiro on 2025/05/12.
//

import SwiftUI
import SwiftData

@main
struct ShikiShiroFanClubApp: App {
    @State private var showingOpeningVideo = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                
                if showingOpeningVideo {
                    VideoPlayerView(isShowing: $showingOpeningVideo)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        }
    }
}
