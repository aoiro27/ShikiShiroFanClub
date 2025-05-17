import SwiftUI
import AVFoundation

struct AnimalSoundGame: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var bgmPlayer: AVAudioPlayer?
    @Environment(\.dismiss) private var dismiss
    
    let animals = [
        ("きつね", "きつね", "きつね"),
        ("いぬ", "いぬ", "いぬ"),
        ("ねこ", "ねこ", "ねこ"),
        ("ぶた", "pig", "ぶた"),
        ("こあら", "こあら", "こあら"),
        ("ぱんだ", "ぱんだ", "ぱんだ"),
        ("？？？", "しきちゃん", "しきちゃん"),
        ("ぞう", "ぞう", "ぞう"),
        ("ねずみ", "ねずみ", "ねずみ"),
        ("さる", "さる", "さる"),
        ("うさぎ", "うさぎ", "うさぎ"),
        ("？？？", "しろちゃん", "しろちゃん")
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            // 背景
            Image("background2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            // メインコンテンツ
            VStack(spacing: 20) {
                Text("どうぶつのなまえ")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                    .padding(.top, 20)
                    .padding(.bottom,100)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(animals, id: \.1) { animal in
                            Button(action: {
                                playSound(forResource: animal.2, withExtension: "wav")
                            }) {
                                VStack {
                                    Image(animal.1)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(15)
                                        .shadow(radius: 5)
                                    Text(animal.0)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .onAppear { setupBGM() }
        .onDisappear { bgmPlayer?.stop() }
    }
    
    private func setupBGM() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            guard let url = Bundle.main.url(forResource: "bgm1", withExtension: "mp3") else {
                print("BGMファイルが見つかりません")
                return
            }
            
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.prepareToPlay()
            bgmPlayer?.numberOfLoops = -1  // 無限ループ
            bgmPlayer?.volume = 0.3  // 音量を30%に設定
            bgmPlayer?.play()
        } catch {
            print("BGMの再生に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func playSound(forResource: String, withExtension: String) {
        guard let url = Bundle.main.url(forResource: forResource, withExtension: withExtension) else {
            print("音声ファイルが見つかりません")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
        } catch {
            print("音声の再生に失敗しました: \(error.localizedDescription)")
        }
    }
}

struct AnimalSoundGame_Previews: PreviewProvider {
    static var previews: some View {
        AnimalSoundGame()
    }
}
