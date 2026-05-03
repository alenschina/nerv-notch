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
            network: NetworkRate(downBytesPerSecond: 1024, upBytesPerSecond: 2048, activeInterfaceCount: 1)
        )

        await viewModel.apply(snapshot)

        let magiState = await viewModel.magiState
        XCTAssertEqual(magiState.cpu.level, .highLoad)
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
