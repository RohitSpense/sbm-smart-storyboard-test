//
//  PhoneOTPController.swift
//  sbm_smart_storyboard_test
//
//  Created by Rohit Kumar on 19/03/25.
//
import UIKit

class PhoneOTPController: UIViewController, UITextFieldDelegate {
    // MARK: - Outlets
    @IBOutlet weak var otpTextField1: UITextField!
    @IBOutlet weak var otpTextField2: UITextField!
    @IBOutlet weak var otpTextField3: UITextField!
    @IBOutlet weak var otpTextField4: UITextField!
    @IBOutlet weak var otpTextField5: UITextField!
    @IBOutlet weak var otpTextField6: UITextField!
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var resendStackView: UIStackView!
//    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    // MARK: - Properties
     public var phone: String = ""
     var verifyCode: String = ""
     var timeRemaining = 60
     var timer: Timer?
     var otpPasted = false
     var isResendVisible = true
     var isLoading = false
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("📱 PhoneOTPController viewDidLoad called")
        setupUI()
        setupTextFields()
        setupNotifications()
        requestOTP()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
    // OTP Label
    otpLabel.text = "Enter the OTP sent to " + phone  // Use phone directly
    
    // Continue Button
    updateContinueButtonState()
    
    // Timer
//    startTimer()
    
    // Initially hide resend stack
    resendStackView.isHidden = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
        self.resendStackView.isHidden = false
    }
}

    
    private func setupTextFields() {
        let textFields = [otpTextField1, otpTextField2, otpTextField3, otpTextField4, otpTextField5, otpTextField6]
        
        for textField in textFields {
            textField?.delegate = self
            textField?.keyboardType = .numberPad
            textField?.textAlignment = .center
            textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        
        // Focus on first textfield
        otpTextField1.becomeFirstResponder()
    }
    
    private func setupNotifications() {
//        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // For handling pasted text
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePasteboardChange),
            name: UIPasteboard.changedNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        NavigationHelper.shared.popViewController()
    }
    
    @IBAction func resendCodeTapped(_ sender: UIButton) {
        resendOTP()
        timeRemaining = 60
//        startTimer()
//        updateResendButtonState(enabled: false)
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
            print("Continue button tapped!") 

        verifyOTP()
    }
    
    // MARK: - Helper Methods
//    private func startTimer() {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
//    }
    
//    @objc private func updateTimer() {
//        if timeRemaining > 0 {
//            timeRemaining -= 1
//            timerLabel.text = "(\(timeRemaining))"
//            updateResendButtonState(enabled: false)
//        } else {
//            timer?.invalidate()
//            updateResendButtonState(enabled: true)
//        }
//    }
    
//    private func updateResendButtonState(enabled: Bool) {
//        resendButton.isEnabled = enabled
//        resendButton.setTitleColor(enabled ? UIColor(named: "sbmPrimary") : UIColor(named: "sbmPrimary30"), for: .normal)
//        timerLabel.isHidden = enabled
//    }
    
    private func updateContinueButtonState() {
        let allFields = [otpTextField1, otpTextField2, otpTextField3, otpTextField4, otpTextField5, otpTextField6]
        let allFilled = allFields.allSatisfy { ($0?.text?.isEmpty == false) }
        
        continueButton.isEnabled = allFilled
        continueButton.backgroundColor = allFilled ? UIColor(named: "sbmPrimary") : UIColor(named: "sbmPrimary30")
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.count >= 1 {
            textField.text = String(text.prefix(1))
            
            if !otpPasted {
                focusNextTextField(after: textField)
            }
        }
        
        updateContinueButtonState()
    }
    
    private func focusNextTextField(after textField: UITextField) {
        switch textField {
        case otpTextField1:
            otpTextField2.becomeFirstResponder()
        case otpTextField2:
            otpTextField3.becomeFirstResponder()
        case otpTextField3:
            otpTextField4.becomeFirstResponder()
        case otpTextField4:
            otpTextField5.becomeFirstResponder()
        case otpTextField5:
            otpTextField6.becomeFirstResponder()
        case otpTextField6:
            otpTextField6.resignFirstResponder()
        default:
            break
        }
    }
    
