//
//  Card.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import Foundation

/// Representa os naipes das cartas de um baralho padrão
enum Suit: Int, CaseIterable, Comparable {
    case spades = 0
    case hearts = 1
    case diamonds = 2
    case clubs = 3
    
    var symbol: String {
        switch self {
        case .spades: return "♠"
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        }
    }
    
    var color: CardColor {
        switch self {
        case .spades, .clubs: return .black
        case .hearts, .diamonds: return .red
        }
    }
    
    static func < (lhs: Suit, rhs: Suit) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// Cor da carta para distinção visual
enum CardColor {
    case red
    case black
}

/// Representa os valores/ranks das cartas
enum Rank: Int, CaseIterable, Comparable {
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case jack = 11
    case queen = 12
    case king = 13
    case ace = 14 // Ás alto por padrão; tratamento especial para Ás baixo em straights
    
    var symbol: String {
        switch self {
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "10"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .ace: return "A"
        }
    }
    
    /// Valor para comparação em straights (A-2-3-4-5)
    var lowAceValue: Int {
        return self == .ace ? 1 : self.rawValue
    }
    
    static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// Representa uma carta individual com rank e suit
struct Card: Hashable, Comparable, Identifiable {
    let suit: Suit
    let rank: Rank
    
    var id: String {
        return "\(rank.symbol)\(suit.symbol)"
    }
    
    /// Representação textual da carta (ex: "A♠", "K♥")
    var description: String {
        return "\(rank.symbol)\(suit.symbol)"
    }
    
    /// Valor numérico único para identificação (usado em algoritmos)
    var numericValue: Int {
        return rank.rawValue * 4 + suit.rawValue
    }
    
    init(suit: Suit, rank: Rank) {
        self.suit = suit
        self.rank = rank
    }
    
    /// Comparação baseada no rank primeiro, depois suit
    static func < (lhs: Card, rhs: Card) -> Bool {
        if lhs.rank != rhs.rank {
            return lhs.rank < rhs.rank
        }
        return lhs.suit < rhs.suit
    }
    
    /// Igualdade baseada em rank e suit
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(suit)
        hasher.combine(rank)
    }
}
