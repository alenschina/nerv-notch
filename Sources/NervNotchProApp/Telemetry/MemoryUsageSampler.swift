import Darwin
import Foundation

struct MemoryUsageSampler {
    func sample() -> MemorySample? {
        var pageSize: vm_size_t = 0
        guard host_page_size(mach_host_self(), &pageSize) == KERN_SUCCESS else { return nil }

        var statistics = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)
        let result = withUnsafeMutablePointer(to: &statistics) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { reboundPointer in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, reboundPointer, &count)
            }
        }

        guard result == KERN_SUCCESS else { return nil }

        let pageBytes = UInt64(pageSize)
        let totalBytes = ProcessInfo.processInfo.physicalMemory
        let availableBytes = UInt64(statistics.free_count + statistics.inactive_count) * pageBytes
        let compressedBytes = UInt64(statistics.compressor_page_count) * pageBytes
        let usedBytes = totalBytes >= availableBytes ? totalBytes - availableBytes : 0

        return MemorySample(
            totalBytes: totalBytes,
            usedBytes: usedBytes,
            availableBytes: availableBytes,
            compressedBytes: compressedBytes
        )
    }
}
