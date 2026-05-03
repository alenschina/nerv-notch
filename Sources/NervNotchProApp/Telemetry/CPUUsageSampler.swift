import Darwin
import Foundation

final class CPUUsageSampler {
    private var previousTicks: CPUTicks?

    func sample() -> CPUSample? {
        guard let ticks = readTicks() else { return nil }

        defer {
            previousTicks = ticks
        }

        guard let previousTicks else {
            return CPUSample(
                usageRatio: 0,
                coreCount: ProcessInfo.processInfo.processorCount,
                userRatio: 0,
                systemRatio: 0,
                idleRatio: 1
            )
        }

        let totalDelta = ticks.total >= previousTicks.total ? ticks.total - previousTicks.total : 0
        guard totalDelta > 0 else {
            return CPUSample(
                usageRatio: 0,
                coreCount: ProcessInfo.processInfo.processorCount,
                userRatio: 0,
                systemRatio: 0,
                idleRatio: 1
            )
        }

        let userDelta = ticks.user >= previousTicks.user ? ticks.user - previousTicks.user : 0
        let systemDelta = ticks.system >= previousTicks.system ? ticks.system - previousTicks.system : 0
        let idleDelta = ticks.idle >= previousTicks.idle ? ticks.idle - previousTicks.idle : 0
        let usageRatio = TelemetryCalculations.cpuUsage(previous: previousTicks, current: ticks)

        return CPUSample(
            usageRatio: usageRatio,
            coreCount: ProcessInfo.processInfo.processorCount,
            userRatio: Double(userDelta) / Double(totalDelta),
            systemRatio: Double(systemDelta) / Double(totalDelta),
            idleRatio: Double(idleDelta) / Double(totalDelta)
        )
    }

    private func readTicks() -> CPUTicks? {
        var processorCount: natural_t = 0
        var processorInfo: processor_info_array_t?
        var processorInfoCount: mach_msg_type_number_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &processorCount,
            &processorInfo,
            &processorInfoCount
        )

        guard result == KERN_SUCCESS, let processorInfo else { return nil }
        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(UInt(bitPattern: processorInfo)),
                vm_size_t(processorInfoCount) * vm_size_t(MemoryLayout<integer_t>.stride)
            )
        }

        var user: UInt64 = 0
        var system: UInt64 = 0
        var idle: UInt64 = 0
        var nice: UInt64 = 0

        for cpuIndex in 0..<Int(processorCount) {
            let baseIndex = cpuIndex * Int(CPU_STATE_MAX)
            user += UInt64(max(0, processorInfo[baseIndex + Int(CPU_STATE_USER)]))
            system += UInt64(max(0, processorInfo[baseIndex + Int(CPU_STATE_SYSTEM)]))
            idle += UInt64(max(0, processorInfo[baseIndex + Int(CPU_STATE_IDLE)]))
            nice += UInt64(max(0, processorInfo[baseIndex + Int(CPU_STATE_NICE)]))
        }

        return CPUTicks(user: user, system: system, idle: idle, nice: nice)
    }
}
