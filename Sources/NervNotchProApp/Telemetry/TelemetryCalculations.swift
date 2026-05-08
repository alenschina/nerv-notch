import Foundation

enum TelemetryCalculations {
    static func cpuUsage(previous: CPUTicks, current: CPUTicks) -> Double {
        let totalDelta = current.total.saturatingSubtract(previous.total)
        guard totalDelta > 0 else { return 0 }

        let idleDelta = current.idle.saturatingSubtract(previous.idle)
        let busyDelta = totalDelta.saturatingSubtract(idleDelta)
        return Double(busyDelta) / Double(totalDelta)
    }

    static func memoryUsageRatio(_ sample: MemorySample) -> Double {
        guard sample.totalBytes > 0 else { return 0 }
        return Double(sample.usedBytes) / Double(sample.totalBytes)
    }

    static func networkRate(previous: NetworkCounters, current: NetworkCounters, interval: TimeInterval) -> NetworkRate {
        guard interval > 0 else {
            return NetworkRate(downBytesPerSecond: 0, upBytesPerSecond: 0, activeInterfaceCount: 0)
        }

        let downDelta = current.receivedBytes >= previous.receivedBytes ? current.receivedBytes - previous.receivedBytes : 0
        let upDelta = current.sentBytes >= previous.sentBytes ? current.sentBytes - previous.sentBytes : 0

        return NetworkRate(
            downBytesPerSecond: UInt64(Double(downDelta) / interval),
            upBytesPerSecond: UInt64(Double(upDelta) / interval),
            activeInterfaceCount: 0
        )
    }

    static func diskIORate(previous: DiskIOCounters, current: DiskIOCounters, interval: TimeInterval) -> DiskIORate {
        guard interval > 0 else {
            return DiskIORate(readBytesPerSecond: 0, writeBytesPerSecond: 0)
        }

        let readDelta = current.readBytes.saturatingSubtract(previous.readBytes)
        let writeDelta = current.writtenBytes.saturatingSubtract(previous.writtenBytes)

        return DiskIORate(
            readBytesPerSecond: UInt64(Double(readDelta) / interval),
            writeBytesPerSecond: UInt64(Double(writeDelta) / interval)
        )
    }
}

private extension UInt64 {
    func saturatingSubtract(_ other: UInt64) -> UInt64 {
        self >= other ? self - other : 0
    }
}
