//
//  camera.swift
//  bedhead
//
//  Created by Ivan Chiu on 7/29/24.
//
import SwiftUI
import AVFoundation

class CameraViewModel: ObservableObject {
    @Published var cameraService = CameraService()
}
// Add flash, zoom,
struct CameraScreen: View {
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var cameraViewModel: CameraViewModel
    @State private var flashMode: AVCaptureDevice.FlashMode = .off
    @State private var timer: Timer?
    @State private var remainingTime = 300 // 5 minutes
    //@State private var flashMode: cameraViewModel.cameraService.flashMode = .off

    var body: some View {
        ZStack {
            CameraView(session: cameraViewModel.cameraService.session)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("BedHead")
                    .font(.system(size: 35))
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, -1)
                    .padding(.top, 12)
                    .foregroundColor(.black)
                
                Text("\(formattedTime)")
                    .font(.system(size: 25))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, -1)
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack{
                    Button(action: {
                        toggleFlashMode()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 50, height: 50)
                                .padding(.leading)
                            Image(systemName: "bolt.fill")
                                .resizable()
                                .foregroundColor(flashIconColor())
                                .frame(width: 30, height: 30)
                                .padding(.leading)
                        }
                    }
                    .padding(.bottom)
                    .padding(.trailing, 70)
                    
                    Button(action: {
                        cameraViewModel.cameraService.capturePhoto()
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 75, height: 75)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                        }
                    }
                    .padding(.bottom)
                    Spacer()
                    Button(action: {
                        cameraViewModel.cameraService.changeCamera()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 50, height: 50) // Background circle
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30) // Icon size
                        }
                    }
                    .offset(x: -20, y: -10)
                }.padding()
            }
        }
        .onAppear {
            cameraViewModel.cameraService.checkForPermissions()
            cameraViewModel.cameraService.configure()
            cameraViewModel.cameraService.start()
            startTimer()
        }
        .onDisappear {
            cameraViewModel.cameraService.stop()
            stopTimer()
        }
        .onChange(of: cameraViewModel.cameraService.photo) { oldPhoto, newPhoto in
            if let photo = newPhoto {
                // Do something with the captured photo
                print("Photo captured: \(photo.id)")
            }
        }
    }
    private var formattedTime: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleFlashMode() {
        flashMode = (flashMode == .off) ? .on : .off
        cameraViewModel.cameraService.flashMode = flashMode
    }
    
    private func flashIconColor() -> Color {
        return flashMode == .off ? Color.gray : Color.white
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer?.invalidate()
                timer = nil
                //isPresented.toggle()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct CameraScreen_Preview: PreviewProvider {
    @StateObject static private var cameraViewModel = CameraViewModel()
    @State static private var isAlarmTriggered = true
    static var previews: some View {
        CameraScreen(isPresented: $isAlarmTriggered, cameraViewModel: cameraViewModel)
    }
}
