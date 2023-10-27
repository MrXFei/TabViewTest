import SwiftUI

struct MessagesView: View {
    let props: Props

    var body: some View {
        NavigationLink(destination: CameraView(), label: {Text("camera")})
        List {
            Section(header: owner) {
                ForEach((1...props.fakeMsgsCount), id: \.self) {
                    message($0)
                }
            }
        }
                .listStyle(PlainListStyle())
    }

    private var owner: some View {
        Text(props.ownerName)
                .clipShape(Capsule(style: .continuous))
                .frame(height: Style.ownerHeight)
    }

    private func message(_ index: Int) -> some View {
        NavigationLink(destination: Text("Details for message: \(index)")) {
            VStack(alignment: .leading) {
                Text("message \(index) ")
                Text("timestamp: \(Date().timeIntervalSince1970)")
            }
        }
    }
}

struct CameraView: View {
    @State private var isCameraPresented: Bool = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }

            Button("打开相机") {
                isCameraPresented = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                .ignoresSafeArea()
        }
    }
}

//import SwiftUI
import AVFoundation

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    
    // 根据设备能力决定是否使用 Portrait 模式
    var usePortraitMode: Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                let supportedFormats = cameraDevice.formats
                for format in supportedFormats {
                    if !format.supportedDepthDataFormats.isEmpty {
                        return true
                    }
                }
            }
        }
        return false
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        
        // 如果设备支持 Portrait 模式，则启用
        if usePortraitMode {
            print("xxxxx")
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .rear
        } else {
            print("yyyyy")
            // 如果不支持 Portrait 模式，你可以选择其他设置或者什么都不做
        }
        
        return picker
    }


    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
}
