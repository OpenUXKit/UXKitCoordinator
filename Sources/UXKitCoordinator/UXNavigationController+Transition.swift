#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import CocoaCoordinator

#if canImport(OpenUXKit) || canImport(UXKit)

#if canImport(OpenUXKit)
import OpenUXKit
#elseif canImport(UXKit)
import UXKit
#endif

extension UXNavigationController {
    func push(_ viewController: UXViewController, animated: Bool, completion: (() -> Void)?) {
        pushViewController(viewController, animated: animated)

        completion?()
    }

    func pop(toRoot: Bool, animated: Bool, completion: PresentationHandler?) {
        if toRoot {
            popToRootViewController(animated: animated)
        } else {
            popViewController(animated: animated)
        }

        completion?()
    }

    func set(_ viewControllers: [UXViewController], animated: Bool, completion: PresentationHandler?) {
        setViewControllers(viewControllers, animated: animated)

        completion?()
    }

    func pop(to viewController: UXViewController, animated: Bool, completion: PresentationHandler?) {
        _ = popToViewController(viewController, animated: animated)

        completion?()
    }
}

#endif

#endif
