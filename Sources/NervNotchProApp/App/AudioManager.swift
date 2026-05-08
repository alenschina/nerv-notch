import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioManager {
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var cancellable: AnyCancellable?
    private var isPlaying = false

    // Continuous phase across render-block calls so there are no discontinuities between buffers.
    // Read/written on the audio render thread; marked unsafe to bypass @MainActor isolation.
    private nonisolated(unsafe) var phase: Float = 0

    private let droneHz: Float = 55.0
    private let fifthHz: Float = 82.41
    private let octaveHz: Float = 110.0

    func attach(to viewModel: NotchViewModel) {
        cancellable = viewModel.$interactionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .opened:
                    self?.start()
                case .closed:
                    self?.stop()
                case .hoverArming, .closing:
                    break
                }
            }
    }

    private func start() {
        guard !isPlaying else { return }
        isPlaying = true

        let sampleRate = engine.mainMixerNode.outputFormat(forBus: 0).sampleRate
        let invSampleRate = Float(1.0 / sampleRate)

        let sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }

            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            guard let buffer = ablPointer.first, let data = buffer.mData else { return noErr }
            let ptr = data.assumingMemoryBound(to: Float.self)

            let droneHz = self.droneHz
            let fifthHz = self.fifthHz
            let octaveHz = self.octaveHz
            var runningPhase = self.phase

            for frame in 0..<Int(frameCount) {
                // Breathing LFO (slow amplitude modulation)
                let lfo = 0.75 + 0.25 * sin(2 * .pi * 0.1 * runningPhase * invSampleRate)

                let drone = sin(2 * .pi * droneHz * runningPhase * invSampleRate)
                let fifth = sin(2 * .pi * fifthHz * runningPhase * invSampleRate) * 0.25
                let octave = sin(2 * .pi * octaveHz * runningPhase * invSampleRate) * 0.15

                let sample = (drone + fifth + octave) * lfo * 0.07
                ptr[frame * 2] = sample
                ptr[frame * 2 + 1] = sample

                runningPhase += 1
            }

            self.phase = runningPhase
            return noErr
        }

        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: nil)

        do {
            try engine.start()
        } catch {
            isPlaying = false
            return
        }

        self.sourceNode = sourceNode
    }

    private func stop() {
        guard isPlaying else { return }
        isPlaying = false

        engine.stop()
        if let sourceNode {
            engine.detach(sourceNode)
        }
        sourceNode = nil
        phase = 0
    }
}
