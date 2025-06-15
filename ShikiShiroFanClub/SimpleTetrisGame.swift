import SwiftUI
import AVFoundation

struct Block {
    let color: Color
    var x: Int
    var y: Int
    var shape: [[Bool]]
}

struct SimpleTetrisGame: View {
    @Environment(\.dismiss) private var dismiss
    @State private var grid: [[Color]] = Array(repeating: Array(repeating: .clear, count: 10), count: 20)
    @State private var currentBlock: Block?
    @State private var gameTimer: Timer?
    @State private var score: Int = 0
    @State private var isGameOver = false
    @State private var dragOffset: CGSize = .zero
    @State private var lastDragPosition: CGPoint?
    @State private var flashOpacity: Double = 0
    @State private var moveSoundPlayer: AVAudioPlayer?
    @State private var bottomSoundPlayer: AVAudioPlayer?
    @State private var bombSoundPlayer: AVAudioPlayer?
    @State private var bgmPlayer: AVAudioPlayer?
    
    // ゲームの設定
    private let gridWidth = 8
    private let gridHeight = 12
    private let blockSize: CGFloat = 50
    private let fallInterval: TimeInterval = 1.0
    
    // テトリミノの形状定義
    private let tetrominoShapes: [[[Bool]]] = [
        // I型（縦棒）
        [[true],
         [true],
         [true],
         [true]],
        // 2x2のブロック
        [[true, true],
         [true, true]]
    ]
    
    // 使用可能な色のリスト
    private let availableColors: [Color] = [
        .red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // スコア表示
                Text("スコア: \(score)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // ゲームグリッド
                ZStack {
                    // 固定されたブロック
                    VStack(spacing: 1) {
                        ForEach(0..<gridHeight, id: \.self) { row in
                            HStack(spacing: 1) {
                                ForEach(0..<gridWidth, id: \.self) { column in
                                    Rectangle()
                                        .fill(grid[row][column])
                                        .frame(width: blockSize, height: blockSize)
                                        .border(Color.gray, width: 0.5)
                                }
                            }
                        }
                    }
                    .background(Color.black)
                    
                    // 落下中のブロック
                    if let block = currentBlock {
                        ForEach(0..<block.shape.count, id: \.self) { y in
                            ForEach(0..<block.shape[y].count, id: \.self) { x in
                                if block.shape[y][x] {
                                    Rectangle()
                                        .fill(block.color)
                                        .frame(width: blockSize, height: blockSize)
                                        .border(Color.gray, width: 0.5)
                                        .position(
                                            x: CGFloat(block.x + x) * (blockSize + 1) + blockSize / 2 + dragOffset.width,
                                            y: CGFloat(block.y + y) * (blockSize + 1) + blockSize / 2 + dragOffset.height
                                        )
                                }
                            }
                        }
                    }
                }
                .frame(width: CGFloat(gridWidth) * (blockSize + 1),
                       height: CGFloat(gridHeight) * (blockSize + 1))
                .overlay(
                    Rectangle()
                        .fill(Color.white)
                        .opacity(flashOpacity)
                )
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if lastDragPosition == nil {
                                lastDragPosition = gesture.location
                                return
                            }
                            
                            let dx = gesture.location.x - lastDragPosition!.x
                            let dy = gesture.location.y - lastDragPosition!.y
                            
                            // 水平方向の移動（左右）
                            if abs(dx) > blockSize / 2 {
                                if dx > 0 {
                                    moveRight()
                                } else {
                                    moveLeft()
                                }
                                lastDragPosition = gesture.location
                            }
                            
                            // 垂直方向の移動（下）
                            if dy > blockSize / 2 {
                                moveDown()
                                lastDragPosition = gesture.location
                            }
                        }
                        .onEnded { _ in
                            lastDragPosition = nil
                            dragOffset = .zero
                        }
                )
                
