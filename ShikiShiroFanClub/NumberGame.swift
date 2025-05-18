import SwiftUI
import AVFoundation

struct NumberGame: View {
    @State private var currentNumber = 1
    @State private var isAnimating = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var bgmPlayer: AVAudioPlayer?
    @Environment(\.dismiss) private var dismiss
    
    let maxNumber = 1000
    
    var body: some View {
        ZStack {
            Image("number_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("すうじをかぞえよう！")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .padding(.top, 20)
                
                Text("\(currentNumber)")
                    .font(.system(size: 160, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                    .onTapGesture {
                        speakNumber()
                    }
                
                HStack(spacing: 15) {
                    if currentNumber >= 100 {
                        ForEach(0..<(currentNumber / 100), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                                .shadow(radius: 3)
                        }
                    }
                    
                    if currentNumber >= 10 {
                        ForEach(0..<((currentNumber % 100) / 10), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.green)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                                .shadow(radius: 3)
                        }
                    }
                    
                    ForEach(0..<(currentNumber % 10), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.yellow)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                            .shadow(radius: 3)
                    }
                }
                
                HStack(spacing: 40) {
                    Button(action: {
                        if currentNumber > 1 {
                            currentNumber -= 1
                            animate()
                            speakNumber()
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .background(Color.red.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    
                    Button(action: {
                        if currentNumber < maxNumber {
                            currentNumber += 1
                            animate()
                            speakNumber()
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .background(Color.green.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(false)
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
    
    private func animate() {
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
        }
    }
    
    private func speakNumber() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            // 前の読み上げを停止
            speechSynthesizer.stopSpeaking(at: .immediate)
            
            let utterance = AVSpeechUtterance(string: "\(currentNumber)")
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            utterance.rate = 0.5  // 話す速度を少し遅く
            utterance.pitchMultiplier = 1.2  // 声の高さを少し上げる
            utterance.volume = 1.0  // 音量を最大に設定
            speechSynthesizer.speak(utterance)
        } catch {
            print("音声の再生に失敗しました: \(error.localizedDescription)")
        }
    }
}

struct NumberGame_Previews: PreviewProvider {
    static var previews: some View {
        NumberGame()
    }
} 
