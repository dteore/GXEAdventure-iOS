
import SwiftUI
import AVFoundation
import AVKit

// MARK: - Custom Resource Loader Delegate
class SplashVideoResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private let videoData: Data
    private let contentType: String

    init(videoData: Data, contentType: String) {
        self.videoData = videoData
        self.contentType = contentType
        super.init()
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url, url.scheme == "splash-video" else {
            return false
        }

        if let contentInformationRequest = loadingRequest.contentInformationRequest {
            contentInformationRequest.contentType = contentType
            contentInformationRequest.contentLength = Int64(videoData.count)
            contentInformationRequest.isByteRangeAccessSupported = true
        }

        if let dataRequest = loadingRequest.dataRequest {
            let offset = dataRequest.currentOffset
            let length = Int(dataRequest.requestedLength)
            let endOffset = Int(offset) + length

            if endOffset <= videoData.count {
                let subdata = videoData.subdata(in: Int(offset)..<endOffset)
                dataRequest.respond(with: subdata)
                loadingRequest.finishLoading()
                return true
            }
        }
        return false
    }
}

// MARK: - SplashViewModel
class SplashViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var videoReady = false
    @Published var videoStarted = false
    
    private var dismissWorkItem: DispatchWorkItem?
    private var resourceLoaderDelegate: SplashVideoResourceLoaderDelegate?
    private var playerItemObservation: NSKeyValueObservation? // To observe playerItem status
    
    var showSplashBinding: Binding<Bool>

    init(showSplash: Binding<Bool>) {
        self.showSplashBinding = showSplash
    }

    func setupVideoPlayer() {
        print("=== SPLASH VIDEO SETUP (NSDataAsset with ResourceLoader) ===")
        
        guard let asset = NSDataAsset(name: "NVRSE_splash") else {
            let msg = "❌ Could not load video asset: NVRSE_splash"
            print(msg)
            errorMessage = "Video asset 'NVRSE_splash' not found"
            showError = true
            return
        }
        
        print("✅ NVRSE_splash video asset loaded successfully")
        
        guard let customURL = URL(string: "splash-video://local/NVRSE_splash.mp4") else {
            errorMessage = "Failed to create custom URL"
            showError = true
            return
        }

        let delegate = SplashVideoResourceLoaderDelegate(videoData: asset.data, contentType: "video/mp4")
        self.resourceLoaderDelegate = delegate

        let urlAsset = AVURLAsset(url: customURL)
        urlAsset.resourceLoader.setDelegate(delegate, queue: .main)

        let playerItem = AVPlayerItem(asset: urlAsset)
        self.player = AVPlayer(playerItem: playerItem)
        self.player?.isMuted = true
        
        // Observe playerItem status directly
        playerItemObservation = playerItem.observe(\AVPlayerItem.status, options: [.new]) { [weak self] (item, change) in
            guard let self = self else { return }
            
            switch item.status {
            case .readyToPlay:
                print("✅ Video ready to play, starting playback...")
                self.player?.play()
                
                DispatchQueue.main.async {
                    withAnimation(.easeIn(duration: 0.3)) {
                        self.videoReady = true
                    }
                }
                
                print("🎬 Video should be playing now, showing UI...")
                self.videoStarted = true
                
            case .failed:
                print("❌ Video failed to load: \(String(describing: item.error))")
                self.errorMessage = "Video failed to load"
                self.showError = true
                self.dismissSplash()
                
            case .unknown:
                print("⏳ Video status still unknown...")
            @unknown default:
                self.dismissSplash()
            }
        }
        
        // When video ends, immediately go to onboarding (only if video actually played)
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            print("🎬 Video completed, going to onboarding...")
            if self?.videoStarted == true {
                self?.dismissSplash()
            } else {
                print("⚠️ Video ended before playing - relying on dismissWorkItem")
            }
        }
        
        print("⏳ Monitoring video status for readiness...")
    }
    
    func cleanupPlayer() {
        print("🧹 Cleaning up splash video player")
        player?.pause()
        player = nil
        videoReady = false
        videoStarted = false
        resourceLoaderDelegate = nil
        playerItemObservation = nil // Invalidate observation
        NotificationCenter.default.removeObserver(self)
    }
    
    func dismissSplash() {
        dismissWorkItem?.cancel()
        showSplashBinding.wrappedValue = false
        print("🚀 Dismissing splash screen.")
    }

    func startDismissTimer() {
        dismissWorkItem = DispatchWorkItem { [weak self] in
            print("⏰ Forced dismiss timer completed, dismissing splash screen.")
            self?.dismissSplash()
        }
        if let workItem = dismissWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: workItem) // Increased to 4 seconds
        }
    }
}

// MARK: - SplashView
struct SplashView: View {
    @Binding var showSplash: Bool
    @StateObject private var viewModel: SplashViewModel

    init(showSplash: Binding<Bool>) {
        self._showSplash = showSplash
        _viewModel = StateObject(wrappedValue: SplashViewModel(showSplash: showSplash))
        print("✅ SplashView init called.")
    }

    var body: some View {
        ZStack {
            // Black background (always visible)
            Color.black
                .ignoresSafeArea(.all)
            
            // Video player (only visible when ready)
            if let player = viewModel.player, viewModel.videoReady {
                VideoPlayer(player: player)
                    .disabled(true) // Disable controls
                    .ignoresSafeArea(.all)
                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
            }
            
            // NVRSE logo overlay (only visible when video is ready)
            if viewModel.videoReady {
                Image("NVRSE")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
            }
            
            // Error display
            if viewModel.showError {
                VStack {
                    Text("Video Load Error")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(viewModel.errorMessage)
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
        .onAppear {
            print("✅ SplashView appeared.")
            viewModel.setupVideoPlayer()
            viewModel.startDismissTimer() // Start the forced dismissal timer
        }
        .onDisappear {
            viewModel.cleanupPlayer()
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
}
