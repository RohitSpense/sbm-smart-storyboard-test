
import Foundation
import sbm_library_ios
import UIKit

class Helpers {
    
    let library = PartnerLibrarySingleton.shared.instance
    
    func openSBMLibrary(from viewController: UIViewController) async {
            if let token = await getToken() {
                do {
                    print("Navigation controller in helper: \(String(describing: viewController.navigationController))")
                    print("TOKEN ******* \(token)")
                    try await library.open(on: viewController,
                                         token: token,
                                         module: "/banking/sbm/credit_card/MWK") { action in
                        switch action {
                        case .logout:
                            print("User logged out")
                        case .redirect(let status):
                            print("Redirected with status: \(status)")
                        }
                    }
                } catch {
                    print("Error opening library: \(error)")
                }
            }
        }
    
    private func getToken() async -> String? {
        print("HERE ")
        do {
            let response = try await NetworkRequest.shared.makeRequest(url: URL(string: ServiceNames.USER_TOKEN)!, method: "GET")
            return response["token"] as? String
        } catch {
            print(error)
            return nil
        }
    }
}
