import SwiftUI

struct ColorPuzzleGame: View {
    @State private var currentQuestion = 0
    @State private var showingResult = false
    @State private var showingComplete = false
    @State private var isCorrect = false
    @State private var isAnimating = false
    @State private var score = 0
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
                    .foregroundColor(.primary)
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
                                    .foregroundColor(.white)
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
        .animation(.spring(), value: showingResult)
        .animation(.spring(), value: showingComplete)
    }
    
    private func checkAnswer(selectedColor: String) {
        isCorrect = selectedColor == questions[currentQuestion].answer
        if isCorrect {
            score += 1
        }
        showingResult = true
        isAnimating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
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

#Preview {
    ColorPuzzleGame(selectedGame: .constant(nil))
} 