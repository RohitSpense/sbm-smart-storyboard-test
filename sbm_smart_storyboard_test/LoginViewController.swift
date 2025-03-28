//
//  LoginViewController.swift
//  sbm_smart_storyboard_test
//
//  Created by Rohit Kumar on 19/03/25.
//


import UIKit
import SafariServices

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var notificationCheckbox: UIButton!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var termsCheckbox: UIButton!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var bottomLogoImageView: UIImageView!
    
    // MARK: - Properties
    public let maxLength = 10
    public var notificationChecked = false
    public var termsChecked = false
    public var urlToLoad: URL?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - UI Setup
    public func setupUI() {
        // Title Label
        titleLabel.text = "Get started with mobile number"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        
        // Phone TextField
        phoneTextField.placeholder = "Enter mobile number"
        phoneTextField.keyboardType = .numberPad
        phoneTextField.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        phoneTextField.backgroundColor = UIColor(named: "TextFieldBackground")
        phoneTextField.textColor = UIColor(named: "TextStandard")
        phoneTextField.layer.cornerRadius = 8
        phoneTextField.delegate = self
        phoneTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: phoneTextField.frame.height))
        phoneTextField.leftViewMode = .always
        phoneTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: phoneTextField.frame.height))
        phoneTextField.rightViewMode = .always
        
        // Notification Checkbox and Label
        notificationCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
        notificationCheckbox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        notificationCheckbox.tintColor = UIColor(named: "SBMPrimary")
        notificationLabel.text = "I agree to get important notifications and assistance on SMS, email and call"
        notificationLabel.font = UIFont.systemFont(ofSize: 14)
        
        // Terms Checkbox and Label
        termsCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
        termsCheckbox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        termsCheckbox.tintColor = UIColor(named: "SBMPrimary")
        
        // Set up terms label with clickable parts
        setupTermsLabel()
        
        // Login Button
        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = UIColor(named: "SBMPrimary")?.withAlphaComponent(0.3)
        loginButton.layer.cornerRadius = 8
        loginButton.isEnabled = false
        
        // Bottom Logo
        bottomLogoImageView.contentMode = .scaleAspectFit
        
        // Set logo images
        logoImageView.image = UIImage(named: "logo_full")
        bottomLogoImageView.image = UIImage(named: "logo_full")
    }
    
    public func setupTermsLabel() {
        let termsText = "I agree to SBM terms of use and privacy policy"
        let attributedString = NSMutableAttributedString(string: termsText)
        
        // Set attributes for clickable parts
        let termsRange = (termsText as NSString).range(of: "terms of use")
        let privacyRange = (termsText as NSString).range(of: "privacy policy")
        
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "SBMPrimary") ?? .blue, range: termsRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "SBMPrimary") ?? .blue, range: privacyRange)
        
        termsLabel.attributedText = attributedString
        
        // Add tap gesture to label
        termsLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTermsTap(_:)))
        termsLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions Setup
    public func setupActions() {
        notificationCheckbox.addTarget(self, action: #selector(notificationCheckboxTapped), for: .touchUpInside)
        termsCheckbox.addTarget(self, action: #selector(termsCheckboxTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Action Methods
    @objc public func notificationCheckboxTapped() {
        notificationChecked.toggle()
        notificationCheckbox.isSelected = notificationChecked
        updateLoginButtonState()
    }
    
    @objc public func termsCheckboxTapped() {
        termsChecked.toggle()
        termsCheckbox.isSelected = termsChecked
        updateLoginButtonState()
    }
    @IBAction func loginButtonTapped(_ sender: Any) {
        print("🔵 Login button tapped")
        
        if !isValidPhoneNumber(phoneTextField.text ?? "") {
            print("❌ Invalid phone number")
            showAlert(message: "Please enter a valid phone number.")
        } else if !termsChecked {
            print("❌ Terms not checked")
            showAlert(message: "You must agree to all terms and policies to proceed")
        } else {
            print("✅ Validation passed, performing segue")
            performSegue(withIdentifier: "goToOTP", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("🔄 Preparing for segue: \(segue.identifier ?? "unknown")")
        
        if segue.identifier == "goToOTP",
           let otpVC = segue.destination as? PhoneOTPController {
            print("✅ Successfully cast destination to PhoneOTPController")
            let phoneNumber = self.phoneTextField.text ?? ""
            UserDefaults.standard.set("+91" + phoneNumber, forKey: "phoneNumber")
            otpVC.phone = "+91" + phoneNumber
            print("📞 Set phone number: +91\(phoneNumber)")
        }
    }
    @objc public func handleTermsTap(_ gesture: UITapGestureRecognizer) {
        let termsText = "I agree to SBM terms of use and privacy policy"
        let termsRange = (termsText as NSString).range(of: "terms of use")
        let privacyRange = (termsText as NSString).range(of: "privacy policy")
        
        let point = gesture.location(in: termsLabel)
        
//        if let textContainer = termsLabel.textContainer(for: point) {
//            if textContainer.contains(point, in: termsRange) {
//                openURL(URL(string: "https://www.sbmbank.co.in")!)
//            } else if textContainer.contains(point, in: privacyRange) {
//                openURL(URL(string: "https://www.sbmbank.co.in")!)
//            }
//        }
    }
    
    // MARK: - Helper Methods
    public func isValidPhoneNumber(_ number: String) -> Bool {
        return number.count == 10
    }
    
    public func updateLoginButtonState() {
        let isValid = isValidPhoneNumber(phoneTextField.text ?? "") && termsChecked && notificationChecked
        loginButton.isEnabled = isValid
        loginButton.backgroundColor = isValid ? UIColor(named: "SBMPrimary") : UIColor(named: "SBMPrimary")?.withAlphaComponent(0.3)
    }
    
    public func openURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    public func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // In LoginViewController.swift
//    public func navigateToOtpScreen() {
//        print("🚀 Starting navigation to OTP screen")
//        
//        NavigationHelper.shared.navigateToViewController(
//            withIdentifier: "PhoneOTPController",
//            animated: true,
//            setup: { [weak self] viewController in
//                guard let self = self else {
//                    print("❌ Self is nil in setup closure")
//                    return
//                }
//                
//                if let otpVC = viewController as? PhoneOTPController {
//                    print("✅ Successfully cast to PhoneOTPController")
//                    let phoneNumber = self.phoneTextField.text ?? ""
//                    UserDefaults.standard.set("+91" + phoneNumber, forKey: "phoneNumber")
//                    otpVC.phone = "+91" + phoneNumber
//                    print("📞 Set phone number: +91\(phoneNumber)")
//                    print("🔍 OTP View Controller state: \(otpVC)")
//                } else {
//                    print("❌ Failed to cast viewController to PhoneOTPController")
//                    print("🔍 Actual type: \(type(of: viewController))")
//                }
//            }
//        ) {
//            print("✅ Navigation completed")
//        }
//    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        if newLength <= maxLength {
            DispatchQueue.main.async {
                self.updateLoginButtonState()
            }
            return true
        }
        return false
    }
}

// MARK: - UILabel Extension for Tap Gesture
extension UILabel {
    func textContainer(for point: CGPoint) -> NSTextContainer? {
        guard let attributedText = attributedText else { return nil }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        if !textBoundingBox.contains(point) {
            return nil
        }
        
        return textContainer
    }
    
    func contains(_ point: CGPoint, in range: NSRange) -> Bool {
        guard let attributedText = attributedText else { return false }
        guard let textContainer = textContainer(for: point) else { return false }
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addLayoutManager(layoutManager)
        
        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        let glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        return glyphRect.contains(point)
    }
}

//// MARK: - PhoneOTPViewController (Stub)
//class PhoneOTPViewController: UIViewController {
//    var phone: String = ""
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Setup your OTP view here
//    }
//}
