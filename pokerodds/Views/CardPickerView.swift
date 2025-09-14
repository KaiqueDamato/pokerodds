//
//  CardPickerView.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import SwiftUI

struct CardPickerView: View {
    let selectedCards: [Card]
    let position: OddsViewModel.CardPosition
    let onCardSelected: (Card) -> Void
    let onCancel: () -> Void
    
    private let deck = Deck()
    
    // Grid layout: 13 ranks × 4 suits
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 13)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Suits header  
                suitsHeaderView
                
                // Cards grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Rank.allCases.reversed(), id: \.self) { rank in
                            ForEach(Suit.allCases, id: \.self) { suit in
                                let card = Card(suit: suit, rank: rank)
                                CardPickerButton(
                                    card: card,
                                    isSelected: false,
                                    isDisabled: selectedCards.contains(card),
                                    onTap: {
                                        selectCard(card)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(NSLocalizedString("Select Card", comment: "Card picker title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("Cancel", comment: "Cancel button")) {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Clear Selection", comment: "Clear selection button")) {
                        // Remove the card from current position by selecting nil equivalent
                        onCancel()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text(position.description)
                .font(.headline)
                .foregroundColor(.primary)
            
            if !selectedCards.isEmpty {
                Text(NSLocalizedString("Used cards are grayed out", comment: "Instruction text"))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Suits Header View
    
    private var suitsHeaderView: some View {
        HStack(spacing: 0) {
            // Ranks column space
            Text("")
                .frame(width: 40)
            
            // Suits headers
            ForEach(Suit.allCases, id: \.self) { suit in
                Text(suit.symbol)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(suit.color == .red ? .red : .black)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.secondary.opacity(0.3)),
            alignment: .bottom
        )
    }
    
    // MARK: - Helper Methods
    
    private func selectCard(_ card: Card) {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Notify selection
        onCardSelected(card)
    }
}

// MARK: - Card Picker Button

struct CardPickerButton: View {
    let card: Card
    let isSelected: Bool
    let isDisabled: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if !isDisabled {
                onTap()
            } else {
                // Haptic feedback for disabled cards
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.warning)
            }
        }) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
                    )
                
                VStack(spacing: 2) {
                    // Rank
                    Text(card.rank.symbol)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(textColor)
                    
                    // Suit
                    Text(card.suit.symbol)
                        .font(.system(size: 16))
                        .foregroundColor(textColor)
                }
            }
        }
        .frame(height: 60)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(isDisabled ? 0.4 : 1.0)
        .allowsHitTesting(!isDisabled)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            if !UIAccessibility.isReduceMotionEnabled && !isDisabled {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            }
        }, perform: {})
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(card.description)
        .accessibilityHint(isDisabled ?
            NSLocalizedString("Card already selected", comment: "Disabled card hint") :
            NSLocalizedString("Tap to select this card", comment: "Card selection hint")
        )
        .accessibilityAddTraits(isDisabled ? [] : .isButton)
    }
    
    // MARK: - Computed Properties
    
    private var backgroundColor: Color {
        if isDisabled {
            return Color(.systemGray5)
        } else if isSelected {
            return Color.accentColor.opacity(0.1)
        } else {
            return Color(.systemBackground)
        }
    }
    
    private var borderColor: Color {
        if isDisabled {
            return Color(.systemGray4)
        } else if isSelected {
            return Color.accentColor
        } else {
            return Color(.systemGray4)
        }
    }
    
    private var textColor: Color {
        if isDisabled {
            return Color(.systemGray3)
        } else if card.suit.color == .red {
            return .red
        } else {
            return .black
        }
    }
}

// MARK: - Preview

struct CardPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CardPickerView(
            selectedCards: [
                Card(suit: .spades, rank: .ace),
                Card(suit: .hearts, rank: .king)
            ],
            position: .playerCard(0),
            onCardSelected: { _ in },
            onCancel: {}
        )
        
        CardPickerView(
            selectedCards: [],
            position: .communityCard(3),
            onCardSelected: { _ in },
            onCancel: {}
        )
        .preferredColorScheme(.dark)
    }
}
