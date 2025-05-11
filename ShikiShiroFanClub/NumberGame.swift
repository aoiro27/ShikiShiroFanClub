import SwiftUI
import AVFoundation

struct NumberGame: View {
    @State private var currentNumber = 1
    @State private var isAnimating = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    let maxNumber = 5
    
    var body: some View {
        ZStack {
            Image("background2")
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
                    .font(.system(size: 120, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                    .onTapGesture {
                        speakNumber()
                    }
                
                HStack(spacing: 20) {
                    ForEach(1...currentNumber, id: \.self) { _ in
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
                            .foregroundColor(.red)
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
                            .foregroundColor(.green)
                            .shadow(radius: 5)
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }
    
    private func animate() {
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
        }
    }
    
    private func speakNumber() {
        let utterance = AVSpeechUtterance(string: "\(currentNumber)")
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.5  // 話す速度を少し遅く
        utterance.pitchMultiplier = 1.2  // 声の高さを少し上げる
        speechSynthesizer.speak(utterance)
    }
}

#Preview {
    NumberGame()
} 
