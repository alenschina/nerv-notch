import XCTest
@testable import NervNotchProApp

final class NotchViewModelTests: XCTestCase {
    func testViewModelUpdatesDecisionFromSnapshot() async {
        let viewModel = await NotchViewModel(
            settings: AppSettings(),
            decisionEngine: MagiDecisionEngine()
        )

        let snapshot = SystemSnapshot(
            sampledAt: Date(timeIntervalSince1970: 1),
            cpu: CPUSample(usageRatio: 0.8, coreCount: 10, userRatio: 0.6, systemRatio: 0.2, idleRatio: 0.2),
            memory: MemorySample(totalBytes: 1000, usedBytes: 400, availableBytes: 600, compressedBytes: 0),
            network: NetworkRate(downBytesPerSecond: 1024, upBytesPerSecond: 2048, activeInterfaceCount: 1),
            disk: DiskSpaceSample(totalBytes: 1000, usedBytes: 625, availableBytes: 375),
            diskIO: DiskIORate(readBytesPerSecond: 512, writeBytesPerSecond: 1_024),
            swap: SwapUsageSample(totalBytes: 1000, usedBytes: 125, availableBytes: 875),
            battery: BatterySample(chargeRatio: 0.71, isCharging: false)
        )

        await viewModel.apply(snapshot)

        let magiState = await viewModel.magiState
        XCTAssertEqual(magiState.cpu.level, .highLoad)
        XCTAssertEqual(magiState.diskUsageRatio, 0.625)
        XCTAssertEqual(magiState.diskIORateText, "R 0 KB/s  W 1 KB/s")
        XCTAssertEqual(magiState.swapUsageRatio, 0.125)
        XCTAssertEqual(magiState.batteryPercentageText, "71%")
        XCTAssertEqual(magiState.judgement.level, .elevatedAlert)
    }

    func testViewModelPublishesInteractionStateTransitions() async {
        let viewModel = await NotchViewModel(
            settings: AppSettings(),
            decisionEngine: MagiDecisionEngine()
        )

        await viewModel.handleInteraction(.notchClicked, at: 10)
        var interactionState = await viewModel.interactionState
        XCTAssertEqual(interactionState, .opened)

        await viewModel.handleInteraction(.outsideClicked, at: 11)
        interactionState = await viewModel.interactionState
        XCTAssertEqual(interactionState, .closed)
    }
}
