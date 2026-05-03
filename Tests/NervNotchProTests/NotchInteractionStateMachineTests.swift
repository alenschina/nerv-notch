import XCTest
@testable import NervNotchProApp

final class NotchInteractionStateMachineTests: XCTestCase {
    func testClickNotchOpensImmediately() {
        var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
        machine.handle(.notchClicked, at: 10)
        XCTAssertEqual(machine.state, .opened)
    }

    func testHoverRequiresFullDelayBeforeOpening() {
        var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
        machine.handle(.mouseEnteredNotch, at: 10)
        machine.handle(.timerTick, at: 11.9)
        XCTAssertEqual(machine.state, .hoverArming(startedAt: 10))
        machine.handle(.timerTick, at: 12.0)
        XCTAssertEqual(machine.state, .opened)
    }

    func testLeavingNotchBeforeDelayCancelsHover() {
        var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
        machine.handle(.mouseEnteredNotch, at: 10)
        machine.handle(.mouseExitedNotch, at: 10.5)
        XCTAssertEqual(machine.state, .closed)
    }

    func testClickOutsideOpenedPanelClosesImmediately() {
        var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
        machine.handle(.notchClicked, at: 10)
        machine.handle(.outsideClicked, at: 10.1)
        XCTAssertEqual(machine.state, .closed)
    }

    func testLeavingPanelClosesAfterGracePeriod() {
        var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
        machine.handle(.notchClicked, at: 10)
        machine.handle(.mouseExitedPanel, at: 11)
        XCTAssertEqual(machine.state, .closing(startedAt: 11))
        machine.handle(.timerTick, at: 11.19)
        XCTAssertEqual(machine.state, .closing(startedAt: 11))
        machine.handle(.timerTick, at: 11.2)
        XCTAssertEqual(machine.state, .closed)
    }

    func testReenteringPanelCancelsClosing() {
        var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
        machine.handle(.notchClicked, at: 10)
        machine.handle(.mouseExitedPanel, at: 11)
        machine.handle(.mouseEnteredPanel, at: 11.1)
        XCTAssertEqual(machine.state, .opened)
    }
}
