import Foundation

struct DiskSpaceSampler {
    private let volumeURL: URL

    init(volumeURL: URL = URL(fileURLWithPath: "/")) {
        self.volumeURL = volumeURL
    }

    func sample() -> DiskSpaceSample? {
        guard let values = try? volumeURL.resourceValues(forKeys: [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey,
            .volumeAvailableCapacityKey
        ]) else {
            return nil
        }

        guard let totalCapacity = values.volumeTotalCapacity, totalCapacity > 0 else {
            return nil
        }

        let totalBytes = UInt64(totalCapacity)
        let availableCapacity = values.volumeAvailableCapacityForImportantUsage
            ?? values.volumeAvailableCapacity.map(Int64.init)
            ?? 0
        let availableBytes = UInt64(max(0, min(availableCapacity, Int64(totalBytes))))
        let usedBytes = totalBytes - availableBytes

        return DiskSpaceSample(
            totalBytes: totalBytes,
            usedBytes: usedBytes,
            availableBytes: availableBytes
        )
    }
}
