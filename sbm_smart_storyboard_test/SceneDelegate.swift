//
//  SceneDelegate.swift
//  sbm_smart_storyboard_test
//
//  Created by Rohit Kumar on 19/03/25.
//

import UIKit
import sbm_library_ios

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create window and initial setup
        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = UINavigationController()
        
        // Check for deep link
        for urlContext in connectionOptions.urlContexts {
            let url = urlContext.url
            let host = url.host
            
            if host == "home" {
                if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
                    navigationController.setViewControllers([homeVC], animated: false)
                    window.rootViewController = navigationController
                    self.window = window
                    window.makeKeyAndVisible()
                    return
                }
            }
        }
        
        // Default flow - no deep link
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            navigationController.setViewControllers([loginVC], animated: false)
            window.rootViewController = navigationController
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    // Handle deep links when app is already running
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        print("Deep link received: \(url)")
        
        let host = url.host
        if host == "home" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController,
               let navigationController = window?.rootViewController as? UINavigationController {
                DispatchQueue.main.async {
                    navigationController.setViewControllers([homeVC], animated: true)
                }
            }
        }
    }
}

// URL extension for query parameters
extension URL {
    func getQueryStringParameter(param: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }




