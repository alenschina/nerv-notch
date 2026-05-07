import AppKit
import SwiftUI

struct NotchIslandLayout: Equatable {
    let compactNotchSize: CGSize
    private let hoverExpansionWidth: CGFloat = 16
    private let magiMetrics = MagiConsoleLayoutMetrics()
    let expandedHeaderTopPadding: CGFloat = 11
    let expandedHeaderSpacing: CGFloat = 6
    let expandedHeaderFontSize: CGFloat = 15
    let expandedHeaderIconSize: CGFloat = 22
    let expandedHeaderFontName = "SourceHanSerifCN-Bold"

    var compactSize: CGSize {
        compactSize(isHovering: false)
    }

    func compactSize(isHovering: Bool) -> CGSize {
        let iconSpaceWidth = compactNotchSize.height * 2
        let hoverWidth = isHovering ? hoverExpansionWidth : 0
        return CGSize(
            width: compactNotchSize.width + iconSpaceWidth + hoverWidth,
            height: compactNotchSize.height
        )
    }

    var expandedSize: CGSize {
        CGSize(
            width: 820,
            height: magiMetrics.consoleContentTopPadding
            + magiMetrics.triadOuterFrameHeight
            + magiMetrics.consoleContentBottomPadding
        )
    }

    var expandedHeaderLeadingPadding: CGFloat {
        magiMetrics.leftAuxiliaryFrameStrokeLeftXInConsole
    }
}

enum NervIslandIcon {
    static let resourceName = "nerv-island-icon"

    static var image: NSImage? {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "png")
            ?? Bundle.module.url(forResource: resourceName, withExtension: "png") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }

    static func dimension(forCompactHeight compactHeight: CGFloat) -> CGFloat {
        max(16, compactHeight - 8)
    }
}

struct NervConsoleView: View {
    @ObservedObject var viewModel: NotchViewModel
    let layout: NotchIslandLayout

    init(viewModel: NotchViewModel, compactNotchSize: CGSize = NotchGeometry.simulatedNotchSize) {
        self.viewModel = viewModel
        self.layout = NotchIslandLayout(compactNotchSize: compactNotchSize)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            islandSurface
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.easeOut(duration: 0.25), value: isExpanded)
        .animation(.easeInOut(duration: 0.18), value: isCompactHovering)
    }

    private var isExpanded: Bool {
        switch viewModel.interactionState {
        case .opened, .closing:
            return true
        case .closed, .hoverArming:
            return false
        }
    }

    private var isCompactHovering: Bool {
        if case .hoverArming = viewModel.interactionState {
            return true
        }
        return false
    }

    private var islandSurface: some View {
        ZStack {
            if isExpanded {
                expandedConsole
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                compactIsland
                    .transition(.opacity)
            }
        }
        .frame(
            width: isExpanded ? layout.expandedSize.width : layout.compactSize(isHovering: isCompactHovering).width,
            height: isExpanded ? layout.expandedSize.height : layout.compactSize(isHovering: isCompactHovering).height
        )
        .notchIslandChrome(isExpanded: isExpanded)
    }

    private var expandedConsole: some View {
        ZStack(alignment: .topLeading) {
            MagiTriadConsoleView(state: viewModel.magiState)

            expandedHeader
                .padding(.top, layout.expandedHeaderTopPadding)
                .padding(.leading, layout.expandedHeaderLeadingPadding)
        }
    }

    private var compactIsland: some View {
        HStack {
            nervLeadingIcon(sideLength: NervIslandIcon.dimension(forCompactHeight: layout.compactSize.height))
                .padding(.leading, 14)

            Spacer()

            Circle()
                .stroke(compactStatusColor, lineWidth: 1.5)
                .frame(width: 10, height: 10)
                .padding(.trailing, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var expandedHeader: some View {
        HStack(alignment: .center, spacing: layout.expandedHeaderSpacing) {
            nervLeadingIcon(sideLength: layout.expandedHeaderIconSize)

            Text("NERV コントロールセンター")
                .font(.custom(layout.expandedHeaderFontName, size: layout.expandedHeaderFontSize))
                .fontWeight(.bold)
                .foregroundStyle(NervStyle.orange)
                .shadow(color: NervStyle.orange.opacity(0.75), radius: 3)
                .lineLimit(1)
        }
        // Match row height to the square icon so the label centers with the glyph box (custom CJK line metrics often read low in a default HStack).
        .frame(height: layout.expandedHeaderIconSize, alignment: .center)
    }

    @ViewBuilder
    private func nervLeadingIcon(sideLength: CGFloat) -> some View {
        if let icon = NervIslandIcon.image {
            Image(nsImage: icon)
                .resizable()
                .scaledToFit()
                .frame(width: sideLength, height: sideLength)
        }
    }

    private var compactStatusColor: Color {
        switch viewModel.magiState.judgement.level {
        case .synchronized:
            return NervStyle.green
        case .elevatedAlert:
            return NervStyle.orange
        case .emergencyMode, .partialSync:
            return NervStyle.red
        }
    }
}
