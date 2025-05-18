import SwiftUI
import AVFoundation

class Zombie: Identifiable, Equatable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var speed: Double
    var imageName: String

    static func == (lhs: Zombie, rhs: Zombie) -> Bool {
        lhs.id == rhs.id
    }
    
    init(x: CGFloat, y: CGFloat, speed: Double, imageName: String) {
        self.x = x
        self.y = y
        self.speed = speed
        self.imageName = imageName
    }
}

struct ZombieShootingGame: View {
    @State private var zombies: [Zombie] = []
    @State private var timer: Timer?
    @State private var score = 0
    @State private var isGameOver = false
    @State private var bgmPlayer: AVAudioPlayer?
    @State private var popPlayer: AVAudioPlayer?
    @State private var missPlayer: AVAudioPlayer?
    @State private var life = 3
    @State private var heartScale: CGFloat = 1.0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Image("zombie_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                let safeTop = geometry.safeAreaInsets.top
                HStack {
                    ForEach(0..<life, id: \.self) { _ in
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 32))
                            .scaleEffect(heartScale)
                            .animation(.easeInOut(duration: 0.2), value: heartScale)
                    }
                    Spacer()
                    Text("スコア: \(score)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                    
                }
               // .padding(.horizontal)
                .padding(.top, safeTop + 8)
            }
            
            // ゾンビたち
            ForEach(zombies) { zombie in
                Image(zombie.imageName)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .position(x: zombie.x, y: zombie.y)
                    .onTapGesture {
                        popZombie(zombie)
                    }
                    .animation(.linear(duration: 0.1), value: zombies)
            }
            
            
            if isGameOver {
                VStack(spacing: 20) {
                    Text("ゲーム終了！")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                    Text("スコア: \(score)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.yellow)
                        .shadow(radius: 2)
                    Button("もういちど！") {
                        startGame()
                    }
                    .font(.system(size: 28, weight: .bold))
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    Button("ホームにもどる") {
                        dismiss()
                    }
                    .font(.system(size: 24, weight: .bold))
                    .padding()
                }
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
                .padding()
            }
            
        }
        .navigationBarBackButtonHidden(false)
        .onAppear {
            startGame()
            playBGM()
        }
        .onDisappear {
            timer?.invalidate()
            bgmPlayer?.stop()
        }
    }
    
    func startGame() {
        score = 0
        isGameOver = false
        zombies = []
        life = 3
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            updateZombies()
        }
    }
    
    func updateZombies() {
        // ゾンビを前進
        zombies = zombies.map { zombie in
            var z = zombie
            z.y += CGFloat(z.speed)
            return z
        }
        // 画面外のゾンビを消す＋ライフ減少
        let screenHeight = UIScreen.main.bounds.height
        let survived = zombies.filter { $0.y <= screenHeight + 100 }
        let passed = zombies.filter { $0.y > screenHeight + 100 }
        if !passed.isEmpty {
            life -= passed.count
            playMissSound()
            animateHeart()
            if life <= 0 {
                isGameOver = true
                timer?.invalidate()
            }
        }
        zombies = survived
        // ランダムで新しいゾンビを追加
        if Int.random(in: 0...20) == 0 {
            let x = CGFloat.random(in: 80...(UIScreen.main.bounds.width-80))
            let speed = Double.random(in: 2.0...4.0)
            let images = ["zombie1"] // かわいいゾンビ画像名
            let imageName = images.randomElement() ?? "zombie1"
            zombies.append(Zombie(x: x, y: -80, speed: speed, imageName: imageName))
        }
    }
    
    func popZombie(_ zombie: Zombie) {
        // 効果音
        playPopSound()
        // スコア加算
        score += 1
        // ゾンビを消す
        zombies.removeAll { $0.id == zombie.id }
    }
    
    func playBGM() {
        guard let url = Bundle.main.url(forResource: "zombie_bgm", withExtension: "mp3") else { return }
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.numberOfLoops = -1
            bgmPlayer?.volume = 0.4
            bgmPlayer?.play()
        } catch {}
    }
    
    func playPopSound() {
        guard let url = Bundle.main.url(forResource: "bomb", withExtension: "mp3") else { return }
        do {
            popPlayer = try AVAudioPlayer(contentsOf: url)
            popPlayer?.volume = 1.0
            popPlayer?.play()
        } catch {}
    }
    
    func playMissSound() {
        guard let url = Bundle.main.url(forResource: "damage", withExtension: "mp3") else { return }
        do {
            missPlayer = try AVAudioPlayer(contentsOf: url)
            missPlayer?.volume = 1.0
            missPlayer?.play()
        } catch {}
    }
    
    func animateHeart() {
        heartScale = 0.7
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            heartScale = 1.0
        }
    }
}

struct ZombieShootingGame_Previews: PreviewProvider {
    static var previews: some View {
        ZombieShootingGame()
    }
} 
