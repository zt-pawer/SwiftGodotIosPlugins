//
//  GameCenterViewController.swift
//  SwiftGodotIosPlugins
//
//  Created by ZT Pawer on 12/26/24.
//

#if canImport(UIKit)
    import SwiftGodot
    import GameKit
    import UIKit

    enum GameCenterUIState: Int {
        case success = 1
        case dismissed = 2
        case error = 3
    }

    class GameCenterViewController: UIViewController,
        GKGameCenterControllerDelegate
    {
        var onCompletitionHandler: ((Int) -> Void)?

        func showUIController(
            _ viewController: GKGameCenterViewController,
            completitionHandler: ((_ status: Int) -> Void)?
        ) {
            do {
                onCompletitionHandler = completitionHandler
                viewController.gameCenterDelegate = self
                try getRootController()?.present(
                    viewController, animated: true,
                    completion: {
                        guard let completitionHandler else { return }
                        completitionHandler(GameCenterUIState.success.rawValue)
                    }
                )
            } catch {
                guard let completitionHandler else { return }
                completitionHandler(GameCenterUIState.error.rawValue)
            }
        }

        func gameCenterViewControllerDidFinish(
            _ gameCenterViewController: GKGameCenterViewController
        ) {
            gameCenterViewController.dismiss(
                animated: true,
                completion: { [self] in
                    guard let onCompletitionHandler else { return }
                    (self.onCompletitionHandler!)(
                        GameCenterUIState.dismissed.rawValue)
                })
        }

        func getRootController() -> UIViewController? {
            return getMainWindow()?.rootViewController
        }

        func getMainWindow() -> UIWindow? {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }
                .first?.windows
                .first(where: \.isKeyWindow)
        }
    }
#endif
