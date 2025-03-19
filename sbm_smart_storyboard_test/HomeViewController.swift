//
//  HomeViewController.swift
//  sbm_smart_storyboard_test
//
//  Created by Rohit Kumar on 19/03/25.
//


import UIKit

class HomeViewController: UIViewController {
    
    private var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Navigated to HomeView from deep link")
    }
     private func setupNavigation() {
        title = "Home"
        // Even if coming from deep link, create a dummy view controller for back navigation
        if navigationController?.viewControllers.count == 1 {
            let dummyVC = UIViewController()
            navigationController?.viewControllers.insert(dummyVC, at: 0)
        }
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
}
