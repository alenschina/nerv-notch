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
        guard let activeInterfaceNames = readActiveInterfaceNames(),
              let counters = readInterfaceCounters(for: activeInterfaceNames)
        else {
            return nil
        }

        return (
            counters: counters,
            activeInterfaceCount: activeInterfaceNames.count
        )
    }

    private func readActiveInterfaceNames() -> Set<String>? {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaceAddresses) == 0, let interfaceAddresses else { return nil }
        defer {
            freeifaddrs(interfaceAddresses)
        }

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
            guard shouldSampleInterface(named: name) else {
                continue
            }

            activeInterfaceNames.insert(name)
        }

        return activeInterfaceNames
    }

    private func readInterfaceCounters(for activeInterfaceNames: Set<String>) -> NetworkCounters? {
        var managementInformationBase = [CTL_NET, PF_ROUTE, 0, 0, NET_RT_IFLIST2, 0]
        var byteCount = 0

        guard sysctl(&managementInformationBase, u_int(managementInformationBase.count), nil, &byteCount, nil, 0) == 0,
              byteCount > 0
        else {
            return nil
        }

        let buffer = UnsafeMutableRawPointer.allocate(
            byteCount: byteCount,
            alignment: MemoryLayout<if_msghdr2>.alignment
        )
        defer {
            buffer.deallocate()
        }

        guard sysctl(&managementInformationBase, u_int(managementInformationBase.count), buffer, &byteCount, nil, 0) == 0 else {
            return nil
        }

        var receivedBytes: UInt64 = 0
        var sentBytes: UInt64 = 0
        var offset = 0

        while offset + MemoryLayout<if_msghdr2>.stride <= byteCount {
            let message = buffer.advanced(by: offset).loadUnaligned(as: if_msghdr2.self)
            let messageLength = Int(message.ifm_msglen)

            guard messageLength > 0, offset + messageLength <= byteCount else {
                return nil
            }

            if Int32(message.ifm_type) == RTM_IFINFO2,
               let name = interfaceName(for: UInt32(message.ifm_index)),
               activeInterfaceNames.contains(name) {
                receivedBytes += UInt64(message.ifm_data.ifi_ibytes)
                sentBytes += UInt64(message.ifm_data.ifi_obytes)
            }

            offset += messageLength
        }

        return NetworkCounters(receivedBytes: receivedBytes, sentBytes: sentBytes)
    }

    private func interfaceName(for index: UInt32) -> String? {
        var nameBuffer = [CChar](repeating: 0, count: Int(IF_NAMESIZE))
        guard if_indextoname(index, &nameBuffer) != nil else { return nil }
        return String(cString: nameBuffer)
    }

    private func shouldSampleInterface(named name: String) -> Bool {
        name.hasPrefix("en")
            || name.hasPrefix("bridge")
            || name.hasPrefix("utun")
            || name.hasPrefix("awdl")
    }
}
