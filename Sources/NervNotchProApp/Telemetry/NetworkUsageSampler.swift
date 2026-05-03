import Darwin
import Foundation

final class NetworkUsageSampler {
    private var previousCounters: NetworkCounters?
    private var previousSampledAt: Date?

    func sample(at date: Date = Date()) -> NetworkRate? {
        guard let current = readCounters() else { return nil }

        defer {
            previousCounters = current.counters
            previousSampledAt = date
        }

        guard let previousCounters, let previousSampledAt else {
            return NetworkRate(
                downBytesPerSecond: 0,
                upBytesPerSecond: 0,
                activeInterfaceCount: current.activeInterfaceCount
            )
        }

        let interval = date.timeIntervalSince(previousSampledAt)
        let rate = TelemetryCalculations.networkRate(
            previous: previousCounters,
            current: current.counters,
            interval: interval
        )

        return NetworkRate(
            downBytesPerSecond: rate.downBytesPerSecond,
            upBytesPerSecond: rate.upBytesPerSecond,
            activeInterfaceCount: current.activeInterfaceCount
        )
    }

    private func readCounters() -> (counters: NetworkCounters, activeInterfaceCount: Int)? {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaceAddresses) == 0, let interfaceAddresses else { return nil }
        defer {
            freeifaddrs(interfaceAddresses)
        }

        var receivedBytes: UInt64 = 0
        var sentBytes: UInt64 = 0
        var activeInterfaceNames = Set<String>()

        var cursor: UnsafeMutablePointer<ifaddrs>? = interfaceAddresses
        while let interface = cursor?.pointee {
            defer {
                cursor = interface.ifa_next
            }

            guard let address = interface.ifa_addr, address.pointee.sa_family == UInt8(AF_LINK) else {
                continue
            }

            let flags = Int32(interface.ifa_flags)
            guard (flags & IFF_UP) != 0, (flags & IFF_LOOPBACK) == 0 else {
                continue
            }

            let name = String(cString: interface.ifa_name)
            guard shouldSampleInterface(named: name), let data = interface.ifa_data else {
                continue
            }

            let interfaceData = data.assumingMemoryBound(to: if_data.self).pointee
            receivedBytes += UInt64(interfaceData.ifi_ibytes)
            sentBytes += UInt64(interfaceData.ifi_obytes)
            activeInterfaceNames.insert(name)
        }

        return (
            counters: NetworkCounters(receivedBytes: receivedBytes, sentBytes: sentBytes),
            activeInterfaceCount: activeInterfaceNames.count
        )
    }

    private func shouldSampleInterface(named name: String) -> Bool {
        name.hasPrefix("en")
            || name.hasPrefix("bridge")
            || name.hasPrefix("utun")
            || name.hasPrefix("awdl")
    }
}
