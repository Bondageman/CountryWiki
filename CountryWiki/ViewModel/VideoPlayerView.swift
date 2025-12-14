import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss
    
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if let player = player {
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
            }
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .padding()
                    .padding(.top, 40)
            }
        }
        .onAppear {
            if player == nil {
                player = AVPlayer(url: url)
            }
            player?.play()
        }
        .onDisappear {
            player?.pause()
        }
    }
}

