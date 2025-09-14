//
//  ResultCardView.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import SwiftUI

struct ResultCardView: View {
    let result: SimulationResult
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            headerView
            
            // Results grid
            resultsGrid
            
            // Summary info
            summaryView
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 4) {
            Text(NSLocalizedString("Simulation Results", comment: "Results header"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(NSLocalizedString("\(NumberFormatter.localizedString(from: NSNumber(value: result.totalSimulations), number: .decimal)) scenarios analyzed", comment: "Scenarios count"))
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Results Grid
    
    private var resultsGrid: some View {
        VStack(spacing: 16) {
            // Win result
            ResultRowView(
                title: NSLocalizedString("Win", comment: "Win result"),
                percentage: result.winPercentage,
                count: result.wins,
                total: result.totalSimulations,
                color: Color("WinColor"),
                isWin: true
            )
            
            // Tie result
            ResultRowView(
                title: NSLocalizedString("Tie", comment: "Tie result"),
                percentage: result.tiePercentage,
                count: result.ties,
                total: result.totalSimulations,
                color: Color("TieColor"),
                isWin: false
            )
            
            // Loss result
            ResultRowView(
                title: NSLocalizedString("Loss", comment: "Loss result"),
                percentage: result.lossPercentage,
                count: result.losses,
                total: result.totalSimulations,
                color: Color("LossColor"),
                isWin: false
            )
        }
    }
    
    // MARK: - Summary View
    
    private var summaryView: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack {
                Text(NSLocalizedString("Execution Time", comment: "Execution time label"))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(String(format: "%.1f%@", result.elapsedTime, NSLocalizedString("s", comment: "seconds abbreviation")))
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            // Odds ratio for wins vs losses (excluding ties)
            if result.wins > 0 && result.losses > 0 {
                HStack {
                    Text(NSLocalizedString("Win/Loss Ratio", comment: "Win loss ratio label"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(winLossRatioText)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var winLossRatioText: String {
        let ratio = Double(result.wins) / Double(result.losses)
        return String(format: "%.1f:1", ratio)
    }
    
    private var accessibilityDescription: String {
        return String(
            format: NSLocalizedString("Simulation results: Win %@, Tie %@, Loss %@", comment: "Results accessibility"),
            formatPercentage(result.winPercentage),
            formatPercentage(result.tiePercentage),
            formatPercentage(result.lossPercentage)
        )
    }
    
    private func formatPercentage(_ value: Double) -> String {
        return String(format: "%.1f%%", value)
    }
}

// MARK: - Result Row View

struct ResultRowView: View {
    let title: String
    let percentage: Double
    let count: Int
    let total: Int
    let color: Color
    let isWin: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Title and percentage
            HStack {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(String(format: "%.1f%%", percentage))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                        .frame(height: 8)
                    
                    // Filled portion
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * (percentage / 100.0), height: 8)
                        .animation(.easeInOut(duration: UIAccessibility.isReduceMotionEnabled ? 0 : 0.6), value: percentage)
                }
            }
            .frame(height: 8)
            
            // Count information
            HStack {
                Text(String(format: NSLocalizedString("%@ scenarios", comment: "Scenario count"), NumberFormatter.localizedString(from: NSNumber(value: count), number: .decimal)))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title): \(String(format: "%.1f%%", percentage))")
        .accessibilityValue(String(format: NSLocalizedString("%@ out of %@ scenarios", comment: "Accessibility scenario count"), NumberFormatter.localizedString(from: NSNumber(value: count), number: .decimal), NumberFormatter.localizedString(from: NSNumber(value: total), number: .decimal)))
    }
}

// MARK: - Preview

struct ResultCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleResult = SimulationResult(
            wins: 12750,
            ties: 1200,
            losses: 6050,
            totalSimulations: 20000,
            elapsedTime: 1.2
        )
        
        VStack {
            ResultCardView(result: sampleResult)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
        
        // Dark mode preview
        VStack {
            ResultCardView(result: sampleResult)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        
        // Different scenario - close match
        let closeResult = SimulationResult(
            wins: 9800,
            ties: 500,
            losses: 9700,
            totalSimulations: 20000,
            elapsedTime: 0.8
        )
        
        VStack {
            ResultCardView(result: closeResult)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
