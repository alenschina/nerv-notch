import Foundation

struct CPUTicks: Equatable, Sendable {
    let user: UInt64
    let system: UInt64
    let idle: UInt64
    let nice: UInt64

    var total: UInt64 {
        user + system + idle + nice
    }
}

struct CPUSample: Equatable, Sendable {
    let usageRatio: Double
    let coreCount: Int
    let userRatio: Double
    let systemRatio: Double
    let idleRatio: Double
}

struct MemorySample: Equatable, Sendable {
    let totalBytes: UInt64
    let usedBytes: UInt64
    let availableBytes: UInt64
    let compressedBytes: UInt64
}

struct NetworkCounters: Equatable, Sendable {
    let receivedBytes: UInt64
    let sentBytes: UInt64
}

struct NetworkRate: Equatable, Sendable {
    let downBytesPerSecond: UInt64
    let upBytesPerSecond: UInt64
    let activeInterfaceCount: Int
}

struct DiskSpaceSample: Equatable, Sendable {
    let totalBytes: UInt64
    let usedBytes: UInt64
    let availableBytes: UInt64
}

struct DiskIOCounters: Equatable, Sendable {
    let readBytes: UInt64
    let writtenBytes: UInt64
}

struct DiskIORate: Equatable, Sendable {
    let readBytesPerSecond: UInt64
    let writeBytesPerSecond: UInt64
}

struct SystemSnapshot: Equatable, Sendable {
    let sampledAt: Date
    let cpu: CPUSample?
    let memory: MemorySample?
    let network: NetworkRate?
    let disk: DiskSpaceSample?
    let diskIO: DiskIORate?
}
