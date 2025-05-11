//
//  ContentView.swift
//  ShikiShiroFanClub
//
//  Created by aoiro on 2025/05/12.
//

import SwiftUI
import SwiftData
import AVFoundation

struct ContentView: View {
    @State private var selectedGame: GameType?
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            if let game = selectedGame {
                switch game {
                case .animalSound:
                    AnimalSoundGame(selectedGame: $selectedGame)
                case .colorPuzzle:
                    ColorPuzzleGame(selectedGame: $selectedGame)
                case .number:
                    NumberGame(selectedGame: $selectedGame)
                }
            } else {
                VStack(spacing: 30) {
                    Text("しきしろファンクラブ")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                    
                    Text("ゲームをえらんでね！")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                    
                    VStack(spacing: 20) {
                        GameButton(title: "どうぶつのなきごえ", systemImage: "speaker.wave.2.fill") {
                            selectedGame = .animalSound
                        }
                        
                        GameButton(title: "いろあてクイズ", systemImage: "paintpalette.fill") {
                            selectedGame = .colorPuzzle
                        }
                        
                        GameButton(title: "すうじをかぞえよう", systemImage: "number.circle.fill") {
                            selectedGame = .number
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
        }
        .onAppear {
            setupAudio()
        }
        .onChange(of: selectedGame) { newValue in
            if newValue != nil {
                audioPlayer?.stop()
            } else {
                audioPlayer?.play()
            }
        }
    }
    
    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: "opening", withExtension: "mp3") else {
            print("BGMファイルが見つかりません")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1  // 無限ループ
            audioPlayer?.volume = 0.5  // 音量を50%に設定
            audioPlayer?.play()
        } catch {
            print("BGMの再生に失敗しました: \(error.localizedDescription)")
        }
    }
}

struct GameButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.8))
            .cornerRadius(15)
            .shadow(radius: 5)
        }
    }
}

enum GameType {
    case animalSound
    case colorPuzzle
    case number
}

#Preview {
    ContentView()
}
