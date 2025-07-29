import SwiftUI
import AVKit

struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var isActive = false
    @State private var player: AVQueuePlayer?
    @State private var playerLooper: AVPlayerLooper?
    @State private var videoOpacity = 0.0

    var body: some View {
        ZStack {
            // Video player background
            if let player = player {
                VideoPlayer(player: player)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(videoOpacity)
            }

            // SVG image overlay
            Image("NVRSE")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .scaleEffect(0.5)
        }
        .onAppear {
            setupVideoPlayer()
            withAnimation(.easeOut(duration: 1.0)) {
                self.isActive = true
                self.videoOpacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    self.videoOpacity = 0.0
                    self.showSplash = false
                }
            }
        }
    }

    private func setupVideoPlayer() {
        guard let asset = NSDataAsset(name: "HoudiniFLip_Exploration.Redshift_ROP2_1") else {
            print("Could not load video asset.")
            return
        }

        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cacheDirectory.appendingPathComponent("splash_video.mp4")

        do {
            try asset.data.write(to: fileURL)
            let playerItem = AVPlayerItem(url: fileURL)
            self.player = AVQueuePlayer(playerItem: playerItem)
            self.player?.isMuted = true
            self.playerLooper = AVPlayerLooper(player: self.player!, templateItem: playerItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.player?.play()
            }
        } catch {
            print("Could not write video data to temporary file: \(error)")
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(showSplash: .constant(true))
    }
}