                Spacer()
            }
        }
        .onAppear {
            startGame()
            startBGM()
        }
        .onDisappear {
            stopBGM()
            gameTimer?.invalidate()
            gameTimer = nil
        }
        .alert("ゲームオーバー", isPresented: $isGameOver) {
            Button("もう一度") {
                resetGame()
                startGame()
            }
            Button("もどる") {
                dismiss()
            }
        } message: {
            Text("スコア: \(score)")
        }
    }
    
    private func startBGM() {
        guard let soundURL = Bundle.main.url(forResource: "mino_bgm", withExtension: "mp3") else {
            print("BGM file not found")
            return
        }
        
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: soundURL)
            bgmPlayer?.numberOfLoops = -1  // 無限ループ
            bgmPlayer?.volume = 0.5  // 音量を50%に設定
            bgmPlayer?.prepareToPlay()
            bgmPlayer?.play()
        } catch {
            print("Failed to play BGM: \(error.localizedDescription)")
        }
    }
    
    private func stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer = nil
    }
    
    private func startGame() {
        // 既存のタイマーを停止
        gameTimer?.invalidate()
        gameTimer = nil
        
        // ゲームの初期化
        resetGame()
        
        // タイマーをメインスレッドで実行
        DispatchQueue.main.async {
            self.gameTimer = Timer.scheduledTimer(withTimeInterval: self.fallInterval, repeats: true) { _ in
                self.moveDown()
            }
            // タイマーをRunLoopに追加
            RunLoop.current.add(self.gameTimer!, forMode: .common)
        }
    }
    
    private func resetGame() {
        // グリッドの初期化
        grid = Array(repeating: Array(repeating: .clear, count: gridWidth), count: gridHeight)
        score = 0
        isGameOver = false
        currentBlock = nil  // 現在のブロックをクリア
        
        // 最初のブロックを生成
        DispatchQueue.main.async {
            self.spawnNewBlock()
        }
    }
    
    private func spawnNewBlock() {
        let randomShape = tetrominoShapes.randomElement()!
        let randomColor = availableColors.randomElement()!
        
        // ブロックの初期位置を中央に設定
        let startX = (gridWidth - randomShape[0].count) / 2
        let startY = 0  // 最上段から開始
        
        print("Spawning new block at x: \(startX), y: \(startY)")
        print("Shape size: \(randomShape.count) rows, \(randomShape[0].count) columns")
        
        currentBlock = Block(color: randomColor, x: startX, y: startY, shape: randomShape)
        
        // 新しいブロックが配置できない場合はゲームオーバー
        if !isValidPosition(block: currentBlock!) {
            print("Invalid position detected - Game Over")
            isGameOver = true
            gameTimer?.invalidate()
            gameTimer = nil
            return
        }
    }
    
    private func moveLeft() {
        guard let block = currentBlock else { return }
        let newBlock = Block(color: block.color, x: block.x - 1, y: block.y, shape: block.shape)
        if isValidPosition(block: newBlock) {
            currentBlock = newBlock
            playMoveSound()
        }
    }
    
    private func moveRight() {
        guard let block = currentBlock else { return }
        let newBlock = Block(color: block.color, x: block.x + 1, y: block.y, shape: block.shape)
        if isValidPosition(block: newBlock) {
            currentBlock = newBlock
            playMoveSound()
        }
    }
    
    private func moveDown() {
        guard let block = currentBlock else { return }
        let newBlock = Block(color: block.color, x: block.x, y: block.y + 1, shape: block.shape)
        
        if isValidPosition(block: newBlock) {
            currentBlock = newBlock
            playMoveSound()
        } else {
            // ブロックが画面内にある場合のみ配置
            if block.y >= 0 {
                placeBlock()
                playBottomSound()
                checkLines()
            }
            spawnNewBlock()
        }
    }
    
    private func isValidPosition(block: Block) -> Bool {
        // ブロックの各セルをチェック
        for y in 0..<block.shape.count {
            for x in 0..<block.shape[y].count {
                if block.shape[y][x] {
                    let gridX = block.x + x
                    let gridY = block.y + y
                    
                    print("Checking position: x: \(gridX), y: \(gridY)")
                    
                    // グリッドの範囲外チェック（左右）
                    if gridX < 0 || gridX >= gridWidth {
                        print("Invalid: Out of bounds horizontally")
                        return false
                    }
                    
                    // 下端チェック
                    if gridY >= gridHeight {
                        print("Invalid: Out of bounds vertically (bottom)")
                        return false
                    }
                    
                    // 既存のブロックとの衝突チェック
                    if gridY >= 0 && grid[gridY][gridX] != .clear {
                        print("Invalid: Collision with existing block")
                        return false
                    }
                }
            }
        }
        return true
    }
    
    private func placeBlock() {
        guard let block = currentBlock else { return }
        
        for y in 0..<block.shape.count {
            for x in 0..<block.shape[y].count {
                if block.shape[y][x] {
                    let gridX = block.x + x
                    let gridY = block.y + y
                    if gridY >= 0 && gridY < gridHeight && gridX >= 0 && gridX < gridWidth {
                        grid[gridY][gridX] = block.color
                    }
                }
            }
        }
    }
    
    private func checkLines() {
        var linesCleared = 0
        
        for y in 0..<gridHeight {
            if grid[y].allSatisfy({ $0 != .clear }) {
                // ラインを削除
                grid.remove(at: y)
                // 新しい空のラインを追加
                grid.insert(Array(repeating: .clear, count: gridWidth), at: 0)
                linesCleared += 1
            }
        }
        
        // スコア加算
        if linesCleared > 0 {
            score += linesCleared * 100
            
            // フラッシュエフェクトを表示
            withAnimation(.easeInOut(duration: 0.1)) {
                flashOpacity = 0.7
            }
            
            // 効果音を再生
            playBombSound()
            
            // 0.2秒後にフラッシュを消す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    flashOpacity = 0
                }
            }
        }
        
        // 最上段にブロックがあるかチェック
        if grid[0].contains(where: { $0 != .clear }) {
            isGameOver = true
            gameTimer?.invalidate()
            gameTimer = nil
        }
    }
    
    private func playMoveSound() {
        guard let soundURL = Bundle.main.url(forResource: "mino_move", withExtension: "mp3") else {
            print("Move sound file not found")
            return
        }
        
        do {
            moveSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
            moveSoundPlayer?.prepareToPlay()
            moveSoundPlayer?.play()
        } catch {
            print("Failed to play move sound: \(error.localizedDescription)")
        }
    }
    
    private func playBottomSound() {
        guard let soundURL = Bundle.main.url(forResource: "mino_bottom", withExtension: "mp3") else {
            print("Bottom sound file not found")
            return
        }
        
        do {
            bottomSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
            bottomSoundPlayer?.prepareToPlay()
            bottomSoundPlayer?.play()
        } catch {
            print("Failed to play bottom sound: \(error.localizedDescription)")
        }
    }
    
    private func playBombSound() {
        guard let soundURL = Bundle.main.url(forResource: "bomb", withExtension: "mp3") else {
            print("Bomb sound file not found")
            return
        }
        
        do {
            bombSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
            bombSoundPlayer?.prepareToPlay()
            bombSoundPlayer?.play()
        } catch {
            print("Failed to play bomb sound: \(error.localizedDescription)")
        }
    }
}

struct SimpleTetrisGame_Previews: PreviewProvider {
    static var previews: some View {
        SimpleTetrisGame()
    }
} 
