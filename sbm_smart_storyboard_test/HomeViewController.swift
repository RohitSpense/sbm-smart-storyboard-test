//
//  HomeViewController.swift
//  sbm_smart_storyboard_test
//
//  Created by Rohit Kumar on 19/03/25.
//


import UIKit

class HomeViewController: UIViewController {
    
    private var titleLabel: UILabel!
    @IBOutlet weak var back: UIButton? // Make this optional
    private var programmaticBackButton: UIButton? // Add this for programmatic creation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        
        // Print navigation stack when HomeViewController loads
        if let navigationController = self.navigationController {
            print("  HomeViewController navigation stack:")
            navigationController.viewControllers.enumerated().forEach { index, vc in
                print("  \(index): \(type(of: vc))")
            }
        } else {
            print("  HomeViewController has no navigation controller")
        }
    }
    
    private func setupNavigation() {
        title = "Home"
        
        if back == nil {
            // Create programmatic back button if IBOutlet is nil
            let backButton = UIButton(type: .system)
            backButton.setTitle("Back", for: .normal)
            backButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(backButton)
            
            // Setup constraints
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
            ])
            
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            self.programmaticBackButton = backButton
        } else {
            // Use storyboard back button
            back?.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        }
        
        navigationItem.hidesBackButton = false
    }

    
    private func setupUI() {
        // Create label
        titleLabel = UILabel()
        titleLabel.text = "Hello World"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to view hierarchy
        view.addSubview(titleLabel)
        
        // Set constraints
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add padding (equivalent to .padding() in SwiftUI)
        titleLabel.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        // Background color
        view.backgroundColor = .systemBackground
    }
    
    @objc private func backButtonTapped() {
        print("⬅️ Back button tapped in HomeViewController")
        if let navigationController = self.navigationController {
            print("Current navigation stack before pop:")
            navigationController.viewControllers.enumerated().forEach { index, vc in
                print("  \(index): \(type(of: vc))")
            }
            
             navigationController.popViewController(animated: true)
        }
    }
}
