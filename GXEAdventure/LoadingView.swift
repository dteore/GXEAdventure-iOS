//
//  LoadingView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//
import SwiftUI
import AVKit

struct LoadingView: View {
    @Binding var isLoading: Bool
    let cancelAction: () -> Void
    @State private var showAbandonAlert: Bool = false
    @State private var player: AVQueuePlayer?
    @State private var playerLooper: AVPlayerLooper?
    
    var body: some View {
        ZStack {
            // Black background always visible
            Color.black
                .ignoresSafeArea()
            
            // Video player background - shows immediately when available
            if let player = player {
                VideoPlayer(player: player)
                    .disabled(true)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            
            // UI Elements - Always visible immediately
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        showAbandonAlert = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    .padding(.leading, 10)
                    .padding(.top, 15)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
                
                Text("Creating adventure...")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.white)
                    .shadow(color: .black, radius: 3, x: 0, y: 2)
                    .padding(.top, 40)
                Text("We're crafting your personalized adventure now.")
                    .font(.body)
                    .foregroundStyle(Color.white)
                    .shadow(color: .black, radius: 2, x: 0, y: 1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.vertical, 50)
        }
        .onAppear {
            setupVideoPlayer()
        }
        .onDisappear {
            cleanupVideoPlayer()
        }
        .overlay(
            Group {
                if showAbandonAlert {
                    AbandonAdventureConfirmationView(
                        onAbandon: {
                            cancelAction()
                            isLoading = false
                            showAbandonAlert = false
                        },
                        onKeepPlaying: {
                            showAbandonAlert = false
                        }
                    )
                }
            }
        )
    }
    
    private func setupVideoPlayer() {
        print("=== LOADING VIDEO SETUP (Immediate Display) ===")
        guard let asset = NSDataAsset(name: "GXE_loading") else {
            print("❌ Could not load video asset: GXE_loading")
            return
        }
        print("✅ GXE_loading video asset loaded successfully")

        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cacheDirectory.appendingPathComponent("loading_video.mp4")

        do {
            // Remove existing file if it exists
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
                print("🗑️ Removed existing loading video file")
            }
            
            try asset.data.write(to: fileURL)
            print("✅ Loading video written to: \(fileURL)")
            print("📊 Video file size: \(asset.data.count) bytes")
            
            let playerItem = AVPlayerItem(url: fileURL)
            self.player = AVQueuePlayer(playerItem: playerItem)
            self.player?.isMuted = true
            self.playerLooper = AVPlayerLooper(player: self.player!, templateItem: playerItem)
            
            // Start playing immediately - no waiting
            self.player?.play()
            print("▶️ Loading video started immediately")
            
        } catch {
            print("❌ Could not write loading video data to temporary file: \(error)")
        }
    }
    
    private func cleanupVideoPlayer() {
        print("🧹 Cleaning up loading video player")
        player?.pause()
        player = nil
        playerLooper = nil
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(isLoading: .constant(true), cancelAction: {})
    }
}
