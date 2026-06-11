#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import CocoaCoordinator

#if canImport(OpenUXKit) || canImport(UXKit)

#if canImport(OpenUXKit)
import OpenUXKit
#elseif canImport(UXKit)
import UXKit
#endif

/// Hosts the currently-visible `UXPopoverController`.
///
/// Mirrors CocoaCoordinator's `GlobalPopover`, but routes through
/// `UXPopoverController` instead of a bare `NSPopover`. This matters for
/// `UXViewController` content: `UXViewController` overrides `preferredContentSize`
/// with a private ivar and never forwards to `NSViewController`, and AppKit's popover
/// show path never reads `preferredContentSize` — it falls back to the content view's
/// frame, so a plain `NSPopover` comes up at `UXViewController`'s default 500×500
/// `loadView` frame. `UXPopoverController` bridges the gap: as the popover's delegate it
/// seeds `NSPopover.contentSize` from `preferredContentSize` in `popoverWillShow:`, and
/// keeps it in sync via KVO so the popover also resizes when the content changes size
/// while visible.
@MainActor
final class UXGlobalPopover: NSObject, UXPopoverControllerDelegate {
    static let shared = UXGlobalPopover()

    private var popoverController: UXPopoverController?

    private override init() {
        super.init()
    }

    func show(
        contentViewController: UXViewController,
        relativeTo positioningRect: NSRect,
        of positioningView: NSView,
        preferredEdge: NSRectEdge,
        behavior: NSPopover.Behavior
    ) {
        // Only one popover at a time; close any previous one first.
        popoverController?.dismissPopover()

        let controller = UXPopoverController(contentViewController: contentViewController)
        controller.popoverBehavior = behavior
        controller.delegate = self
        popoverController = controller

        // Anchor through the underlying popover so a plain `NSView` works;
        // `presentPopoverFromRect:inView:` requires a `UXView`. The delegate-driven
        // content-size seeding fires either way.
        controller.popover.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
    }

    func close() {
        popoverController?.dismissPopover()
    }

    // MARK: - UXPopoverControllerDelegate

    func popoverControllerShouldDismissPopover(_ popoverController: UXPopoverController) -> Bool {
        true
    }

    func popoverControllerDidDismissPopover(_ popoverController: UXPopoverController) {
        if popoverController === self.popoverController {
            self.popoverController = nil
        }
    }
}

extension Transition {
    /// Presents `presentable` in a `UXPopoverController`-managed popover anchored to
    /// `positioningRect` in `positioningView`. The content controller must be a
    /// `UXViewController` so the popover honours its `preferredContentSize`.
    public static func uxPopover(
        _ presentable: Presentable,
        relativeTo positioningRect: NSRect,
        of positioningView: NSView,
        preferredEdge: NSRectEdge,
        behavior: NSPopover.Behavior
    ) -> Self {
        Self(presentables: [presentable]) { _, _, _, completion in
            if let uxViewController = presentable.viewController as? UXViewController {
                UXGlobalPopover.shared.show(
                    contentViewController: uxViewController,
                    relativeTo: positioningRect,
                    of: positioningView,
                    preferredEdge: preferredEdge,
                    behavior: behavior
                )
            }
            completion?()
        }
    }

    /// Closes the popover presented by `uxPopover(_:relativeTo:of:preferredEdge:behavior:)`.
    /// Use this where a non-transient dismissal is needed (e.g. after a selection); a
    /// `.transient` popover otherwise closes itself on an outside click.
    public static func closeUXPopover() -> Self {
        Self(presentables: []) { _, _, _, completion in
            UXGlobalPopover.shared.close()
            completion?()
        }
    }
}

#endif

#endif
