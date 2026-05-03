import AppKit

extension NSScreen {
    var physicalNotchSize: CGSize {
        guard safeAreaInsets.top > 0 else {
            return .zero
        }

        let leftMenuAreaWidth = auxiliaryTopLeftArea?.width ?? 0
        let rightMenuAreaWidth = auxiliaryTopRightArea?.width ?? 0
        guard leftMenuAreaWidth > 0, rightMenuAreaWidth > 0 else {
            return CGSize(width: 180, height: safeAreaInsets.top)
        }

        return CGSize(
            width: frame.width - leftMenuAreaWidth - rightMenuAreaWidth + 4,
            height: safeAreaInsets.top
        )
    }
}
