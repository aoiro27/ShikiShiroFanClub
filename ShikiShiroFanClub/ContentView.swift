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
    @State private var titleSoundPlayer: AVAudioPlayer?
    @State private var isFirstAppearance = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("home_background")
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
                        GameButton(
                            title: "どうぶつのおなまえ",
                            systemImage: "speaker.wave.2.fill",
                            onTap: {
                                playSound(forResource: "どうぶつのおなまえ", withExtension: "wav")
                            }
                        )
                        
                        GameButton(
                            title: "いろあてクイズ",
                            systemImage: "paintpalette.fill",
                            onTap: {
                                playSound(forResource: "いろあてくいず", withExtension: "wav")
                            }
                        )
                        
                        GameButton(
                            title: "すうじをかぞえよう",
                            systemImage: "number.circle.fill",
                            onTap: {
                                playSound(forResource: "すうじをかぞえよう", withExtension: "wav")
                            }
                        )
                        
                        GameButton(
                            title: "ゾンビシューティング",
                            systemImage: "target",
                            onTap: {
                                playSound(forResource: "ぞんびしゅーてぃんぐ", withExtension: "wav")
                            }
                        )
                        
                        GameButton(
                            title: "おえかきゲーム",
                            systemImage: "pencil.tip",
                            onTap: {
                                playSound(forResource: "おえかき", withExtension: "wav")
                            }
                        )
                        
                        GameButton(
                            title: "しきしろテトリス",
                            systemImage: "square.grid.3x3.fill",
                            onTap: {
                                playSound(forResource: "てとりす", withExtension: "wav")
                            }
                        )
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .onAppear {
                setupAudioSession()
                // 初回起動時以外の場合のみBGMを開始
                if !isFirstAppearance {
                    BGMPlayer.shared.playBGM()
                }
                isFirstAppearance = false
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
            titleSoundPlayer?.numberOfLoops = 0 
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
}

struct GameButton: View {
    let title: String
    let systemImage: String
    let onTap: (() -> Void)?
    @State private var isNavigating = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button(action: {
            onTap?()
            // BGMを停止
            BGMPlayer.shared.stopBGM()
            // 効果音の再生が完了するのを待ってから画面遷移
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isNavigating = true
            }
        }) {
            HStack(spacing: 20) {
                Image(systemName: systemImage)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                Text(title)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.85), Color.cyan.opacity(0.85)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
            )
            .shadow(color: Color.cyan.opacity(0.3), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            NavigationLink(
                destination: destination,
                isActive: $isNavigating,
                label: { EmptyView() }
            )
        )
        .padding(.horizontal, 8)
    }
    
    var destination: some View {
        switch title {
        case "どうぶつのおなまえ":
            return AnyView(
                AnimalSoundGame()
            )
        case "いろあてクイズ":
            return AnyView(
                ColorPuzzleGame()
            )
        case "すうじをかぞえよう":
            return AnyView(
                NumberGame()
            )
        case "ゾンビシューティング":
            return AnyView(
                ZombieShootingGame()
            )
        case "おえかきゲーム":
            return AnyView(
                PhotoDrawingGame()
            )
        case "しきしろテトリス":
            return AnyView(
                SimpleTetrisGame()
            )
        default:
            return AnyView(EmptyView())
        }
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

