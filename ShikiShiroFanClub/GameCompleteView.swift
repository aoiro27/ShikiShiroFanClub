import SwiftUI

struct GameCompleteView: View {
    let score: Int
    let totalQuestions: Int
    let onRestart: () -> Void
    let onFinish: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "trophy.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.yellow)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
            
            Text("おつかれさま！")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.blue)
            
            Text("\(score)もん せいかい！")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.green)
            
            Text("\(totalQuestions)もんちゅう \(score)もん せいかい")
                .font(.system(size: 24))
                .foregroundColor(.gray)
            
            HStack(spacing: 20) {
                Button(action: onRestart) {
                    VStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 30))
                        Text("もういちど")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 160, height: 80)
                    .background(Color.blue)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                
                Button(action: onFinish) {
                    VStack {
                        Image(systemName: "house.fill")
                            .font(.system(size: 30))
                        Text("おわる")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 160, height: 80)
                    .background(Color.green)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
            }
            .padding(.top, 20)
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
    GameCompleteView(
        score: 4,
        totalQuestions: 5,
        onRestart: {},
        onFinish: {}
    )
} 