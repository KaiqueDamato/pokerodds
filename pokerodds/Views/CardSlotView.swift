//
//  CardSlotView.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import SwiftUI

struct CardSlotView: View {
    let card: Card?
    let position: OddsViewModel.CardPosition
    let onTap: () -> Void
    let onRemove: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    private let cardSize = CGSize(width: 60, height: 84)
    
    var body: some View {
        Group {
            if let card = card {
                cardView(card)
            } else {
                emptySlotView
            }
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            if !UIAccessibility.isReduceMotionEnabled {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
            }
            
            onTap()
        }
    }
    
    // MARK: - Card View
    
    private func cardView(_ card: Card) -> some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("CardBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            Color("CardBorder"),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            VStack(spacing: 2) {
                // Rank
                Text(card.rank.symbol)
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(card.suit.color == .red ? .red : .black)
                
                // Suit
                Text(card.suit.symbol)
                    .font(.system(size: 20))
                    .foregroundColor(card.suit.color == .red ? .red : .black)
            }
            
            // Remove button (X)
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .background(Color.white.clipShape(Circle()))
                    }
                    .offset(x: 6, y: -6)
                    .accessibilityLabel(NSLocalizedString("Remove card", comment: "Remove card button"))
                }
                
                Spacer()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(card.description) - \(position.description)")
        .accessibilityHint(NSLocalizedString("Tap to change card", comment: "Card accessibility hint"))
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Empty Slot View
    
    private var emptySlotView: some View {
        ZStack {
            // Dashed border background
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 2,
                        lineCap: .round,
                        dash: [6, 4]
                    )
                )
                .foregroundColor(.secondary.opacity(0.6))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
                )
            
            VStack(spacing: 8) {
                // Plus icon
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                // Position label
                Text(positionLabel)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(NSLocalizedString("Empty card slot - \(position.description)", comment: "Empty slot accessibility"))
        .accessibilityHint(NSLocalizedString("Tap to select a card", comment: "Empty slot accessibility hint"))
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Helpers
    
    private var positionLabel: String {
        switch position {
        case .playerCard(let index):
            return index == 0 ?
                NSLocalizedString("Card 1", comment: "Player card 1") :
                NSLocalizedString("Card 2", comment: "Player card 2")
        case .communityCard(let index):
            switch index {
            case 0: return NSLocalizedString("Flop 1", comment: "Community card position")
            case 1: return NSLocalizedString("Flop 2", comment: "Community card position")
            case 2: return NSLocalizedString("Flop 3", comment: "Community card position")
            case 3: return NSLocalizedString("Turn", comment: "Community card position")
            case 4: return NSLocalizedString("River", comment: "Community card position")
            default: return NSLocalizedString("Card", comment: "Generic card")
            }
        }
    }
}

// MARK: - Preview

struct CardSlotView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Empty slot
                CardSlotView(
                    card: nil,
                    position: .playerCard(0),
                    onTap: {},
                    onRemove: {}
                )
                
                // Card slot
                CardSlotView(
                    card: Card(suit: .spades, rank: .ace),
                    position: .playerCard(1),
                    onTap: {},
                    onRemove: {}
                )
            }
            
            HStack(spacing: 12) {
                // Community cards
                CardSlotView(
                    card: Card(suit: .hearts, rank: .king),
                    position: .communityCard(0),
                    onTap: {},
                    onRemove: {}
                )
                
                CardSlotView(
                    card: nil,
                    position: .communityCard(3),
                    onTap: {},
                    onRemove: {}
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .previewLayout(.sizeThatFits)
        
        // Dark mode preview
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                CardSlotView(
                    card: nil,
                    position: .playerCard(0),
                    onTap: {},
                    onRemove: {}
                )
                
                CardSlotView(
                    card: Card(suit: .diamonds, rank: .queen),
                    position: .playerCard(1),
                    onTap: {},
                    onRemove: {}
                )
            }
        }
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
