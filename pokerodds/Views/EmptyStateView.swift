//
//  EmptyStateView.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "rectangle.on.rectangle")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.accentColor)
            }
            
            // Text content
            VStack(spacing: 8) {
                Text(NSLocalizedString("Ready to Calculate", comment: "Empty state title"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(NSLocalizedString("Select your 2 hole cards to get started", comment: "Empty state message"))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(NSLocalizedString("Community cards are optional", comment: "Empty state hint"))
                    .font(.footnote)
                    .foregroundColor(.secondary.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(NSLocalizedString("Ready to calculate poker odds. Select your 2 hole cards to get started. Community cards are optional.", comment: "Empty state accessibility"))
    }
}

// MARK: - Preview

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EmptyStateView()
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
        
        // Dark mode preview
        VStack {
            EmptyStateView()
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
