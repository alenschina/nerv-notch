import Foundation
import IOKit

final class DiskIOSampler {
    private var previousCounters: DiskIOCounters?
    private var previousDate: Date?

    func sample(at date: Date = Date()) -> DiskIORate? {
        guard let counters = readCounters() else {
            return nil
        }

        defer {
            previousCounters = counters
            previousDate = date
        }

        guard let previousCounters, let previousDate else {
            return DiskIORate(readBytesPerSecond: 0, writeBytesPerSecond: 0)
        }

        return TelemetryCalculations.diskIORate(
            previous: previousCounters,
            current: counters,
            interval: date.timeIntervalSince(previousDate)
        )
    }

    private func readCounters() -> DiskIOCounters? {
        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IOBlockStorageDriver"),
            &iterator
        )

        guard result == KERN_SUCCESS else {
            return nil
        }
        defer { IOObjectRelease(iterator) }

        var readBytes: UInt64 = 0
        var writtenBytes: UInt64 = 0
        var service = IOIteratorNext(iterator)

        while service != 0 {
            defer { service = IOIteratorNext(iterator) }
            defer { IOObjectRelease(service) }

            guard let property = IORegistryEntryCreateCFProperty(
                service,
                "Statistics" as CFString,
                kCFAllocatorDefault,
                0
            )?.takeRetainedValue() as? [String: Any] else {
                continue
            }

            readBytes += uint64Value(property["Bytes (Read)"])
            writtenBytes += uint64Value(property["Bytes (Write)"])
        }

        return DiskIOCounters(readBytes: readBytes, writtenBytes: writtenBytes)
    }

    private func uint64Value(_ value: Any?) -> UInt64 {
        guard let number = value as? NSNumber else {
            return 0
        }
        return number.uint64Value
    }
}
