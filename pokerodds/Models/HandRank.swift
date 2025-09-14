//
//  HandRank.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import Foundation

/// Classificação das mãos de poker em ordem hierárquica
enum HandRank: Int, Comparable, CaseIterable {
    case highCard = 0
    case pair = 1
    case twoPair = 2
    case threeOfAKind = 3
    case straight = 4
    case flush = 5
    case fullHouse = 6
    case fourOfAKind = 7
    case straightFlush = 8
    case royalFlush = 9
    
    var name: String {
        switch self {
        case .highCard:
            return NSLocalizedString("High Card", comment: "Hand rank name")
        case .pair:
            return NSLocalizedString("Pair", comment: "Hand rank name")
        case .twoPair:
            return NSLocalizedString("Two Pair", comment: "Hand rank name")
        case .threeOfAKind:
            return NSLocalizedString("Three of a Kind", comment: "Hand rank name")
        case .straight:
            return NSLocalizedString("Straight", comment: "Hand rank name")
        case .flush:
            return NSLocalizedString("Flush", comment: "Hand rank name")
        case .fullHouse:
            return NSLocalizedString("Full House", comment: "Hand rank name")
        case .fourOfAKind:
            return NSLocalizedString("Four of a Kind", comment: "Hand rank name")
        case .straightFlush:
            return NSLocalizedString("Straight Flush", comment: "Hand rank name")
        case .royalFlush:
            return NSLocalizedString("Royal Flush", comment: "Hand rank name")
        }
    }
    
    static func < (lhs: HandRank, rhs: HandRank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// Resultado da avaliação de uma mão, incluindo rank e kickers para desempate
struct HandEvaluation: Comparable {
    let rank: HandRank
    let primaryValue: Int      // Valor principal (ex: valor da trinca no full house)
    let secondaryValue: Int    // Valor secundário (ex: valor do par no full house)
    let kickers: [Int]         // Cartas de desempate ordenadas do maior para o menor
    let cards: [Card]          // As 5 melhores cartas que formam a mão
    
    init(rank: HandRank, primaryValue: Int = 0, secondaryValue: Int = 0, kickers: [Int] = [], cards: [Card]) {
        self.rank = rank
        self.primaryValue = primaryValue
        self.secondaryValue = secondaryValue
        self.kickers = kickers.sorted(by: >)  // Ordena kickers do maior para menor
        self.cards = cards
    }
    
    /// Comparação para determinar qual mão é melhor
    static func < (lhs: HandEvaluation, rhs: HandEvaluation) -> Bool {
        // Primeiro compara o rank da mão
        if lhs.rank != rhs.rank {
            return lhs.rank < rhs.rank
        }
        
        // Se o rank é igual, compara valores primários
        if lhs.primaryValue != rhs.primaryValue {
            return lhs.primaryValue < rhs.primaryValue
        }
        
        // Se valores primários são iguais, compara valores secundários
        if lhs.secondaryValue != rhs.secondaryValue {
            return lhs.secondaryValue < rhs.secondaryValue
        }
        
        // Se ainda empata, compara kickers um por um
        for i in 0..<min(lhs.kickers.count, rhs.kickers.count) {
            if lhs.kickers[i] != rhs.kickers[i] {
                return lhs.kickers[i] < rhs.kickers[i]
            }
        }
        
        // Se chegou aqui, as mãos são idênticas (empate verdadeiro)
        return false
    }
    
    static func == (lhs: HandEvaluation, rhs: HandEvaluation) -> Bool {
        return lhs.rank == rhs.rank &&
               lhs.primaryValue == rhs.primaryValue &&
               lhs.secondaryValue == rhs.secondaryValue &&
               lhs.kickers == rhs.kickers
    }
}
