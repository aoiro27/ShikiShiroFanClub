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
    @Binding var selectedGame: GameType?
    
    let gameTime: Double = 30 // 30秒
    @State private var timeLeft: Double = 30
    
    var body: some View {
        ZStack {
            Image("background2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: { selectedGame = nil }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    Spacer()
                    Text("スコア: \(score)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                    Spacer()
                    Text("のこり: \(Int(timeLeft))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
                .padding(.horizontal)
                .padding(.top, 20)
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
                        selectedGame = nil
                    }
                    .font(.system(size: 24, weight: .bold))
                    .padding()
                }
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
                .padding()
            }
        }
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
        timeLeft = gameTime
        isGameOver = false
        zombies = []
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            updateZombies()
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            timeLeft -= 1
            if timeLeft <= 0 {
                t.invalidate()
                timer?.invalidate()
                isGameOver = true
            }
        }
    }
    
    func updateZombies() {
        // ゾンビを前進
        if(!zombies.isEmpty){
            print(zombies[0].y)
        }
        for i in zombies.indices {
            zombies[i].y += 5
        }
        if(!zombies.isEmpty){
            print(zombies[0].y)
        }
        // 画面外のゾンビを消す
        zombies.removeAll { $0.y > UIScreen.main.bounds.height + 100 }
        // ランダムで新しいゾンビを追加
        if Int.random(in: 0...20) == 0 {
            let x = CGFloat.random(in: 80...(UIScreen.main.bounds.width-80))
            let speed = Double.random(in: 2.0...4.0)
            let images = ["zombie1", "zombie1", "zombie1"] // かわいいゾンビ画像名
            let imageName = images.randomElement() ?? "zombie1"
            zombies.append(Zombie(x: x, y: 200, speed: speed, imageName: imageName))
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
        guard let url = Bundle.main.url(forResource: "pop", withExtension: "wav") else { return }
        do {
            popPlayer = try AVAudioPlayer(contentsOf: url)
            popPlayer?.volume = 1.0
            popPlayer?.play()
        } catch {}
    }
} 
