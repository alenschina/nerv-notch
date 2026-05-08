import Darwin
import Foundation

struct SwapUsageSampler {
    func sample() -> SwapUsageSample? {
        var usage = xsw_usage()
        var size = MemoryLayout<xsw_usage>.stride
        let result = sysctlbyname("vm.swapusage", &usage, &size, nil, 0)

        guard result == 0 else {
            return nil
        }

        return SwapUsageSample(
            totalBytes: usage.xsu_total,
            usedBytes: usage.xsu_used,
            availableBytes: usage.xsu_avail
        )
    }
}
