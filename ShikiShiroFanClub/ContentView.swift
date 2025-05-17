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
    @State private var audioPlayer: AVAudioPlayer?
    @State private var titleSoundPlayer: AVAudioPlayer?
    @State private var hasPlayedTitleSound = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
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
                        NavigationLink(destination: AnimalSoundGame()) {
                            GameButton(title: "どうぶつのなきごえ", systemImage: "speaker.wave.2.fill")
                        }
                        
                        NavigationLink(destination: ColorPuzzleGame()) {
                            GameButton(title: "いろあてクイズ", systemImage: "paintpalette.fill")
                        }
                        
                        NavigationLink(destination: NumberGame()) {
                            GameButton(title: "すうじをかぞえよう", systemImage: "number.circle.fill")
                        }
                        
                        NavigationLink(destination: ZombieShootingGame()) {
                            GameButton(title: "ゾンビシューティング", systemImage: "target")
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .onAppear {
                setupAudioSession()
                setupAudio()
                if !hasPlayedTitleSound {
                    playTitleSound()
                    hasPlayedTitleSound = true
                }
            }
        }
    }
    
    private func playSound(forResource: String, withExtension: String) {
        guard let url = Bundle.main.url(forResource: forResource, withExtension: withExtension) else {
            print("音声ファイルが見つかりません")
            return
        }
        
        do {
            titleSoundPlayer = try AVAudioPlayer(contentsOf: url)
            titleSoundPlayer?.volume = 1.0
            titleSoundPlayer?.play()
        } catch {
            print("音声の再生に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("オーディオセッションの設定に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: "opening", withExtension: "mp3") else {
            print("BGMファイルが見つかりません")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1  // 無限ループ
            audioPlayer?.volume = 0.5  // 音量を50%に設定
            audioPlayer?.play()
        } catch {
            print("BGMの再生に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func playTitleSound() {
        guard let url = Bundle.main.url(forResource: "title", withExtension: "wav") else {
            print("タイトル音声ファイルが見つかりません")
            return
        }
        
        do {
            titleSoundPlayer = try AVAudioPlayer(contentsOf: url)
            titleSoundPlayer?.volume = 1.0
            titleSoundPlayer?.play()
        } catch {
            print("タイトル音声の再生に失敗しました: \(error.localizedDescription)")
        }
    }
}

struct GameButton: View {
    let title: String
    let systemImage: String
    
    var body: some View {
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

enum GameType {
    case animalSound
    case colorPuzzle
    case number
    case zombieShooting
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

