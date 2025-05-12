import SwiftUI

struct ResultView: View {
    let isCorrect: Bool
    let correctAnswer: String
    let onNext: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: isCorrect ? "star.fill" : "xmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(isCorrect ? .yellow : .red)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
            
            Text(isCorrect ? "せいかい！" : "ざんねん...")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(isCorrect ? .green : .red)
            
            if !isCorrect {
                Text("こたえは「\(correctAnswer)」でした")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
            
            Text(isCorrect ? "すごいね！" : "つぎはがんばろう！")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.blue)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 10)
        )
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ResultView(
        isCorrect: true,
        correctAnswer: "きいろ",
        onNext: {}
    )
} 
