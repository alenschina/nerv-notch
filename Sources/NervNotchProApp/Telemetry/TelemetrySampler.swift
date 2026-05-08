import Foundation

final class TelemetrySampler {
    private let cpuSampler: CPUUsageSampler
    private let memorySampler: MemoryUsageSampler
    private let networkSampler: NetworkUsageSampler
    private let diskSampler: DiskSpaceSampler
    private let diskIOSampler: DiskIOSampler

    init(
        cpuSampler: CPUUsageSampler = CPUUsageSampler(),
        memorySampler: MemoryUsageSampler = MemoryUsageSampler(),
        networkSampler: NetworkUsageSampler = NetworkUsageSampler(),
        diskSampler: DiskSpaceSampler = DiskSpaceSampler(),
        diskIOSampler: DiskIOSampler = DiskIOSampler()
    ) {
        self.cpuSampler = cpuSampler
        self.memorySampler = memorySampler
        self.networkSampler = networkSampler
        self.diskSampler = diskSampler
        self.diskIOSampler = diskIOSampler
    }

    func sample() -> SystemSnapshot {
        let date = Date()
        return SystemSnapshot(
            sampledAt: date,
            cpu: cpuSampler.sample(),
            memory: memorySampler.sample(),
            network: networkSampler.sample(at: date),
            disk: diskSampler.sample(),
            diskIO: diskIOSampler.sample(at: date)
        )
    }
}
