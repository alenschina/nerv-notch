import Foundation

final class TelemetrySampler {
    private let cpuSampler: CPUUsageSampler
    private let memorySampler: MemoryUsageSampler
    private let networkSampler: NetworkUsageSampler

    init(
        cpuSampler: CPUUsageSampler = CPUUsageSampler(),
        memorySampler: MemoryUsageSampler = MemoryUsageSampler(),
        networkSampler: NetworkUsageSampler = NetworkUsageSampler()
    ) {
        self.cpuSampler = cpuSampler
        self.memorySampler = memorySampler
        self.networkSampler = networkSampler
    }

    func sample() -> SystemSnapshot {
        let date = Date()
        return SystemSnapshot(
            sampledAt: date,
            cpu: cpuSampler.sample(),
            memory: memorySampler.sample(),
            network: networkSampler.sample(at: date)
        )
    }
}
