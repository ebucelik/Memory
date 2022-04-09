//
//  MemoryUIKitView.swift
//  Memory
//
//  Created by Ing. Ebu Celik on 27.03.22.
//

import UIKit

class MemoryUIKitView: UIView {

    let memoryUIKitCellKey = "MemoryUIKitCell"

    var firstAppearance = true
    var calculateHeightOnce = false

    var didSelect: ((Int) -> Void)?
    var playAgain: (() -> Void)?

    var memoryCards: [UIImage] {
        didSet {

            self.collectionView.reloadData()

            if !calculateHeightOnce {
                self.collectionView.heightAnchor.constraint(equalToConstant: collectionView.collectionViewLayout.collectionViewContentSize.height).isActive = true

                calculateHeightOnce = true
            }

            if memoryCards.isEmpty {
                successfulMessageLabel.isHidden = false
                playAgainButton.isHidden = false
            }
        }
    }

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    let loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.style = .large
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        return loadingIndicator
    }()

    let successfulMessageLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let playAgainButton: UIButton = {
        let button = UIButton()
        button.setTitle("Play again", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        self.memoryCards = []

        super.init(frame: frame)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MemoryUIKitCell.self, forCellWithReuseIdentifier: memoryUIKitCellKey)

        playAgainButton.addTarget(self, action: #selector(playGameAgain), for: .touchUpInside)

        addSubview(loadingIndicator)
        addSubview(collectionView)
        addSubview(successfulMessageLabel)
        addSubview(playAgainButton)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            collectionView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: centerYAnchor),

            successfulMessageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            successfulMessageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),

            playAgainButton.topAnchor.constraint(equalTo: successfulMessageLabel.bottomAnchor, constant: 20),
            playAgainButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playAgainButton.heightAnchor.constraint(equalToConstant: 50),
            playAgainButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func playGameAgain() {
        guard let playAgain = playAgain else {
            return
        }

        firstAppearance = true

        playAgain()
    }
}

extension MemoryUIKitView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        memoryCards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: memoryUIKitCellKey, for: indexPath) as! MemoryUIKitCell

        if firstAppearance {
            cell.alpha = 0
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

            cell.image = memoryCards[indexPath.row]

            let delay = sqrt(Double(indexPath.row)) * 0.2

            UIView.animate(withDuration: 0.3, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 10) {
                cell.alpha = 1
                cell.transform = .identity
            }

            if indexPath.row >= memoryCards.count - 1 {
                firstAppearance = false
            }
        } else {
            cell.image = memoryCards[indexPath.row]
        }

        return cell
    }
}

extension MemoryUIKitView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: bounds.width / 3.6, height: bounds.width / 3.6)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let didSelect = self.didSelect else { return }

        didSelect(indexPath.row)
    }
}
