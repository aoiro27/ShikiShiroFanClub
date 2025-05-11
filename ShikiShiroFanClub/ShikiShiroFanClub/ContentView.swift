//
//  ContentView.swift
//  ShikiShiroFanClub
//
//  Created by aoiro on 2025/05/12.
//

import SwiftUI
import SwiftData
import AVFoundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

// 動物の鳴き声ボタンアプリの実装
struct AnimalSoundButton: View {
    let animalName: String
    let soundFileName: String

    var body: some View {
        Button(action: {
            playSound(soundFileName)
        }) {
            Text(animalName)
                .font(.title)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }

    private func playSound(_ fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Sound file not found: \(fileName)")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}

struct AnimalSoundApp: View {
    var body: some View {
        VStack {
            Text("動物の鳴き声")
                .font(.largeTitle)
                .padding()

            AnimalSoundButton(animalName: "犬", soundFileName: "dog")
            AnimalSoundButton(animalName: "猫", soundFileName: "cat")
            AnimalSoundButton(animalName: "牛", soundFileName: "cow")
        }
    }
}

#Preview {
    AnimalSoundApp()
}
