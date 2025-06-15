import SwiftUI
import AVKit
import AVFoundation

class BGMPlayer {
    static let shared = BGMPlayer()
    private var player: AVAudioPlayer?
    private var titleSoundPlayer: AVAudioPlayer?
    
    private init() {}
    
    func playBGM() {
        guard let bgmURL = Bundle.main.url(forResource: "opening", withExtension: "mp3") else {
            print("BGMファイルが見つかりません")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: bgmURL)
            player?.prepareToPlay()
            player?.numberOfLoops = -1  // 無限ループ
            player?.volume = 0.5  // 音量を50%に設定
            player?.play()
        } catch {
            print("BGMの再生に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func stopBGM() {
        player?.stop()
        player = nil
    }
    
    func playTitleSound() {
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

struct VideoPlayerView: View {
    @State private var player: AVPlayer?
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            }
        }
        .onAppear {
            if let videoURL = Bundle.main.url(forResource: "opening", withExtension: "mp4") {
                player = AVPlayer(url: videoURL)
                player?.actionAtItemEnd = .pause
                
                // 動画終了時の処理
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                     object: player?.currentItem,
                                                     queue: .main) { _ in
                    // タイトル音声を再生
                    BGMPlayer.shared.playTitleSound()
                    // BGMを開始
                    BGMPlayer.shared.playBGM()
                    // 動画を非表示
                    isShowing = false
                }
            }
        }
    }
} 
