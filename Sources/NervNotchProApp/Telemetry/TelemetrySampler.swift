import Foundation

final class TelemetrySampler {
    private let cpuSampler: CPUUsageSampler
    private let memorySampler: MemoryUsageSampler
    private let networkSampler: NetworkUsageSampler
    private let diskSampler: DiskSpaceSampler
    private let diskIOSampler: DiskIOSampler
    private let swapSampler: SwapUsageSampler
    private let batterySampler: BatterySampler

    init(
        cpuSampler: CPUUsageSampler = CPUUsageSampler(),
        memorySampler: MemoryUsageSampler = MemoryUsageSampler(),
        networkSampler: NetworkUsageSampler = NetworkUsageSampler(),
        diskSampler: DiskSpaceSampler = DiskSpaceSampler(),
        diskIOSampler: DiskIOSampler = DiskIOSampler(),
        swapSampler: SwapUsageSampler = SwapUsageSampler(),
        batterySampler: BatterySampler = BatterySampler()
    ) {
        self.cpuSampler = cpuSampler
        self.memorySampler = memorySampler
        self.networkSampler = networkSampler
        self.diskSampler = diskSampler
        self.diskIOSampler = diskIOSampler
        self.swapSampler = swapSampler
        self.batterySampler = batterySampler
    }

    func sample() -> SystemSnapshot {
        let date = Date()
        return SystemSnapshot(
            sampledAt: date,
            cpu: cpuSampler.sample(),
            memory: memorySampler.sample(),
            network: networkSampler.sample(at: date),
            disk: diskSampler.sample(),
            diskIO: diskIOSampler.sample(at: date),
            swap: swapSampler.sample(),
            battery: batterySampler.sample()
        )
    }
}
