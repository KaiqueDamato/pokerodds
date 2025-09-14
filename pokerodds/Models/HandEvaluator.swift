//
//  HandEvaluator.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import Foundation

/// Avaliador de mãos de poker que determina o rank e permite comparações
struct HandEvaluator {
    
    /// Avalia uma mão de 5 a 7 cartas e retorna a melhor mão possível de 5 cartas
    static func evaluateHand(_ cards: [Card]) -> HandEvaluation {
        guard cards.count >= 5 else {
            fatalError("Hand evaluation requires at least 5 cards")
        }
        
        // Se temos exatamente 5 cartas, avalia diretamente
        if cards.count == 5 {
            return evaluateFiveCards(cards)
        }
        
        // Se temos mais de 5 cartas, encontra a melhor combinação de 5
        return findBestFiveCardHand(cards)
    }
    
    /// Encontra a melhor mão de 5 cartas entre todas as combinações possíveis
    private static func findBestFiveCardHand(_ cards: [Card]) -> HandEvaluation {
        var bestHand: HandEvaluation?
        
        // Gera todas as combinações de 5 cartas
        let combinations = generateCombinations(cards, choose: 5)
        
        for combination in combinations {
            let evaluation = evaluateFiveCards(combination)
            
            if bestHand == nil || evaluation > bestHand! {
                bestHand = evaluation
            }
        }
        
        return bestHand!
    }
    
    /// Avalia uma mão de exatamente 5 cartas
    private static func evaluateFiveCards(_ cards: [Card]) -> HandEvaluation {
        let sortedCards = cards.sorted(by: { $0.rank.rawValue > $1.rank.rawValue })
        
        // Verifica cada tipo de mão em ordem de prioridade (da melhor para pior)
        
        if let royalFlush = checkRoyalFlush(sortedCards) {
            return royalFlush
        }
        
        if let straightFlush = checkStraightFlush(sortedCards) {
            return straightFlush
        }
        
        if let fourOfAKind = checkFourOfAKind(sortedCards) {
            return fourOfAKind
        }
        
        if let fullHouse = checkFullHouse(sortedCards) {
            return fullHouse
        }
        
        if let flush = checkFlush(sortedCards) {
            return flush
        }
        
        if let straight = checkStraight(sortedCards) {
            return straight
        }
        
        if let threeOfAKind = checkThreeOfAKind(sortedCards) {
            return threeOfAKind
        }
        
        if let twoPair = checkTwoPair(sortedCards) {
            return twoPair
        }
        
        if let pair = checkPair(sortedCards) {
            return pair
        }
        
        return checkHighCard(sortedCards)
    }
    
    // MARK: - Hand Type Checkers
    
    private static func checkRoyalFlush(_ cards: [Card]) -> HandEvaluation? {
        guard isFlush(cards) else { return nil }
        
        let ranks = cards.map { $0.rank.rawValue }.sorted(by: >)
        let royalRanks = [14, 13, 12, 11, 10] // A, K, Q, J, 10
        
        if ranks == royalRanks {
            return HandEvaluation(rank: .royalFlush, primaryValue: 14, cards: cards)
        }
        
        return nil
    }
    
    private static func checkStraightFlush(_ cards: [Card]) -> HandEvaluation? {
        guard isFlush(cards) && isStraight(cards) else { return nil }
        
        let highCard = getHighCardForStraight(cards)
        return HandEvaluation(rank: .straightFlush, primaryValue: highCard, cards: cards)
    }
    
    private static func checkFourOfAKind(_ cards: [Card]) -> HandEvaluation? {
        let rankCounts = getRankCounts(cards)
        
        for (rank, count) in rankCounts {
            if count == 4 {
                let kicker = rankCounts.keys.first { $0 != rank }!
                return HandEvaluation(
                    rank: .fourOfAKind,
                    primaryValue: rank,
                    kickers: [kicker],
                    cards: cards
                )
            }
        }
        
        return nil
    }
    
    private static func checkFullHouse(_ cards: [Card]) -> HandEvaluation? {
        let rankCounts = getRankCounts(cards)
        var threeRank: Int?
        var pairRank: Int?
        
        for (rank, count) in rankCounts {
            if count == 3 {
                threeRank = rank
            } else if count == 2 {
                pairRank = rank
            }
        }
        
        if let three = threeRank, let pair = pairRank {
            return HandEvaluation(
                rank: .fullHouse,
                primaryValue: three,
                secondaryValue: pair,
                cards: cards
            )
        }
        
        return nil
    }
    
