//
//  MemorySwiftUI.swift
//  Memory
//
//  Created by Ing. Ebu Celik on 27.03.22.
//

import SwiftUI
import Combine
import ComposableArchitecture

public typealias MemoryStore = Store<MemoryState, MemoryAction>

struct MemorySwiftUI: View {

    @State
    var showMemoryCard = false

    let animationDelay = 0.1
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
                        stateBody(viewStore, geometry)
                    }
                    .navigationTitle("Memory")
                }
            }
            .onAppear {
                viewStore.send(.startGame)
            }
        }
    }

    @ViewBuilder
    func stateBody(_ viewStore: MemoryViewStore, _ geometryProxy: GeometryProxy) -> some View {
        switch viewStore.memoryCardsStateChanged {
        case .error:
            Text("Error.")

        case .none, .loading, .refreshing:
            ProgressView("Memory cards will be shuffled...")

        case let .loaded(memoryCards):
            VStack(spacing: 0) {
                if memoryCards.isEmpty {
                    Button(action: {
                        viewStore.send(.startGame)
                        showMemoryCard = false
                    }) {
                        Text("Play again")
                            .frame(maxWidth: 100)
                            .padding()
                            .foregroundColor(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.black, lineWidth: 1)
                            )
                    }
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(0..<memoryCards.count, id: \.self) { index in
                            Button(action: {
                                viewStore.send(.openCard(index: index))
                            }) {
                                Image(uiImage: memoryCards[index])
                                    .resizable()
                                    .frame(maxWidth: geometryProxy.size.width / 4, maxHeight: geometryProxy.size.width / 4)
                            }
                            .opacity(showMemoryCard ? 1 : 0)
                            .animation(Animation.easeInOut(duration: 0.3).delay(animationDelay * Double(index)), value: showMemoryCard)
                        }
                    }
                    .padding(.horizontal)
                    .onAppear {
                        showMemoryCard.toggle()
                    }

                    Spacer()
                }
            }
        }
    }
}
