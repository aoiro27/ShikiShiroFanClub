import SwiftUI

struct NumberGame: View {
    @State private var currentNumber = 1
    @State private var isAnimating = false
    
    let maxNumber = 5
    
    var body: some View {
        VStack(spacing: 30) {
            Text("すうじをかぞえよう！")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            Text("\(currentNumber)")
                .font(.system(size: 120, weight: .bold))
                .foregroundColor(.blue)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
            
            HStack(spacing: 20) {
                ForEach(1...currentNumber, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                }
            }
            
            HStack(spacing: 40) {
                Button(action: {
                    if currentNumber > 1 {
                        currentNumber -= 1
                        animate()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    if currentNumber < maxNumber {
                        currentNumber += 1
                        animate()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)
                }
            }
            .padding(.top, 20)
        }
        .padding()
    }
    
    private func animate() {
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
        }
    }
}

#Preview {
    NumberGame()
} 