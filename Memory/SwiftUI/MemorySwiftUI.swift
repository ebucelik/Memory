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
                    ScrollView {
                        VStack {
                            HStack {
                                Text("Memory")
                                    .font(.largeTitle.bold())

                                Spacer()

                                ForEach(0..<viewStore.chances, id: \.self) { _ in
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()

                            switch viewStore.winOrLost {
                            case .win:
                                playAgainButton(viewStore, text: "Congratulations! \nYou won this game!")

                            case .lost:
                                playAgainButton(viewStore, text: "You lost all your chances. Maybe next time!")

                            case .none:
                                stateBody(viewStore, geometry)
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
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
            Spacer(minLength: 150)
            Text("Error.")

        case .none, .loading, .refreshing:
            Spacer(minLength: 150)
            ProgressView("Memory cards will be shuffled...")

        case let .loaded(memoryCards):
            VStack(spacing: 0) {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<memoryCards.count, id: \.self) { index in
                        Button(action: {
                            viewStore.send(.openCard(index: index))
                        }) {
                            Image(uiImage: memoryCards[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: geometryProxy.size.width / 4,
                                       maxHeight: geometryProxy.size.width / 4)

                        }
                        .opacity(showMemoryCard ? 1 : 0)
                        .animation(Animation.easeInOut(duration: 0.3).delay(animationDelay * Double(index)),
                                   value: showMemoryCard)
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    showMemoryCard.toggle()
                }
            }
        }
    }

    @ViewBuilder
    func playAgainButton(_ viewStore: MemoryViewStore, text: String) -> some View {
        Spacer(minLength: 150)

        HStack {
            Text(text)
                .multilineTextAlignment(.center)

            if case .win = viewStore.winOrLost {
                Image(systemName: "face.smiling")
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
                    .padding()
            }
        }
        .padding()

        Button(action: {
            viewStore.send(.startGame)
            showMemoryCard = false
        }) {
            Text("Play again").frame(maxWidth: 100)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.black, lineWidth: 1))
        }
    }
}
