import SwiftUI
import AVFoundation

struct AnimalSoundGame: View {
    @State private var currentAnimal = 0
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var bgmPlayer: AVAudioPlayer?
    @Binding var selectedGame: GameType?
    
    let animals = [
        ("いぬ", "dog"),
        ("ねこ", "cat"),
        ("うし", "cow"),
        ("ぶた", "pig"),
        ("ひつじ", "sheep")
    ]
    
    var body: some View {
        ZStack {
            Image("background2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                HStack {
                    Button(action: {
                        selectedGame = nil
                    }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                Text("どうぶつのなきごえ")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                
                Image(animals[currentAnimal].1)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .shadow(radius: 10)
                
                Text(animals[currentAnimal].0)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                
                HStack(spacing: 40) {
                    Button(action: {
                        if currentAnimal > 0 {
                            currentAnimal -= 1
                        }
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .background(Color.blue.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    
                    Button(action: {
                        playSound()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                            .background(Color.green.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    
                    Button(action: {
                        if currentAnimal < animals.count - 1 {
                            currentAnimal += 1
                        }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .background(Color.blue.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .onAppear {
            setupBGM()
        }
        .onDisappear {
            bgmPlayer?.stop()
        }
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
    
    private func playSound() {
        if isPlaying {
            audioPlayer?.stop()
            isPlaying = false
            return
        }
        
        guard let url = Bundle.main.url(forResource: animals[currentAnimal].1, withExtension: "mp3") else {
            print("音声ファイルが見つかりません")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = nil
            audioPlayer?.play()
            isPlaying = true
            
            // 音声再生が終了したら再生状態をリセット
            DispatchQueue.main.asyncAfter(deadline: .now() + audioPlayer!.duration) {
                isPlaying = false
            }
        } catch {
            print("音声の再生に失敗しました: \(error.localizedDescription)")
        }
    }
}

struct AnimalSoundGame_Previews: PreviewProvider {
    static var previews: some View {
        AnimalSoundGame(selectedGame: .constant(nil))
    }
}
