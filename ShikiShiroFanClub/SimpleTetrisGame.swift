import SwiftUI

struct SimpleTetrisGame: View {
    @Environment(\.dismiss) private var dismiss
    @State private var grid: [[Color]] = Array(repeating: Array(repeating: .clear, count: 10), count: 20)
    @State private var currentBlock: Block?
    @State private var gameTimer: Timer?
    @State private var score: Int = 0
    @State private var isGameOver = false
    @State private var dragOffset: CGSize = .zero
    @State private var lastDragPosition: CGPoint?
    
    // ゲームの設定
    private let gridWidth = 10
    private let gridHeight = 20
    private let blockSize: CGFloat = 30
    private let fallInterval: TimeInterval = 1.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack {
                // スコア表示
                Text("スコア: \(score)")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                
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
                        ForEach(0..<2) { y in
                            ForEach(0..<2) { x in
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
                .frame(width: CGFloat(gridWidth) * (blockSize + 1),
                       height: CGFloat(gridHeight) * (blockSize + 1))
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
                .padding()
                
                // 操作ボタン（バックアップとして残しておく）
                HStack(spacing: 50) {
                    Button(action: moveLeft) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: moveRight) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: moveDown) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                // 戻るボタン
                Button(action: {
                    gameTimer?.invalidate()
                    dismiss()
                }) {
                    Text("もどる")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear {
            startGame()
        }
        .alert("ゲームオーバー", isPresented: $isGameOver) {
            Button("もう一度") {
                resetGame()
            }
            Button("もどる") {
                dismiss()
            }
        } message: {
            Text("スコア: \(score)")
        }
    }
    
    private func startGame() {
        resetGame()
        gameTimer = Timer.scheduledTimer(withTimeInterval: fallInterval, repeats: true) { _ in
            moveDown()
        }
    }
    
    private func resetGame() {
        grid = Array(repeating: Array(repeating: .clear, count: gridWidth), count: gridHeight)
        score = 0
        isGameOver = false
        spawnNewBlock()
    }
    
    private func spawnNewBlock() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
        let randomColor = colors.randomElement() ?? .red
        currentBlock = Block(color: randomColor, x: gridWidth / 2 - 1, y: -2)
    }
    
    private func moveLeft() {
        guard let block = currentBlock else { return }
        let newBlock = Block(color: block.color, x: block.x - 1, y: block.y)
        if isValidPosition(block: newBlock) {
            currentBlock = newBlock
        }
    }
    
    private func moveRight() {
        guard let block = currentBlock else { return }
        let newBlock = Block(color: block.color, x: block.x + 1, y: block.y)
        if isValidPosition(block: newBlock) {
            currentBlock = newBlock
        }
    }
    
    private func moveDown() {
        guard let block = currentBlock else { return }
        let newBlock = Block(color: block.color, x: block.x, y: block.y + 1)
        
        if isValidPosition(block: newBlock) {
            currentBlock = newBlock
        } else {
            // ブロックが画面内にある場合のみ配置
            if block.y >= 0 {
                placeBlock()
                checkLines()
            }
            spawnNewBlock()
            
            // 新しいブロックが配置できない場合はゲームオーバー
            if !isValidPosition(block: currentBlock!) {
                isGameOver = true
                gameTimer?.invalidate()
            }
        }
    }
    
    private func isValidPosition(block: Block) -> Bool {
        // 2x2のブロックの位置チェック
        for y in 0..<2 {
            for x in 0..<2 {
                let gridX = block.x + x
                let gridY = block.y + y
                
                // グリッドの範囲外チェック
                if gridX < 0 || gridX >= gridWidth {
                    return false
                }
                
                // 下端チェック
                if gridY >= gridHeight {
                    return false
                }
                
                // 既存のブロックとの衝突チェック（画面内の場合のみ）
                if gridY >= 0 && grid[gridY][gridX] != .clear {
                    return false
                }
            }
        }
        return true
    }
    
    private func placeBlock() {
        guard let block = currentBlock else { return }
        
        // 2x2のブロックを配置
        for y in 0..<2 {
            for x in 0..<2 {
                let gridX = block.x + x
                let gridY = block.y + y
                if gridY >= 0 && gridY < gridHeight && gridX >= 0 && gridX < gridWidth {
                    grid[gridY][gridX] = block.color
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
        }
        
        // 最上段にブロックがあるかチェック
        if grid[0].contains(where: { $0 != .clear }) {
            isGameOver = true
            gameTimer?.invalidate()
        }
    }
}

struct Block {
    let color: Color
    var x: Int
    var y: Int
}

struct SimpleTetrisGame_Previews: PreviewProvider {
    static var previews: some View {
        SimpleTetrisGame()
    }
} 