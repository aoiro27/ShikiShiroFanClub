 
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
        VStack(spacing: 30) {
            Text("なきごえをきいてみよう！")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            Spacer()
            
            if showingAnswer {
                Image(systemName: animals[currentAnimal].image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.orange)
                    .transition(.scale)
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
                    .foregroundColor(.blue)
                    .scaleEffect(isPlaying ? 1.2 : 1.0)
            }
            
            if showingAnswer {
                Text(animals[currentAnimal].name)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.green)
                    .transition(.scale)
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
            }
            .padding(.bottom, 30)
        }
        .padding()
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
