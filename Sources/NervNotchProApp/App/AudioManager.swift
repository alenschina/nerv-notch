import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioManager {
    static let shared = AudioManager()

    private var player: AVAudioPlayer?
    private var cancellable: AnyCancellable?

    @Published var isMuted = false {
        didSet { player?.volume = isMuted ? 0 : 0.35 }
    }

    private init() {}

    func attach(to viewModel: NotchViewModel) {
        cancellable = viewModel.$interactionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .opened:
                    self?.play()
                case .closed:
                    self?.stop()
                case .hoverArming, .closing:
                    break
                }
            }
    }

    private func play() {
        guard player == nil, let url = Bundle.module.url(forResource: "ambient", withExtension: "m4a") else { return }

        player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1
        player?.volume = isMuted ? 0 : 0.35
        player?.play()
    }

    private func stop() {
        player?.stop()
        player = nil
    }
}
