import SwiftUI
import AVFoundation

struct ColorPuzzleGame: View {
    @State private var currentQuestion = 0
    @State private var showingResult = false
    @State private var showingComplete = false
    @State private var isCorrect = false
    @State private var isAnimating = false
    @State private var score = 0
    @State private var renzoku = 0
    @State private var bgmPlayer: AVAudioPlayer?
    @State private var correctSoundPlayer: AVAudioPlayer?
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedGame: GameType?
    
    let questions = [
        (question: "きいろをえらんでね", answer: "きいろ"),
        (question: "あかをえらんでね", answer: "あか"),
        (question: "あおをえらんでね", answer: "あお"),
        (question: "みどりをえらんでね", answer: "みどり"),
        (question: "むらさきをえらんでね", answer: "むらさき")
    ]
    
    let colors: [(name: String, color: Color)] = [
        ("あか", .red),
        ("あお", .blue),
        ("きいろ", .yellow),
        ("みどり", .green),
        ("むらさき", .purple)
    ]
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
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
                
                Text("いろクイズ")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .shadow(radius: 2)
                
                Text("せいかい: \(score)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                
                Text(questions[currentQuestion].question)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(radius: 5)
                    )
                    .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                    ForEach(colors, id: \.name) { colorInfo in
                        Button(action: {
                            checkAnswer(selectedColor: colorInfo.name)
                        }) {
                            VStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(colorInfo.color)
                                    .frame(width: 100, height: 100)
                                    .shadow(radius: 3)
                                    .scaleEffect(isAnimating && colorInfo.name == questions[currentQuestion].answer ? 1.1 : 1.0)
                                
                                Text(colorInfo.name)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
                .padding()
            }
            .padding()
            
            if showingResult {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                ResultView(
                    isCorrect: isCorrect,
                    correctAnswer: questions[currentQuestion].answer,
                    onNext: moveToNextQuestion
                )
                .transition(.scale)
            }
            
            if showingComplete {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                GameCompleteView(
                    score: score,
                    totalQuestions: questions.count,
                    onRestart: restartGame,
                    onFinish: { selectedGame = nil }
                )
                .transition(.scale)
            }
        }
        .onAppear {
            setupBGM()
        }
        .onDisappear {
            bgmPlayer?.stop()
        }
        .animation(.spring(), value: showingResult)
        .animation(.spring(), value: showingComplete)
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
    
    private func checkAnswer(selectedColor: String) {
        isCorrect = selectedColor == questions[currentQuestion].answer
        if isCorrect {
            score += 1
            renzoku += 1
            playSound(forResource: "seikai", withExtension: "wav")
            switch renzoku {
            case 2:
                playSound(forResource: "2問連続", withExtension: "wav")
            case 3:
                playSound(forResource: "3問連続", withExtension: "wav")
            case 4:
                playSound(forResource: "4問連続", withExtension: "wav")
            case 5:
                playSound(forResource: "5問連続", withExtension: "wav")
            default: print(renzoku)
            }
        }else {
            playSound(forResource: "hazure", withExtension: "wav")
            renzoku = 0
        }
        showingResult = true
        isAnimating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
        }
        
        // 1.5秒後に次の問題に進む
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            moveToNextQuestion()
        }
    }
    
    private func playSound(forResource: String, withExtension: String) {
        guard let url = Bundle.main.url(forResource: forResource, withExtension: withExtension) else {
            print("効果音ファイルが見つかりません")
            return
        }
        
        do {
            correctSoundPlayer = try AVAudioPlayer(contentsOf: url)
            correctSoundPlayer?.volume = 1.0
            correctSoundPlayer?.play()
        } catch {
            print("効果音の再生に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func moveToNextQuestion() {
        withAnimation {
            showingResult = false
        }
        
        if currentQuestion < questions.count - 1 {
            currentQuestion += 1
        } else {
            showingComplete = true
        }
    }
    
    private func restartGame() {
        withAnimation {
            showingComplete = false
            currentQuestion = 0
            score = 0
        }
    }
}

struct ColorPuzzleGame_Previews: PreviewProvider {
    static var previews: some View {
        ColorPuzzleGame(selectedGame: .constant(nil))
    }
} 
