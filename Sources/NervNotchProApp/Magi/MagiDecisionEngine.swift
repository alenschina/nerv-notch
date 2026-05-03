import Foundation

struct MagiDecisionState: Equatable, Sendable {
    let cpu: MagiPanelDecision
    let memory: MagiPanelDecision
    let network: MagiPanelDecision
    let judgement: CentralDogmaJudgement
}

struct MagiPanelDecision: Equatable, Sendable {
    enum Level: Equatable, Sendable {
        case unavailable
        case idle
        case normal
        case high
        case critical
    }

    let level: Level
    let title: String
    let detail: String
    let value: String
}

struct CentralDogmaJudgement: Equatable, Sendable {
    enum Level: Equatable, Sendable {
        case synchronized
        case partialSync
        case elevatedAlert
        case emergencyMode
    }

    let level: Level
    let title: String
    let detail: String
}

struct MagiDecisionEngine: Sendable {
    func evaluate(_ snapshot: SystemSnapshot) -> MagiDecisionState {
        let cpu = evaluateCPU(snapshot.cpu)
        let memory = evaluateMemory(snapshot.memory)
        let network = evaluateNetwork(snapshot.network)
        let judgement = evaluateJudgement(panels: [cpu, memory, network])

        return MagiDecisionState(
            cpu: cpu,
            memory: memory,
            network: network,
            judgement: judgement
        )
    }

    private func evaluateCPU(_ sample: CPUSample?) -> MagiPanelDecision {
        guard let sample else {
            return MagiPanelDecision(
                level: .unavailable,
                title: "CPU",
                detail: "No processor telemetry available",
                value: "Unavailable"
            )
        }

        let level: MagiPanelDecision.Level
        if sample.usageRatio >= 0.90 {
            level = .critical
        } else if sample.usageRatio >= 0.70 {
            level = .high
        } else {
            level = .normal
        }

        return MagiPanelDecision(
            level: level,
            title: "CPU",
            detail: "\(sample.coreCount) cores sampled",
            value: Self.percent(sample.usageRatio)
        )
    }

    private func evaluateMemory(_ sample: MemorySample?) -> MagiPanelDecision {
        guard let sample else {
            return MagiPanelDecision(
                level: .unavailable,
                title: "Memory",
                detail: "No memory telemetry available",
                value: "Unavailable"
            )
        }

        let usageRatio = TelemetryCalculations.memoryUsageRatio(sample)
        let level: MagiPanelDecision.Level
        if usageRatio >= 0.90 {
            level = .critical
        } else if usageRatio >= 0.75 {
            level = .high
        } else {
            level = .normal
        }

        return MagiPanelDecision(
            level: level,
            title: "Memory",
            detail: "\(ByteFormat.string(from: sample.availableBytes)) available",
            value: Self.percent(usageRatio)
        )
    }

    private func evaluateNetwork(_ sample: NetworkRate?) -> MagiPanelDecision {
        guard let sample else {
            return MagiPanelDecision(
                level: .unavailable,
                title: "Network",
                detail: "No network telemetry available",
                value: "Unavailable"
            )
        }

        let totalRate = sample.downBytesPerSecond + sample.upBytesPerSecond
        let level: MagiPanelDecision.Level
        if sample.activeInterfaceCount == 0 {
            level = .idle
        } else if totalRate >= 100_000_000 {
            level = .critical
        } else if totalRate >= 25_000_000 {
            level = .high
        } else {
            level = .normal
        }

        return MagiPanelDecision(
            level: level,
            title: "Network",
            detail: "\(sample.activeInterfaceCount) active interfaces",
            value: "\(ByteFormat.string(from: totalRate))/s"
        )
    }

    private func evaluateJudgement(panels: [MagiPanelDecision]) -> CentralDogmaJudgement {
        let level: CentralDogmaJudgement.Level
        if panels.contains(where: { $0.level == .unavailable }) {
            level = .partialSync
        } else if panels.contains(where: { $0.level == .critical }) {
            level = .emergencyMode
        } else if panels.contains(where: { $0.level == .high }) {
            level = .elevatedAlert
        } else {
            level = .synchronized
        }

        return CentralDogmaJudgement(
            level: level,
            title: title(for: level),
            detail: detail(for: level)
        )
    }

    private func title(for level: CentralDogmaJudgement.Level) -> String {
        switch level {
        case .synchronized:
            return "Synchronized"
        case .partialSync:
            return "Partial Sync"
        case .elevatedAlert:
            return "Elevated Alert"
        case .emergencyMode:
            return "Emergency Mode"
        }
    }

    private func detail(for level: CentralDogmaJudgement.Level) -> String {
        switch level {
        case .synchronized:
            return "All MAGI panels report nominal conditions"
        case .partialSync:
            return "One or more MAGI panels lack telemetry"
        case .elevatedAlert:
            return "One or more MAGI panels report elevated load"
        case .emergencyMode:
            return "One or more MAGI panels report critical load"
        }
    }

    private static func percent(_ ratio: Double) -> String {
        "\(Int((ratio * 100).rounded()))%"
    }
}

enum ByteFormat {
    static func string(from bytes: UInt64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var value = Double(bytes)
        var unitIndex = 0

        while value >= 1_000, unitIndex < units.count - 1 {
            value /= 1_000
            unitIndex += 1
        }

        if unitIndex == 0 {
            return "\(bytes) \(units[unitIndex])"
        }

        return String(format: "%.1f %@", value, units[unitIndex])
    }
}
