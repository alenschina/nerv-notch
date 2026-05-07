import AppKit
import XCTest
@testable import NervNotchProApp

final class NotchIslandChromeTests: XCTestCase {
    func testCompactChromeUsesPhysicalNotchLikeCornerInsets() {
        let metrics = NotchIslandChromeMetrics(isExpanded: false)

        XCTAssertEqual(metrics.topCornerRadius, 6)
        XCTAssertEqual(metrics.bottomCornerRadius, 14)
    }

    func testExpandedChromeUsesReferenceCornerInsets() {
        let metrics = NotchIslandChromeMetrics(isExpanded: true)

        XCTAssertEqual(metrics.topCornerRadius, 19)
        XCTAssertEqual(metrics.bottomCornerRadius, 24)
    }

    func testChromeShapeAnimatesCornerRadii() {
        var shape = NotchIslandShape(metrics: NotchIslandChromeMetrics(isExpanded: false))

        shape.animatableData = .init(19, 24)

        XCTAssertEqual(shape.metrics.topCornerRadius, 19)
        XCTAssertEqual(shape.metrics.bottomCornerRadius, 24)
    }

    func testChromeDoesNotDrawOuterBorder() {
        let style = NotchIslandChromeStyle()

        XCTAssertFalse(style.drawsOuterBorder)
    }

    func testChromeDoesNotDrawTopHighlight() {
        let style = NotchIslandChromeStyle()

        XCTAssertFalse(style.drawsTopHighlight)
    }

    func testLayoutUsesPhysicalNotchHeightForCompactIsland() {
        let layout = NotchIslandLayout(compactNotchSize: CGSize(width: 210, height: 32))

        XCTAssertEqual(layout.compactSize.height, 32)
    }

    func testLayoutAddsSquareIconSpaceOnBothSidesOfCompactIsland() {
        let layout = NotchIslandLayout(compactNotchSize: CGSize(width: 210, height: 32))

        XCTAssertEqual(layout.compactSize.width, 274)
    }

    func testCompactIslandUsesBundledNervIconOnLeadingEdge() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let resourceFile = projectRoot
            .appendingPathComponent("Sources/NervNotchProApp/Resources/nerv-island-icon.png")
        let packageFile = projectRoot.appendingPathComponent("Package.swift")
        let sourceFile = projectRoot
            .appendingPathComponent("Sources/NervNotchProApp/UI/NervConsoleView.swift")

        let packageSource = try String(contentsOf: packageFile)
        let consoleSource = try String(contentsOf: sourceFile)

        XCTAssertTrue(FileManager.default.fileExists(atPath: resourceFile.path))
        XCTAssertTrue(packageSource.contains(#".process("Resources")"#))
        XCTAssertTrue(consoleSource.contains("nervLeadingIcon(sideLength: NervIslandIcon.dimension(forCompactHeight: layout.compactSize.height))"))
        XCTAssertTrue(consoleSource.contains("Image(nsImage: icon)"))
        XCTAssertTrue(consoleSource.contains(".padding(.leading, 14)"))
        XCTAssertNotNil(Bundle.module.url(forResource: "nerv-island-icon", withExtension: "png"))
        XCTAssertNotNil(Bundle.module.image(forResource: "nerv-island-icon"))
        XCTAssertEqual(NervIslandIcon.resourceName, "nerv-island-icon")
        XCTAssertEqual(NervIslandIcon.dimension(forCompactHeight: 32), 24)
        XCTAssertNotNil(NervIslandIcon.image)
    }

    func testExpandedConsoleShowsLeadingNervHeaderWithOrangeWarningTitle() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceFile = projectRoot
            .appendingPathComponent("Sources/NervNotchProApp/UI/NervConsoleView.swift")
        let consoleSource = try String(contentsOf: sourceFile)
        let layout = NotchIslandLayout(compactNotchSize: CGSize(width: 210, height: 32))
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertTrue(consoleSource.contains("Text(\"NERV コントロールセンター\")"))
        XCTAssertTrue(consoleSource.contains("private var expandedHeader: some View"))
        XCTAssertTrue(consoleSource.contains("foregroundStyle(NervStyle.orange)"))
        XCTAssertTrue(consoleSource.contains("nervLeadingIcon(sideLength: layout.expandedHeaderIconSize)"))
        XCTAssertTrue(consoleSource.contains(".font(.custom(layout.expandedHeaderFontName, size: layout.expandedHeaderFontSize))"))
        XCTAssertTrue(consoleSource.contains(".fontWeight(.bold)"))
        XCTAssertEqual(layout.expandedHeaderTopPadding, 11)
        XCTAssertEqual(layout.expandedHeaderLeadingPadding, metrics.leftAuxiliaryFrameStrokeLeftXInConsole)
        XCTAssertEqual(layout.expandedHeaderLeadingPadding, 69)
        XCTAssertEqual(layout.expandedHeaderSpacing, 6)
        XCTAssertEqual(layout.expandedHeaderFontSize, 15)
        XCTAssertEqual(layout.expandedHeaderIconSize, 22)
        XCTAssertEqual(layout.expandedHeaderFontName, "SourceHanSerifCN-Bold")
    }

