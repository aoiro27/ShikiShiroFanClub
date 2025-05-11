//
//  ContentView.swift
//  ShikiShiroFanClub
//
//  Created by aoiro on 2025/05/12.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Text("こどものともだち")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(.top, 30)
                
                Spacer()
                
                NavigationLink(destination: AnimalSoundGame()) {
                    GameButton(title: "どうぶつのなきごえ", color: .green, systemImage: "speaker.wave.2.fill")
                }
                
                NavigationLink(destination: ColorPuzzleGame()) {
                    GameButton(title: "いろあそび", color: .orange, systemImage: "paintpalette.fill")
                }
                
                NavigationLink(destination: NumberGame()) {
                    GameButton(title: "すうじあそび", color: .purple, systemImage: "star.fill")
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
}

struct GameButton: View {
    let title: String
    let color: Color
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.system(size: 30))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(color)
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
