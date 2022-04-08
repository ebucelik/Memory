//
//  MemorySwiftUI.swift
//  Memory
//
//  Created by Ing. Ebu Celik on 27.03.22.
//

import SwiftUI
import Combine
import ComposableArchitecture

public typealias MemoryStore = Store<MemoryUIKitState, MemoryUIKitAction>

struct MemorySwiftUI: View {

    let store: MemoryStore

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @State
    var memoryCards: [UIImage] = []

    var body: some View {
        return WithViewStore(store) { viewStore in
            GeometryReader { geometry in
                NavigationView {
                    VStack {
                        switch viewStore.memoryCardsStateChanged {
                        case .error:
                            Text("Error.")

                        case .none, .loading, .refreshing:
                            ProgressView("Memory cards will be shuffled...")

                        case let .loaded(memoryCards):
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(0..<memoryCards.count, id: \.self) {
                                    Image(uiImage: memoryCards[$0])
                                        .resizable()
                                        .frame(maxWidth: geometry.size.width / 3.8, maxHeight: geometry.size.width / 3.8)
                                }
                            }
                            .padding(.horizontal)

                            Spacer()
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.startGame)
            }
        }
    }

//    @ViewBuilder
//    func stateBody(_ viewStore: MemoryStore) -> some View {
//
//    }
}