    func testExpandedConsoleShowsTrailingSettingsButtonSymmetricWithHeaderIcon() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceFile = projectRoot
            .appendingPathComponent("Sources/NervNotchProApp/UI/NervConsoleView.swift")
        let consoleSource = try String(contentsOf: sourceFile)
        let layout = NotchIslandLayout(compactNotchSize: CGSize(width: 210, height: 32))
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertTrue(consoleSource.contains("let onOpenSettings: () -> Void"))
        XCTAssertTrue(consoleSource.contains("Button(action: onOpenSettings)"))
        XCTAssertTrue(consoleSource.contains("Image(systemName: \"gearshape\")"))
        XCTAssertTrue(consoleSource.contains("private var expandedSettingsButton: some View"))
        XCTAssertEqual(layout.expandedHeaderTrailingPadding, metrics.leftAuxiliaryFrameStrokeLeftXInConsole)
        XCTAssertEqual(layout.expandedHeaderTrailingPadding, layout.expandedHeaderLeadingPadding)
        XCTAssertEqual(layout.expandedSettingsButtonSize, layout.expandedHeaderIconSize)
    }

    func testLayoutExtendsCompactIslandWidthWhileHovering() {
        let layout = NotchIslandLayout(compactNotchSize: CGSize(width: 210, height: 32))

        XCTAssertEqual(layout.compactSize(isHovering: true).width, 290)
        XCTAssertEqual(layout.compactSize(isHovering: true).height, 32)
    }

    func testLayoutKeepsExpandedConsoleSizeIndependentFromPhysicalNotch() {
        let layout = NotchIslandLayout(compactNotchSize: CGSize(width: 210, height: 32))
        let metrics = MagiConsoleLayoutMetrics()
        let expectedHeight = metrics.consoleContentTopPadding
        + metrics.triadOuterFrameHeight
        + metrics.consoleContentBottomPadding

        XCTAssertEqual(layout.expandedSize.width, 820)
        XCTAssertEqual(layout.expandedSize.height, expectedHeight)
    }

    func testMagiConsoleLayoutKeepsTriadCenteredBetweenSymmetricInfoColumns() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.sideInfoWidth, 0)
        XCTAssertEqual(metrics.triadWidth, 368)
        XCTAssertEqual(metrics.triadOuterFrameWidth, 492)
        XCTAssertEqual(metrics.triadOuterFrameHeight, 308)
        XCTAssertEqual(metrics.triadOuterFrameHorizontalInset, 0)
        XCTAssertEqual(metrics.triadOuterFrameStrokeHorizontalInset, 38)
        XCTAssertEqual(metrics.triadOuterFrameStrokeLineWidth, 1)
        XCTAssertEqual(metrics.triadOuterFrameStrokeWidth, 416)
        XCTAssertEqual(metrics.sideAuxiliaryFrameWidth, 132)
        XCTAssertEqual(metrics.sideAuxiliaryFrameStrokeWidth, 56)
        XCTAssertEqual(metrics.triadOuterFrameBottomPadding, 4)
        XCTAssertEqual(metrics.triadWarningStripHeight, 16)
        XCTAssertEqual(
            metrics.triadWarningStripHorizontalInset,
            metrics.triadOuterFrameStrokeHorizontalInset + metrics.triadOuterFrameStrokeLineWidth
        )
        XCTAssertEqual(metrics.triadContentOffsetY, 46)
        XCTAssertEqual(metrics.trailingInfoWidth, 0)
    }

    func testMagiOuterFrameEmbedsSideInfoWhileKeepingOverallConsoleCompact() {
        let metrics = MagiConsoleLayoutMetrics()

        let previousTotalWidth: CGFloat = metrics.sideInfoWidth + metrics.columnSpacing + 332 + metrics.columnSpacing + 154
        let currentTotalWidth = metrics.triadOuterFrameWidth

        XCTAssertEqual(metrics.triadOuterFrameWidth, metrics.triadWidth + metrics.triadEmbeddedInfoReserveWidth * 2)
        XCTAssertLessThan(currentTotalWidth, previousTotalWidth)
        XCTAssertLessThan(metrics.triadOuterFrameBottomPadding, 8)
    }

    func testMagiConsoleAddsEmptyAuxiliaryFramesWithoutMovingCenterContent() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(
            metrics.triadClusterWidth,
            metrics.sideAuxiliaryFrameWidth * 2 + metrics.triadOuterFrameWidth + metrics.columnSpacing * 2
        )
        XCTAssertEqual(metrics.triadClusterWidth, 784)
        XCTAssertEqual(metrics.triadOuterFrameWidth, 492)
        XCTAssertEqual(metrics.triadLeadingEmbeddedInfoLeadingX, 80)
        XCTAssertEqual(metrics.triadTrailingEmbeddedInfoTrailingX, 470)
        XCTAssertEqual(
            metrics.sideAuxiliaryFrameWarningStripWidth,
            metrics.sideAuxiliaryFrameStrokeWidth - metrics.triadOuterFrameStrokeLineWidth * 2
        )
    }

    func testMagiConsoleDrawsWarningBackgroundStripsOutsideContentLayout() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.sideWarningBackgroundWidth, 64)
        XCTAssertEqual(metrics.sideWarningBackgroundPaintedNarrowing, 5)
        XCTAssertEqual(metrics.sideWarningBackgroundPaintedWidth, 59)
        XCTAssertEqual(metrics.sideWarningBackgroundStripeWidth, 36)
        XCTAssertEqual(metrics.sideWarningBackgroundStripeHeight, 58)
        XCTAssertGreaterThan(metrics.sideWarningBackgroundOpacity, 0)
        XCTAssertLessThan(metrics.sideWarningBackgroundOpacity, 1)
        XCTAssertEqual(metrics.triadClusterWidth, 784)
    }

    func testMagiLeftAuxiliaryFrameClearsWarningStripAndTouchesTriadWithFivePointGap() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(
            metrics.leftAuxiliaryFrameStrokeLeftXInConsole - metrics.sideWarningBackgroundWidth,
            5
        )
        XCTAssertEqual(
            metrics.triadOuterFrameStrokeLeftXInConsole - metrics.leftAuxiliaryFrameStrokeRightXInConsole,
            5
        )
    }

    func testMagiRightAuxiliaryFrameClearsWarningStripAndTouchesTriadWithFivePointGap() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(
            metrics.rightAuxiliaryFrameStrokeLeftXInConsole - metrics.triadOuterFrameStrokeRightXInConsole,
            5
        )
        XCTAssertEqual(
            metrics.consoleWidth - metrics.sideWarningBackgroundWidth - metrics.rightAuxiliaryFrameStrokeRightXInConsole,
            5
        )
    }

    func testMagiConsolePlacesFramedContentBelowPhysicalNotchAfterRemovingStatusBanners() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.consoleContentTopPadding, 46)
        XCTAssertEqual(metrics.consoleContentBottomPadding, 20)
        XCTAssertEqual(metrics.consoleFramedContentTopY, metrics.consoleContentTopPadding)
        XCTAssertEqual(metrics.consoleFramedContentBottomY, metrics.consoleContentTopPadding + metrics.triadOuterFrameHeight)
        XCTAssertLessThanOrEqual(metrics.consoleFramedContentBottomY, CGFloat(420) - metrics.consoleContentBottomPadding)
    }

    func testMagiRedFrameStrokeHugsContentWithoutMovingEmbeddedInfo() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.triadOuterFrameWidth, 492)
        XCTAssertLessThan(metrics.triadOuterFrameStrokeWidth, metrics.triadOuterFrameWidth)
        XCTAssertEqual(
            metrics.triadOuterFrameStrokeWidth,
            metrics.triadOuterFrameWidth - metrics.triadOuterFrameStrokeHorizontalInset * 2
        )
        XCTAssertEqual(metrics.triadLeadingEmbeddedInfoLeadingX, 80)
        XCTAssertEqual(metrics.triadTrailingEmbeddedInfoTrailingX, 470)
    }

    func testMagiEmbeddedSideInfoFitsInSideBlankAreas() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.triadEmbeddedInfoWidth, 118)
        XCTAssertEqual(metrics.triadEmbeddedInfoRowCount, 9)
        XCTAssertLessThanOrEqual(metrics.triadEmbeddedInfoFontSize, 8)
        XCTAssertLessThanOrEqual(metrics.triadEmbeddedInfoRowSpacing, 2)
        XCTAssertLessThan(metrics.triadLeadingEmbeddedInfoTrailingX, metrics.triadOuterFrameWidth / 2)
        XCTAssertGreaterThan(metrics.triadTrailingEmbeddedInfoLeadingX, metrics.balthasarRightEdgeInOuterFrame)
        XCTAssertEqual(metrics.triadEmbeddedLeftInfoInset, 80)
        XCTAssertEqual(metrics.triadEmbeddedRightInfoInset, 22)
        XCTAssertEqual(metrics.triadLeadingEmbeddedInfoLeadingX, metrics.triadEmbeddedLeftInfoInset)
        XCTAssertEqual(
            metrics.triadOuterFrameWidth - metrics.triadTrailingEmbeddedInfoTrailingX,
            metrics.triadEmbeddedRightInfoInset
        )
        XCTAssertLessThan(metrics.triadEmbeddedInfoBottomY, metrics.casperTopYInOuterFrame)
        XCTAssertLessThan(metrics.triadEmbeddedInfoBottomY, metrics.melchiorTopYInOuterFrame)
    }

    func testMagiWarningStripStaysInsideTriadOuterFrame() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertGreaterThan(metrics.triadWarningStripHorizontalInset, 0)
        XCTAssertEqual(
            metrics.triadOuterFrameWidth - metrics.triadWarningStripHorizontalInset * 2,
            metrics.triadOuterFrameStrokeWidth - metrics.triadOuterFrameStrokeLineWidth * 2
        )
        XCTAssertLessThan(
            metrics.triadWarningStripHorizontalInset * 2,
            metrics.triadOuterFrameWidth
        )
    }

    func testMagiTriadUsesReferenceUnitProportions() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.topUnitSize, CGSize(width: 149, height: 108))
        XCTAssertEqual(metrics.bottomUnitSize, CGSize(width: 136, height: 104))
        XCTAssertEqual(metrics.hubSize, CGSize(width: 120, height: 72.5))
        XCTAssertEqual(metrics.topUnitCenter, CGPoint(x: 184, y: 55))
        XCTAssertEqual(metrics.hubCenter, CGPoint(x: 184, y: 145.25))
    }

    func testMagiOuterUnitTypographyUsesCompactNonOverflowingSizes() {
        let typography = MagiConsoleTypography()

        XCTAssertEqual(typography.englishFontName, "Share Tech Mono")
        XCTAssertEqual(typography.topUnitLabelSize, 32)
        XCTAssertEqual(typography.bottomUnitLabelSize, 32)
        XCTAssertEqual(typography.unitTitleFontName, "Helvetica Neue Condensed Bold")
        XCTAssertEqual(typography.unitSubtitleSize, 7)
        XCTAssertEqual(typography.metricFontName, "DS-Digital-Bold")
        XCTAssertEqual(typography.metricValueSize, 20)
    }

    func testMagiOuterUnitsExposeMetricSubtitles() {
        let labels = MagiTriadUnitLabels()

        XCTAssertEqual(labels.balthasar.title, "BALTHASAR-2")
        XCTAssertEqual(labels.balthasar.subtitle, "MEMORY")
        XCTAssertEqual(labels.casper.title, "CASPER-3")
        XCTAssertEqual(labels.casper.subtitle, "NETWORK")
        XCTAssertEqual(labels.melchior.title, "MELCHIOR-1")
        XCTAssertEqual(labels.melchior.subtitle, "CPU")
    }

    func testMagiUnitContentLayoutsStayInsideUnitBounds() {
        let metrics = MagiConsoleLayoutMetrics()
        let topLayout = MagiUnitContentLayout(placement: .top)
        let bottomLayout = MagiUnitContentLayout(placement: .bottom)

        XCTAssertEqual(topLayout.contentWidth, 136)
        XCTAssertLessThanOrEqual(topLayout.contentWidth, metrics.topUnitSize.width - topLayout.horizontalPadding * 2)
        XCTAssertEqual(topLayout.contentHeight, 80)
        XCTAssertLessThanOrEqual(topLayout.contentHeight, metrics.topUnitSize.height - topLayout.verticalPadding * 2)
        XCTAssertLessThanOrEqual(bottomLayout.contentWidth, metrics.bottomUnitSize.width - bottomLayout.horizontalPadding * 2)
        XCTAssertLessThanOrEqual(bottomLayout.contentHeight, metrics.bottomUnitSize.height - bottomLayout.verticalPadding * 2)
        XCTAssertEqual(topLayout.statusHeight, 0)
        XCTAssertEqual(bottomLayout.statusHeight, 0)
        XCTAssertEqual(topLayout.titleHeight, 44)
        XCTAssertEqual(bottomLayout.titleHeight, 44)
        XCTAssertEqual(topLayout.valueHorizontalInset, 20)
        XCTAssertEqual(bottomLayout.valueHorizontalInset, 16)
        XCTAssertEqual(topLayout.valueWidth, topLayout.contentWidth - topLayout.valueHorizontalInset * 2)
        XCTAssertEqual(bottomLayout.valueWidth, bottomLayout.contentWidth - bottomLayout.valueHorizontalInset * 2)
        XCTAssertFalse(topLayout.titleAppearsBelowValue)
        XCTAssertTrue(bottomLayout.titleAppearsBelowValue)
    }

    func testMagiBottomUnitsUseSymmetricInnerCornerBevels() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.bottomInnerCornerBevel, CGSize(width: 43.5, height: 43.5))
    }

    func testMagiBottomInnerBevelsShareHubLowerEdgeEndpoints() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.hubLowerLeftEdgeUpper, metrics.casperInnerBevelUpper)
        XCTAssertEqual(metrics.hubLowerLeftEdgeLower, metrics.casperInnerBevelLower)
        XCTAssertEqual(metrics.hubLowerRightEdgeUpper, metrics.melchiorInnerBevelUpper)
        XCTAssertEqual(metrics.hubLowerRightEdgeLower, metrics.melchiorInnerBevelLower)
    }

    func testMagiConnectorDoesNotDrawLowerVerticalStem() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let projectRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceFile = projectRoot
            .appendingPathComponent("Sources/NervNotchProApp/UI/MagiTriadConsoleView.swift")
        let source = try String(contentsOf: sourceFile)

        XCTAssertFalse(source.contains("path.addLine(to: CGPoint(x: centerX, y: rect.minY + metrics.casperCenter.y))"))
    }

    func testMagiSharedSlantSlopeIsFortyFiveDegrees() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.sharedSlantRun.width, metrics.sharedSlantRun.height)
        XCTAssertEqual(metrics.sharedSlantRun, CGSize(width: 29, height: 29))
    }

    func testMagiHubTopEdgeFullyOverlapsBalthasarBottomEdge() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.hubTopEdgeLength, 62)
        XCTAssertEqual(metrics.hubBottomEdgeLength, 33)
        XCTAssertEqual(metrics.hubTopEdgeLength, metrics.topUnitBottomEdgeLength)
        XCTAssertEqual(metrics.hubTopEdgeLength, metrics.hubSize.width - metrics.hubUpperSlantRun.width * 2)
        XCTAssertEqual(metrics.hubUpperLeftEdge, metrics.balthasarBottomLeftEdge)
        XCTAssertEqual(metrics.hubUpperRightEdge, metrics.balthasarBottomRightEdge)
    }

    func testMagiHubUpperSlantsUseLowerSlantsSupplementaryAngle() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.hubUpperSlantRun, metrics.sharedSlantRun)
        XCTAssertNotEqual(metrics.hubUpperSlantRun, metrics.hubLowerSlantRun)
    }

    func testMagiHubBottomEdgeAdaptsToSharedSlantSlope() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.hubLowerSlantScale, 1.5)
        XCTAssertEqual(metrics.hubLowerSlantRun, CGSize(width: 43.5, height: 43.5))
        XCTAssertEqual(metrics.hubBottomEdgeLength, metrics.hubSize.width - metrics.hubLowerSlantRun.width * 2)
    }

    func testMagiTriadSlantsShareTheSameSlope() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.bottomInnerCornerBevel, metrics.hubLowerSlantRun)
        XCTAssertEqual(
            metrics.topUnitLowerSideRun.width * metrics.sharedSlantRun.height,
            metrics.topUnitLowerSideRun.height * metrics.sharedSlantRun.width,
            accuracy: 0.001
        )
        XCTAssertEqual(
            metrics.hubLowerSlantRun.width * metrics.sharedSlantRun.height,
            metrics.hubLowerSlantRun.height * metrics.sharedSlantRun.width,
            accuracy: 0.001
        )
        XCTAssertEqual(
            metrics.hubUpperSlantRun.width * metrics.sharedSlantRun.height,
            metrics.hubUpperSlantRun.height * metrics.sharedSlantRun.width,
            accuracy: 0.001
        )
    }

    func testBalthasarBottomEdgeAdaptsToSharedSlantSlope() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.topUnitLowerSideRun, metrics.bottomInnerCornerBevel)
        XCTAssertEqual(metrics.topUnitLowerSideRun.height, metrics.topUnitSize.height - metrics.topUnitVerticalSideHeight)
        XCTAssertEqual(
            metrics.topUnitBottomEdgeLength,
            metrics.topUnitSize.width - metrics.topUnitLowerSideRun.width * 2,
            accuracy: 0.001
        )
    }

    func testBalthasarSideEdgesAreVerticalBeforeLowerSlants() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(
            metrics.topUnitVerticalSideHeight,
            metrics.topUnitSize.height - metrics.bottomInnerCornerBevel.height,
            accuracy: 0.001
        )
    }
}
