//
//  MemoryUIKit.swift
//  Memory
//
//  Created by Ing. Ebu Celik on 27.03.22.
//

import UIKit
import Combine
import ComposableArchitecture

public typealias MemoryViewStore = ViewStore<MemoryState, MemoryAction>

class MemoryUIKitController: UIViewController {

    var store: MemoryStore
    var viewStore: MemoryViewStore
    var cancellable: Set<AnyCancellable> = []

    let memoryUIKitView: MemoryUIKitView = {
        let memoryUIKitView = MemoryUIKitView()
        memoryUIKitView.layoutMargins = .init(top: 0, left: 10, bottom: 0, right: 10)
        memoryUIKitView.translatesAutoresizingMaskIntoConstraints = false
        return memoryUIKitView
    }()

    init(store: MemoryStore) {
        self.store = store
        self.viewStore = ViewStore(store)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .white

        view.addSubview(memoryUIKitView)

        NSLayoutConstraint.activate([
            memoryUIKitView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            memoryUIKitView.topAnchor.constraint(equalTo: view.topAnchor),
            memoryUIKitView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            memoryUIKitView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        setupStateObservers()

        memoryUIKitView.didSelect = { [self] in
            viewStore.send(.openCard(index: $0))
        }

        memoryUIKitView.playAgain = { [self] in
            memoryUIKitView.successfulMessageLabel.isHidden = true
            memoryUIKitView.playAgainButton.isHidden = true
            viewStore.send(.startGame)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.navigationBar.topItem?.title = "Memory"

        setupRightBarButtonItems(chances: viewStore.chances)

        viewStore.send(.startGame)
    }

    func setupStateObservers() {
        viewStore.publisher.memoryCardsStateChanged
            .sink {
                self.memoryCardsStateChanged(state: $0)
            }
            .store(in: &cancellable)

        viewStore.publisher.chances
            .sink {
                self.setupRightBarButtonItems(chances: $0)
            }
            .store(in: &cancellable)

        viewStore.publisher.winOrLost
            .sink { [self] winOrLost in
                switch winOrLost {
                case .win:
                    memoryUIKitView.successfulMessageLabel.text = "Congratulations! \nYou won this game!"
                    viewStore.send(.endGame)

                case .lost:
                    memoryUIKitView.successfulMessageLabel.text = "You lost all your chances. Maybe next time!"
                    viewStore.send(.endGame)

                case .none:
                    break
                }
            }
            .store(in: &cancellable)
    }

    func setupRightBarButtonItems(chances: Int) {
        let rightBarButtonItems: [UIImageView] = {
            (0..<chances).compactMap({ _ in
                let uiImageView = UIImageView(image: UIImage(systemName: "heart.fill"))
                uiImageView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
                uiImageView.contentMode = .scaleAspectFit
                uiImageView.tintColor = .red
                return uiImageView
            })
        }()

        let stackView = UIStackView(arrangedSubviews: rightBarButtonItems)
        stackView.axis = .horizontal
        stackView.spacing = 5

        let barButtonItem = UIBarButtonItem(customView: stackView)
        self.navigationItem.setRightBarButton(barButtonItem, animated: true)
    }

    func memoryCardsStateChanged(state: Loadable<[UIImage]>) {
        switch state {
        case .none, .error, .refreshing:
            memoryUIKitView.loadingIndicator.stopAnimating()
            memoryUIKitView.loadingIndicator.isHidden = true
            memoryUIKitView.collectionView.isHidden = false

        case let .loaded(memoryCards):
            memoryUIKitView.loadingIndicator.stopAnimating()
            memoryUIKitView.loadingIndicator.isHidden = true
            memoryUIKitView.collectionView.isHidden = false
            memoryUIKitView.memoryCards = memoryCards

        case .loading:
            memoryUIKitView.loadingIndicator.startAnimating()
            memoryUIKitView.loadingIndicator.isHidden = false
            memoryUIKitView.collectionView.isHidden = true
        }
    }
}
