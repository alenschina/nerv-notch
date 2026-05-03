import Foundation

struct MagiDecisionState: Equatable, Sendable {
    let sampledAt: Date
    let cpu: MagiPanelDecision
    let memory: MagiPanelDecision
    let network: MagiPanelDecision
    let judgement: CentralDogmaJudgement
}

struct MagiPanelDecision: Equatable, Sendable {
    enum Level: Equatable, Sendable {
        case normal
        case highLoad
        case critical
        case idle
        case unavailable
    }

    let codeName: String
    let title: String
    let primaryValue: String
    let secondaryValue: String
    let level: Level
    let statusText: String
    let decisionText: String
}

struct CentralDogmaJudgement: Equatable, Sendable {
    enum Level: Equatable, Sendable {
        case synchronized
        case elevatedAlert
        case emergencyMode
        case partialSync
    }

    let level: Level
    let title: String
    let summary: String
}

struct MagiDecisionEngine: Sendable {
    func evaluate(_ snapshot: SystemSnapshot) -> MagiDecisionState {
        let cpu = evaluateCPU(snapshot.cpu)
        let memory = evaluateMemory(snapshot.memory)
        let network = evaluateNetwork(snapshot.network)
        let judgement = evaluateJudgement(panels: [cpu, memory, network])

        return MagiDecisionState(
            sampledAt: snapshot.sampledAt,
            cpu: cpu,
            memory: memory,
            network: network,
            judgement: judgement
        )
    }

    private func evaluateCPU(_ sample: CPUSample?) -> MagiPanelDecision {
        guard let sample else {
            return unavailablePanel(codeName: "MELCHIOR-01", title: "CPU LOAD")
        }

        let level: MagiPanelDecision.Level
        let statusText: String
        let decisionText: String

        if sample.usageRatio >= 0.90 {
            level = .critical
            statusText = "CRITICAL"
            decisionText = "PROCESSOR SATURATION"
        } else if sample.usageRatio >= 0.70 {
            level = .highLoad
            statusText = "HIGH LOAD"
            decisionText = "LOAD RISING"
        } else {
            level = .normal
            statusText = "NORMAL"
            decisionText = "LOAD ACCEPTABLE"
        }

        return MagiPanelDecision(
            codeName: "MELCHIOR-01",
            title: "CPU LOAD",
            primaryValue: percent(sample.usageRatio),
            secondaryValue: "\(sample.coreCount) CORES",
            level: level,
            statusText: statusText,
            decisionText: decisionText
        )
    }

    private func evaluateMemory(_ sample: MemorySample?) -> MagiPanelDecision {
        guard let sample else {
            return unavailablePanel(codeName: "BALTHASAR-02", title: "MEMORY")
        }

        let usageRatio = TelemetryCalculations.memoryUsageRatio(sample)
        let level: MagiPanelDecision.Level
        let statusText: String
        let decisionText: String

        if usageRatio >= 0.90 {
            level = .critical
            statusText = "CRITICAL"
            decisionText = "MEMORY PRESSURE CRITICAL"
        } else if usageRatio >= 0.75 {
            level = .highLoad
            statusText = "HIGH LOAD"
            decisionText = "MEMORY PRESSURE RISING"
        } else {
            level = .normal
            statusText = "NORMAL"
            decisionText = "MEMORY STABLE"
        }

        return MagiPanelDecision(
            codeName: "BALTHASAR-02",
            title: "MEMORY",
            primaryValue: percent(usageRatio),
            secondaryValue: "\(ByteFormat.megabytes(sample.availableBytes)) FREE",
            level: level,
            statusText: statusText,
            decisionText: decisionText
        )
    }

    private func evaluateNetwork(_ sample: NetworkRate?) -> MagiPanelDecision {
        guard let sample else {
            return unavailablePanel(codeName: "CASPER-03", title: "NETWORK")
        }

        if sample.activeInterfaceCount == 0 {
            return MagiPanelDecision(
                codeName: "CASPER-03",
                title: "NETWORK",
                primaryValue: "0 KB/s",
                secondaryValue: "NO ACTIVE LINK",
                level: .idle,
                statusText: "COMM LINK IDLE",
                decisionText: "COMMUNICATION STANDBY"
            )
        }

        let totalRate = sample.downBytesPerSecond + sample.upBytesPerSecond
        let level: MagiPanelDecision.Level
        let statusText: String
        let decisionText: String

        if totalRate >= 100_000_000 {
            level = .critical
            statusText = "CRITICAL"
            decisionText = "BANDWIDTH SATURATION"
        } else if totalRate >= 25_000_000 {
            level = .highLoad
            statusText = "HIGH TRAFFIC"
            decisionText = "COMM LOAD RISING"
        } else {
            level = .normal
            statusText = "ACTIVE"
            decisionText = "COMM LINK ACTIVE"
        }

        return MagiPanelDecision(
            codeName: "CASPER-03",
            title: "NETWORK",
            primaryValue: ByteFormat.rate(sample.downBytesPerSecond),
            secondaryValue: "UP \(ByteFormat.rate(sample.upBytesPerSecond))",
            level: level,
            statusText: statusText,
            decisionText: decisionText
        )
    }

    private func evaluateJudgement(panels: [MagiPanelDecision]) -> CentralDogmaJudgement {
        if panels.contains(where: { $0.level == .unavailable }) {
            return CentralDogmaJudgement(
                level: .partialSync,
                title: "PARTIAL SYNC",
                summary: "MAGI CONSENSUS DEGRADED"
            )
        }

        if panels.contains(where: { $0.level == .critical }) {
            return CentralDogmaJudgement(
                level: .emergencyMode,
                title: "EMERGENCY MODE",
                summary: "CENTRAL DOGMA ALERT"
            )
        }

        if panels.contains(where: { $0.level == .highLoad }) {
            return CentralDogmaJudgement(
                level: .elevatedAlert,
                title: "ELEVATED ALERT",
                summary: "SYSTEM LOAD INCREASING"
            )
        }

        return CentralDogmaJudgement(
            level: .synchronized,
            title: "SYNCHRONIZED",
            summary: "MAGI SYSTEMS NOMINAL"
        )
    }

    private func unavailablePanel(codeName: String, title: String) -> MagiPanelDecision {
        MagiPanelDecision(
            codeName: codeName,
            title: title,
            primaryValue: "--",
            secondaryValue: "NO SIGNAL",
            level: .unavailable,
            statusText: "DATA UNAVAILABLE",
            decisionText: "SIGNAL LOST"
        )
    }

    private func percent(_ ratio: Double) -> String {
        "\(Int((ratio * 100).rounded()))%"
    }
}

enum ByteFormat {
    static func megabytes(_ bytes: UInt64) -> String {
        "\(bytes / 1_048_576) MB"
    }

    static func rate(_ bytesPerSecond: UInt64) -> String {
        if bytesPerSecond >= 1_048_576 {
            return "\(bytesPerSecond / 1_048_576) MB/s"
        }
        return "\(bytesPerSecond / 1024) KB/s"
    }
}
