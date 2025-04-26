import UIKit
import sbm_library_ios

class NavigationHelper {
    
    // MARK: - Singleton
    static let shared = NavigationHelper()
    private init() {}
    
    // MARK: - Properties
    private var mainNavigationController: UINavigationController?
    
    // MARK: - Setup
    func setupMainNavigationController(_ navController: UINavigationController) {
        self.mainNavigationController = navController
        print("Main navigation controller set: \(navController)")
    }
    
    // MARK: - Navigation Methods
    
    /// Push a view controller onto the navigation stack
    func push(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let navController = mainNavigationController else {
            print("❌ Error: Main navigation controller not set")
            return
        }
        
        print("🔄 Current view controller: \(String(describing: navController.topViewController))")
        print("➡️ Pushing new view controller: \(String(describing: viewController))")
        
        DispatchQueue.main.async {
            navController.pushViewController(viewController, animated: animated)
            print("✅ Push completed")
            
            if let completion = completion {
                if animated, let coordinator = navController.transitionCoordinator {
                    coordinator.animate(alongsideTransition: nil) { _ in
                        completion()
                    }
                } else {
                    completion()
                }
            }
        }
    }
    
    /// Present a view controller modally
    func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let navController = mainNavigationController else {
            print("Error: Main navigation controller not set")
            return
        }
        
        navController.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop to the previous view controller
    func popViewController(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let navController = mainNavigationController else {
            print("Error: Main navigation controller not set")
            return
        }
        
        navController.popViewController(animated: animated)
        
        if let completion = completion {
            if animated, let coordinator = navController.transitionCoordinator {
                coordinator.animate(alongsideTransition: nil) { _ in
                    completion()
                }
            } else {
                completion()
            }
        }
    }
    
    /// Navigate to a specific view controller by identifier from storyboard
    func navigateToViewController(withIdentifier identifier: String,
                                from storyboardName: String = "Main",
                                animated: Bool = true,
                                setup: ((UIViewController) -> Void)? = nil,
                                completion: (() -> Void)? = nil) {
        print("⚡️ Attempting to navigate to: \(identifier)")
        
        guard let navController = mainNavigationController else {
            print("❌ Error: Main navigation controller not set")
            return
        }
        print("✅ Navigation controller found: \(navController)")
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        guard let destinationVC = storyboard.instantiateViewController(withIdentifier: identifier) as UIViewController? else {
            print("❌ Error: Could not instantiate view controller with identifier: \(identifier)")
            return
        }
        print("✅ Successfully instantiated \(identifier)")
        
        setup?(destinationVC)
        print("➡️ Pushing view controller")
        push(destinationVC, animated: animated, completion: completion)
    }
    
    /// Open SBM Library
    func openSBMLibrary(from viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let navController = mainNavigationController else {
            print("Error: Main navigation controller not set")
            return
        }
        
        PartnerLibrarySingleton.shared.initialize(
            withHostName: EnvManager.partnerHostName,
            deviceBindingEnabled: false,
            whitelistedUrls: ["api.razorpay.com", "sbmkycuat.esbeeyem.com", "m2pfintech.com"]
        )
        
        // Use Task to handle async call
        Task {
            if let token = await Helpers().getToken() {
                do {
                    // Initialize Partner Library
                    
                    // Set navigation controller for Partner Library
                    PartnerLibrarySingleton.shared.instance.setParentNavigationController(navController)
                    try await PartnerLibrarySingleton.shared.instance.open(
                        on: viewController,
                        token: token,
                        module: "/banking/sbm/credit_card/MWK"
                    ) { action in
                        switch action {
                        case .logout:
                            print("User logged out")
                            completion?()
                        case .redirect(let status):
                            print("Redirected with status: \(status)")
                            completion?()
                        }
                    }
                } catch {
                    print("Error opening SBM Library: \(error)")
                }
            }
        }
    }
}
