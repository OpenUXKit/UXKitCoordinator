#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import OSLog
import AppKit
import CocoaCoordinator

#if canImport(OpenUXKit) || canImport(UXKit)

#if canImport(OpenUXKit)
import OpenUXKit
#elseif canImport(UXKit)
import UXKit
#endif

private let logger = Logger(subsystem: "com.JH.OpenUXKitCoordinator", category: "Transition")

extension Transition where ViewController: UXNavigationController {
    public static func push(_ presentable: Presentable, animated: Bool) -> Self {
        Self(presentables: [presentable]) { windowController, viewController, options, completion in
            if let uxViewController = presentable.viewController as? UXViewController {
                viewController?.push(
                    uxViewController
                    ,
                    animated: animated
                ) {
                    presentable.presented(from: viewController)
                    completion?()
                }
            } else {
                logger.fault("\(presentable.viewController) is not UXViewController.")
                completion?()
            }
        }
    }

    public static func pop(animated: Bool) -> Self {
        Self(presentables: []) { windowController, viewController, options, completion in
            viewController?.pop(toRoot: false, animated: animated, completion: completion)
        }
    }

    public static func pop(to presentable: Presentable, animated: Bool) -> Self {
        Self(presentables: [presentable]) { _, rootViewController, options, completion in
            if let uxViewController = presentable.viewController as? UXViewController {
                rootViewController?.pop(
                    to: uxViewController,
                    animated: animated,
                    completion: completion
                )
            } else {
                logger.fault("\(presentable.viewController) is not UXViewController.")
                completion?()
            }
        }
    }

    public static func popToRoot(animated: Bool) -> Self {
        Self(presentables: []) { _, rootViewController, options, completion in
            rootViewController?.pop(
                toRoot: true,
                animated: animated,
                completion: completion
            )
        }
    }

    public static func set(_ presentables: [Presentable], animated: Bool) -> Self {
        Self(presentables: presentables) { _, rootViewController, options, completion in
            rootViewController?.set(
                presentables.compactMap { $0.viewController as? UXViewController },
                animated: animated
            ) {
                presentables.forEach { $0.presented(from: rootViewController) }
                completion?()
            }
        }
    }
}

#endif

#endif