//    @objc private func appMovedToForeground() {
//        if timeRemaining <= 0 {
//            updateResendButtonState(enabled: true)
//        }
//    }
    
    @objc private func handlePasteboardChange() {
        if let pasteboardString = UIPasteboard.general.string, pasteboardString.count >= 6 {
            let otpDigits = Array(pasteboardString.prefix(6))
            let textFields = [otpTextField1, otpTextField2, otpTextField3, otpTextField4, otpTextField5, otpTextField6]
            
            otpPasted = true
            
            for (index, digit) in otpDigits.enumerated() {
                if index < textFields.count {
                    textFields[index]?.text = String(digit)
                }
            }
            
            textFields.last??.becomeFirstResponder()
            updateContinueButtonState()
            otpPasted = false
        }
    }
    
    // MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // If multiple characters pasted
        if string.count > 1 {
            distributeOTP(string, startingAt: textField.tag)
            return false
        }
        
        // Handle backspace
        if string.isEmpty && range.length > 0 {
            if textField.text?.isEmpty == true {
                handleBackspace(at: textField.tag)
                return false
            }
            return true
        }
        
        // Allow only one digit
        if textField.text?.count ?? 0 >= 1 && range.length == 0 {
            return false
        }
        
        // Accept only numeric characters
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
    }
    
    private func handleBackspace(at index: Int) {
        switch index {
        case 1:
            otpTextField1.becomeFirstResponder()
        case 2:
            otpTextField2.becomeFirstResponder()
            otpTextField2.text = ""
        case 3:
            otpTextField3.becomeFirstResponder()
            otpTextField3.text = ""
        case 4:
            otpTextField4.becomeFirstResponder()
            otpTextField4.text = ""
        case 5:
            otpTextField5.becomeFirstResponder()
            otpTextField5.text = ""
        default:
            break
        }
        otpPasted = false
    }
    
    private func distributeOTP(_ otpString: String, startingAt index: Int) {
        let characters = Array(otpString.prefix(6))
        let textFields = [otpTextField1, otpTextField2, otpTextField3, otpTextField4, otpTextField5, otpTextField6]
        
        otpPasted = true
        
        for (offset, char) in characters.enumerated() {
            let targetIndex = index + offset
            if targetIndex < textFields.count {
                textFields[targetIndex]?.text = String(char)
            }
        }
        
        if index + characters.count < textFields.count {
            textFields[index + characters.count]?.becomeFirstResponder()
        } else {
            textFields.last??.becomeFirstResponder()
        }
        
        updateContinueButtonState()
    }
    
    // MARK: - API Methods
    private func requestOTP() {
    Task {
        do {
            guard !phone.isEmpty else {
                print("❌ Error: Phone number is empty")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Phone number is required")
                }
                return
            }
            
            print("Requesting OTP for phone: \(phone)")
            let payload = ["credential": phone]
            print("Payload: \(payload)")
            
            let response = try await NetworkRequest.shared.makeRequest(
                url: URL(string: ServiceNames.PHONE_AUTH)!,
                method: "POST",
                jsonPayload: payload as [String : Any]
            )
            
            print("Full API Response: \(response)")
            
            if let code = response["verify_code"] as? String {
                self.verifyCode = code
                print("✅ Verify code received: \(code)")
            } else {
                print("❌ Error: verify_code not found in response")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Could not get verification code")
                }
            }
        } catch {
            print("❌ Error sending OTP: \(error)")
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Failed to send OTP. Error: \(error.localizedDescription)")
            }
        }
    }
}
    
    private func resendOTP() {
        Task {
            do {
                let payload = ["verify_code": verifyCode]
                let _ = try await NetworkRequest.shared.makeRequest(url: URL(string: ServiceNames.AUTH_RESEND)!, method: "POST", jsonPayload: payload as [String: Any])
            } catch {
                print("Error resending OTP: \(error)")
            }
        }
    }
    
    private func verifyOTP() {
        showLoading(true)
        
        let otp = [
            otpTextField1.text ?? "",
            otpTextField2.text ?? "",
            otpTextField3.text ?? "",
            otpTextField4.text ?? "",
            otpTextField5.text ?? "",
            otpTextField6.text ?? ""
        ].joined()
        
        Task {
            do {
                let payload = ["auth": otp]
                let response = try await NetworkRequest.shared.makeRequest(url: URL(string: "\(ServiceNames.AUTH_VERIFY)/\(verifyCode)")!, method: "POST", jsonPayload: payload as [String: Any])
                print("verifyOTP response: \(response)")
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if let type = response["type"] as? String {
                        if type == "danger" {
                            if let message = response["message"] as? String, message == "Invalid auth" {
                                // Incorrect OTP
                                self.showAlert(title: "Incorrect OTP", message: "The OTP you entered is incorrect")
                            }
                            self.showLoading(false)
                        } else if type == "success" {
                            UserDefaults.standard.setValue((response["user"] as? [String: Any])!["user_id"] as! Int, forKey: "user_id")
                            self.checkForNewUser(response: response)
                        }
                    } else {
                        self.showAlert(title: "Error", message: "Something went wrong")
                        self.showLoading(false)
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showLoading(false)
                    self?.showAlert(title: "Error", message: "Failed to verify OTP")
                }
                print("Error verifying OTP: \(error)")
            }
        }
    }
    
    private func checkForNewUser(response: [String: Any]) {
        guard let user = response["user"] as? [String: Any],
              let email = user["email"] as? String else {
            goToEmailVerification()
            return
        }
        
        if !email.isEmpty {
            UserDefaults.standard.setValue(true, forKey: "is_logged_in")
            Task {
                await NavigationHelper.shared.openSBMLibrary(from: self)
//                await Helpers().openSBMLibrary(from: self)
//
            }
        } else {
            goToEmailVerification()
        }
    }
private func checkForProfileSetup(response: [String: Any]) async {
    guard let user = response["user"] as? [String: Any],
          let attributes = user["attributes"] as? [String: Any],
          let name = attributes["name"] as? String else {
        goToProfileSetup()
        return
    }
    
    if !name.isEmpty {
        UserDefaults.standard.setValue(true, forKey: "is_logged_in")
        DispatchQueue.main.async { [weak self] in
           // self?.navigationController?.popViewController(animated: true)
        }
        // Pass self as the viewController parameter
//        await Helpers().openSBMLibrary(from: self)
        await NavigationHelper.shared.openSBMLibrary(from: self)
    } else {
        goToProfileSetup()
    }
}
    
    private func goToEmailVerification() {
        DispatchQueue.main.async { [weak self] in
            self?.showLoading(false)
            self?.performSegue(withIdentifier: "goToEmailVerification", sender: self)
        }
    }
    
    private func goToProfileSetup() {
        DispatchQueue.main.async { [weak self] in
            self?.showLoading(false)
            self?.performSegue(withIdentifier: "goToProfileSetup", sender: self)
        }
    }
    
    // MARK: - Helper UI Methods
    private func showLoading(_ show: Bool) {
        isLoading = show
        // Add your loading indicator logic here
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
