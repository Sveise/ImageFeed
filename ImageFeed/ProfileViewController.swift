//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 07.05.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupProfileImage()
        setupNameLabel()
        setupLoginLabel()
        setupDescriptionLabel()
        setupButtonExit()
    }
    
    private let imageView = UIImageView()
    private let labelName = UILabel()
    private let labelLogin = UILabel()
    private let labelDescription = UILabel()
    private let buttonExit = UIButton(type: .system)
    
    private func setupProfileImage() {
        let profileImage = UIImage(resource: .photo)
        imageView.image = profileImage
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupNameLabel() {
        labelName.text = "Екатерина Новикова"
        labelName.textColor = .ypWhite
        labelName.font = .systemFont(ofSize: 23, weight: .bold)
        
        view.addSubview(labelName)
        labelName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            labelName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
    }
    
    private func setupLoginLabel() {
        labelLogin.text = "@ekaterina_nov"
        labelLogin.textColor = .ypGray
        labelLogin.font = .systemFont(ofSize: 13, weight: .regular)
        
        view.addSubview(labelLogin)
        labelLogin.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelLogin.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 8),
            labelLogin.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
    }
    
    private func setupDescriptionLabel() {
        labelDescription.text = "Hello, world!"
        labelDescription.textColor = .ypWhite
        labelDescription.font = .systemFont(ofSize: 13, weight: .regular)
        
        view.addSubview(labelDescription)
        labelDescription.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelDescription.topAnchor.constraint(equalTo: labelLogin.bottomAnchor, constant: 8),
            labelDescription.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
    }
    
    private func setupButtonExit() {
        buttonExit.setImage(UIImage(resource: .exit), for: .normal)
        buttonExit.tintColor = .ypRed
        
        view.addSubview(buttonExit)
        buttonExit.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonExit.widthAnchor.constraint(equalToConstant: 44),
            buttonExit.heightAnchor.constraint(equalToConstant: 44),
            buttonExit.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            buttonExit.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45)
        ])
    }
}

