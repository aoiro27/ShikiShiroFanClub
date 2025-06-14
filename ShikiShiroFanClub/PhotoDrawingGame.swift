import SwiftUI
import PhotosUI
import PencilKit
import AVFoundation

struct PhotoDrawingGame: View {
    @State private var selectedImage: UIImage?
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingSaveAlert = false
    @State private var savedImage: UIImage?
    
    var body: some View {
        ZStack {
            // 背景とキャンバス
            if let selectedImage = selectedImage {
                ZStack {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    
                    CanvasView(canvasView: $canvasView, toolPicker: toolPicker)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                }
            } else {
                Text("写真を選択してください")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            
            // ボタン類
            VStack {
                Spacer()
                HStack(spacing: 20) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        showingCamera = true
                    }) {
                        Image(systemName: "camera")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        canvasView.drawing = PKDrawing()
                    }) {
                        Image(systemName: "trash")
                            .font(.title)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        saveDrawing()
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView(image: $selectedImage)
        }
        .alert("保存しました！", isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        }
    }
    
    private func saveDrawing() {
        guard let selectedImage = selectedImage else { return }
        
        // 背景画像と描画内容を合成
        let renderer = UIGraphicsImageRenderer(size: canvasView.bounds.size)
        let image = renderer.image { ctx in
            // 背景画像を描画
            selectedImage.draw(in: canvasView.bounds)
            
            // 描画内容を合成
            canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        }
        
        // 非同期で保存処理を実行
        DispatchQueue.global(qos: .userInitiated).async {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            // メインスレッドでアラートを表示
            DispatchQueue.main.async {
                self.savedImage = image
                self.showingSaveAlert = true
            }
        }
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var toolPicker: PKToolPicker
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 1)
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        toolPicker.addObserver(uiView)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.modalPresentationStyle = .fullScreen
        picker.cameraOverlayView = nil
        picker.cameraViewTransform = .identity
        
        // カメラのプレビューを画面いっぱいに設定
        if let cameraView = picker.view {
            cameraView.frame = UIScreen.main.bounds
            cameraView.backgroundColor = .black
            
            // カメラのプレビューレイヤーを画面いっぱいに設定
            if let previewLayer = cameraView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
                previewLayer.frame = UIScreen.main.bounds
                previewLayer.videoGravity = .resizeAspectFill
            }
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // カメラのプレビューを画面いっぱいに表示
        uiViewController.view.frame = UIScreen.main.bounds
        uiViewController.view.backgroundColor = .black
        
        // カメラのプレビューレイヤーを画面いっぱいに設定
        if let previewLayer = uiViewController.view.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = UIScreen.main.bounds
            previewLayer.videoGravity = .resizeAspectFill
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
} 