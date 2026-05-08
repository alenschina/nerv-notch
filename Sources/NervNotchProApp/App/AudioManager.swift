import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioManager {
    static let shared = AudioManager()

    private nonisolated(unsafe) var player: AVAudioPlayer?
    private nonisolated(unsafe) var fadeTimer: Timer?
    private var cancellable: AnyCancellable?
    var autoPlayAudio = true
    private let normalVolume: Float = 0.35

    @Published var isMuted = false {
        didSet { player?.volume = isMuted ? 0 : normalVolume }
    }

    private init() {}

    func attach(to viewModel: NotchViewModel) {
        cancellable = viewModel.$interactionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .opened:
                    if self?.autoPlayAudio == true {
                        self?.play()
                    }
                case .closing:
                    self?.startFadeOut()
                case .closed:
                    self?.stop()
                case .hoverArming:
                    break
                }
            }
    }

    private func play() {
        fadeTimer?.invalidate()
        fadeTimer = nil

        guard player == nil, let url = Bundle.module.url(forResource: "ambient", withExtension: "m4a") else {
            player?.volume = isMuted ? 0 : normalVolume
            return
        }

        player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1
        player?.volume = isMuted ? 0 : normalVolume
        player?.play()
    }

    private func startFadeOut() {
        guard player != nil, fadeTimer == nil else { return }

        fadeTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self, let player = self.player else {
                timer.invalidate()
                return
            }

            let newVolume = player.volume - 0.04
            if newVolume <= 0 {
                player.volume = 0
                timer.invalidate()
                self.fadeTimer = nil
            } else {
                player.volume = newVolume
            }
        }
    }

    private func stop() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        player?.stop()
        player = nil
    }
}
