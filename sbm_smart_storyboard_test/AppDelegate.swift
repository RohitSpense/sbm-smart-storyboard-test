//
//  AppDelegate.swift
//  sbm_smart_storyboard_test
//
//  Created by Rohit Kumar on 19/03/25.
//
import UIKit
import sbm_library_ios

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigationController: UINavigationController!  // Make this non-optional
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
            fatalError("Unable to instantiate LoginViewController")
        }
        
        navigationController = UINavigationController(rootViewController: loginVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // Initialize Partner Library first
        PartnerLibrarySingleton.shared.initialize(
            withHostName: EnvManager.partnerHostName,
            deviceBindingEnabled: false,
            whitelistedUrls: ["api.razorpay.com", "sbmkycuat.esbeeyem.com", "m2pfintech.com"]
        )
        
        // Then set the app's navigation controller
        PartnerLibrarySingleton.shared.instance.setParentNavigationController(navigationController)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    print("📱 Deep link received: \(url)")
    handleDeepLink(url)
    return true
}

private func handleDeepLink(_ url: URL) {
    print("🔍 Checking URL scheme: \(url.scheme ?? "nil")")
    
    guard url.scheme == "ikwik-test" else {
        print("❌ Invalid URL scheme: \(url.scheme ?? "nil")")
        return
    }
    
    print("✅ Valid URL scheme")
    print("📍 URL host: \(url.host ?? "nil")")
    
    if url.host == "home" {
        print("🏠 Attempting to navigate to Home")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            print("❌ Failed to instantiate HomeViewController")
            return
        }
        
        guard let navController = window?.rootViewController as? UINavigationController else {
            print("❌ Navigation controller not found")
            return
        }
        
        print("⚡️ Navigation controller found, setting HomeViewController")
        DispatchQueue.main.async {
            navController.setViewControllers([homeVC], animated: true)
            print("✅ Navigation complete")
        }
    }
}
}
