import SwiftUI
import AVFoundation

struct AnimalSoundGame: View {
    @State private var currentAnimal = 0
    @State private var showingAnswer = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    
    let animals = [
        (name: "いぬ", sound: "dog", image: "dog.fill"),
        (name: "ねこ", sound: "cat", image: "cat.fill"),
        (name: "うし", sound: "cow", image: "cow.fill"),
        (name: "ぶた", sound: "pig", image: "pig.fill"),
        (name: "ひつじ", sound: "sheep", image: "sheep.fill")
    ]
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("なきごえをきいてみよう！")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .padding(.top, 20)
                
                Spacer()
                
                if showingAnswer {
                    Image(systemName: animals[currentAnimal].image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.orange)
                        .transition(.scale)
                        .shadow(radius: 5)
                }
                
                Button(action: {
                    withAnimation {
                        playSound()
                    }
                }) {
                    Image(systemName: isPlaying ? "speaker.wave.2.fill" : "speaker.wave.2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .scaleEffect(isPlaying ? 1.2 : 1.0)
                        .shadow(radius: 5)
                }
                
                if showingAnswer {
                    Text(animals[currentAnimal].name)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale)
                        .shadow(radius: 2)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        if showingAnswer {
                            currentAnimal = (currentAnimal + 1) % animals.count
                            showingAnswer = false
                        } else {
                            showingAnswer = true
                        }
                    }
                }) {
                    Text(showingAnswer ? "つぎへ" : "こたえをみる")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 60)
                        .background(showingAnswer ? Color.green : Color.blue)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
    }
    
    func playSound() {
        guard let soundURL = Bundle.main.url(forResource: animals[currentAnimal].sound, withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
            isPlaying = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPlaying = false
            }
        } catch {
            print("音声の再生に失敗しました: \(error)")
        }
    }
}

#Preview {
    AnimalSoundGame()
}
