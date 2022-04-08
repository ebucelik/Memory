//
//  MemoryUIKitCore.swift
//  Memory
//
//  Created by Ing. Ebu Celik on 28.03.22.
//

import Combine
import ComposableArchitecture
import UIKit

public struct MemoryUIKitState: Equatable {
    var defaultMemoryCard = UIImage(named: "pokerBackground")!
    var emptyMemoryCard = UIImage()

    var memoryCards: [UIImage] = []
    var memoryCardsStateChanged: Loadable<[UIImage]> = .none

    var memoryCardsState: [UIImage] = []
}

public enum MemoryUIKitAction {
    case startGame
    case assignAllCards
    case openCard(index: Int)
    case compareTwoCards(firstCard: UIImage, secondCard: UIImage)
    case closeAllCards
    case endGame
}

public struct MemoryUIKitEnvironment {}

let memoryUIKitReducer = Reducer<MemoryUIKitState, MemoryUIKitAction, MemoryUIKitEnvironment> { state, action, _ in
    switch action {
    case .startGame:
        struct GameID: Hashable {}

        state.memoryCardsStateChanged = .loading

        return Effect(value: .assignAllCards)
            .debounce(id: GameID(), for: 1.0, scheduler: DispatchQueue.main)

    case .assignAllCards:
        struct GameID: Hashable {}

        let images = ["boat", "camper", "flight", "helicopter", "sportive-car", "trailer"]
        var memoryCards: [UIImage] = []

        for index in 0...5 {
            memoryCards.append(UIImage(named: images[index]) ?? state.emptyMemoryCard)
            memoryCards.append(UIImage(named: images[index]) ?? state.emptyMemoryCard)
        }

        let shuffledMemoryCards = memoryCards.shuffled()

        state.memoryCardsStateChanged = .loaded(shuffledMemoryCards)
        state.memoryCards = shuffledMemoryCards

        return Effect(value: .closeAllCards)
            .debounce(id: GameID(), for: 3.0, scheduler: DispatchQueue.main)

    case let .openCard(index):
        struct GameId: Hashable {}

        if state.memoryCardsState[index] == state.emptyMemoryCard {
            return .none
        }

        let image = state.memoryCards[index]

        if !state.memoryCardsState.isEmpty {
            state.memoryCardsState[index] = image
            state.memoryCardsStateChanged = .loaded(state.memoryCardsState)

            let openedMemoryCards = state.memoryCardsState.filter({ $0 != state.defaultMemoryCard && $0 != state.emptyMemoryCard })

            if openedMemoryCards.count == 2 {
                return Effect(value: .compareTwoCards(firstCard: openedMemoryCards[0], secondCard: openedMemoryCards[1]))
                    .debounce(id: GameId(), for: 1, scheduler: DispatchQueue.main)
            }
        }

        return .none

    case let .compareTwoCards(firstCard, secondCard):

        var indices: [Int] = []

        _ = state.memoryCardsState.enumerated().compactMap({ index, element in
            if element == firstCard || element == secondCard {
                indices.append(index)
            }
        })

        if firstCard == secondCard {
            state.memoryCardsState[indices[0]] = state.emptyMemoryCard
            state.memoryCardsState[indices[1]] = state.emptyMemoryCard
        } else {
            state.memoryCardsState[indices[0]] = state.defaultMemoryCard
            state.memoryCardsState[indices[1]] = state.defaultMemoryCard
        }

        state.memoryCardsStateChanged = .loaded(state.memoryCardsState)

        if state.memoryCardsState.filter({ $0 != state.emptyMemoryCard }).count <= 0 {
            return Effect(value: .endGame)
        }

        return .none

    case .closeAllCards:

        var closedMemoryCards: [UIImage] = []

        for _ in 0...11 {
            closedMemoryCards.append(state.defaultMemoryCard)
        }

        state.memoryCardsStateChanged = .loaded(closedMemoryCards)
        state.memoryCardsState = closedMemoryCards

        return .none

    case .endGame:
        state.memoryCardsState = []
        state.memoryCardsStateChanged = .loaded(state.memoryCardsState)

        return .none
    }
}