    private static func checkFlush(_ cards: [Card]) -> HandEvaluation? {
        guard isFlush(cards) else { return nil }
        
        let kickers = cards.map { $0.rank.rawValue }.sorted(by: >)
        return HandEvaluation(
            rank: .flush,
            primaryValue: kickers[0],
            kickers: Array(kickers[1...]),
            cards: cards
        )
    }
    
    private static func checkStraight(_ cards: [Card]) -> HandEvaluation? {
        guard isStraight(cards) else { return nil }
        
        let highCard = getHighCardForStraight(cards)
        return HandEvaluation(rank: .straight, primaryValue: highCard, cards: cards)
    }
    
    private static func checkThreeOfAKind(_ cards: [Card]) -> HandEvaluation? {
        let rankCounts = getRankCounts(cards)
        
        for (rank, count) in rankCounts {
            if count == 3 {
                let kickers = rankCounts.keys
                    .filter { $0 != rank }
                    .sorted(by: >)
                
                return HandEvaluation(
                    rank: .threeOfAKind,
                    primaryValue: rank,
                    kickers: kickers,
                    cards: cards
                )
            }
        }
        
        return nil
    }
    
    private static func checkTwoPair(_ cards: [Card]) -> HandEvaluation? {
        let rankCounts = getRankCounts(cards)
        let pairs = rankCounts.filter { $0.value == 2 }.keys.sorted(by: >)
        
        if pairs.count == 2 {
            let kicker = rankCounts.keys.first { !pairs.contains($0) }!
            
            return HandEvaluation(
                rank: .twoPair,
                primaryValue: pairs[0],
                secondaryValue: pairs[1],
                kickers: [kicker],
                cards: cards
            )
        }
        
        return nil
    }
    
    private static func checkPair(_ cards: [Card]) -> HandEvaluation? {
        let rankCounts = getRankCounts(cards)
        
        for (rank, count) in rankCounts {
            if count == 2 {
                let kickers = rankCounts.keys
                    .filter { $0 != rank }
                    .sorted(by: >)
                
                return HandEvaluation(
                    rank: .pair,
                    primaryValue: rank,
                    kickers: kickers,
                    cards: cards
                )
            }
        }
        
        return nil
    }
    
    private static func checkHighCard(_ cards: [Card]) -> HandEvaluation {
        let kickers = cards.map { $0.rank.rawValue }.sorted(by: >)
        
        return HandEvaluation(
            rank: .highCard,
            primaryValue: kickers[0],
            kickers: Array(kickers[1...]),
            cards: cards
        )
    }
    
    // MARK: - Helper Methods
    
    private static func isFlush(_ cards: [Card]) -> Bool {
        let firstSuit = cards.first!.suit
        return cards.allSatisfy { $0.suit == firstSuit }
    }
    
    private static func isStraight(_ cards: [Card]) -> Bool {
        let ranks = cards.map { $0.rank.rawValue }.sorted()
        
        // Verifica sequência normal
        for i in 1..<ranks.count {
            if ranks[i] != ranks[i-1] + 1 {
                // Se não é sequência normal, verifica A-2-3-4-5 (wheel)
                return isWheel(cards)
            }
        }
        
        return true
    }
    
    private static func isWheel(_ cards: [Card]) -> Bool {
        let ranks = Set(cards.map { $0.rank.rawValue })
        return ranks == Set([14, 2, 3, 4, 5]) // A-2-3-4-5
    }
    
    private static func getHighCardForStraight(_ cards: [Card]) -> Int {
        if isWheel(cards) {
            return 5 // Em A-2-3-4-5, o 5 é a carta alta
        }
        
        return cards.map { $0.rank.rawValue }.max()!
    }
    
    private static func getRankCounts(_ cards: [Card]) -> [Int: Int] {
        var counts: [Int: Int] = [:]
        
        for card in cards {
            counts[card.rank.rawValue, default: 0] += 1
        }
        
        return counts
    }
    
    /// Gera todas as combinações de 'choose' elementos de um array
    private static func generateCombinations<T>(_ array: [T], choose: Int) -> [[T]] {
        guard choose <= array.count else { return [] }
        guard choose > 0 else { return [[]] }
        guard choose < array.count else { return [array] }
        
        if choose == 1 {
            return array.map { [$0] }
        }
        
        var result: [[T]] = []
        
        for i in 0...(array.count - choose) {
            let first = array[i]
            let rest = Array(array[(i+1)...])
            let subCombinations = generateCombinations(rest, choose: choose - 1)
            
            for subCombination in subCombinations {
                result.append([first] + subCombination)
            }
        }
        
        return result
    }
}
