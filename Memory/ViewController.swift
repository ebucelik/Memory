//
//  ViewController.swift
//  Memory
//
//  Created by Ing. Ebu Celik on 20.03.22.
//

import UIKit
import SwiftUI
import SwiftHelper

class ViewController: UIViewController {

    let buttonUIKit: UIButton = {
        let button = UIButton()
        button.setTitle("Open Memory with UIKit", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        return button
    }()

    let buttonSwiftUI: UIButton = {
        let button = UIButton()
        button.setTitle("Open Memory with SwiftUI", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        return button
    }()

    override func viewDidLoad() {
        view.backgroundColor = .white

        buttonUIKit.addTarget(self, action: #selector(openMemoryUIKit), for: .touchUpInside)
        buttonSwiftUI.addTarget(self, action: #selector(openMemorySwiftUI), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [buttonUIKit, buttonSwiftUI])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.layoutMargins = .init(horizontal: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        navigationController?.navigationBar.tintColor = .black
    }

    @objc func openMemoryUIKit() {
        let memoryUIKitController = MemoryUIKitController(store: .init(initialState: MemoryState(),
                                                                       reducer: memoryReducer,
                                                                       environment: MemoryEnvironment()))
        navigationController?.pushViewController(memoryUIKitController, animated: true)
    }

    @objc func openMemorySwiftUI() {
        let memorySwiftUI = UIHostingController(rootView: MemorySwiftUI(store: .init(initialState: MemoryState(),
                                                                                     reducer: memoryReducer,
                                                                                     environment: MemoryEnvironment())))
        navigationController?.pushViewController(memorySwiftUI, animated: true)
    }
}
