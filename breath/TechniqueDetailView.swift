//
//  TechniqueDetailView.swift
//  breath
//
//  Created by pc on 24.06.25.
//

import SwiftUI

struct TechniqueDetailView: View {
    let technique: BreathingTechnique
    
    @State private var selectedSessionLength: SessionLength = .medium
    @State private var selectedDifficulty: ExperienceLevel
    @State private var showingSession = false
    
    // Computed property for durations based on difficulty
    private var adjustedDurations: [BreathingTechnique.BreathPhase: Double] {
        var newDurations: [BreathingTechnique.BreathPhase: Double] = [:]
        for (phase, duration) in technique.t {
            newDurations[phase] = duration * selectedDifficulty.multiplier
        }
        return newDurations
    }
    
    init(technique: BreathingTechnique) {
        self.technique = technique
        self._selectedDifficulty = State(initialValue: technique.difficulty)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text(technique.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.inAppLabel)
                    
                    HStack(spacing: 12) {
                        CategoryBadge(category: technique.category)
                        DifficultyBadge(difficulty: technique.difficulty)
                        DurationBadge(duration: technique.totalDuration)
                    }
                }
                
                // Description
                VStack(alignment: .leading, spacing: 12) {
                    Text("Description")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.inAppLabel)
                    
                    Text(technique.description)
                        .font(.body)
                        .foregroundColor(.inAppSecondaryLabel)
                        .lineSpacing(4)
                }
                
                // Benefits
                VStack(alignment: .leading, spacing: 12) {
                    Text("Benefits")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.inAppLabel)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(technique.benefits, id: \.self) { benefit in
                                BenefitCard(benefit: benefit)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                // Tags
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tags")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.inAppLabel)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(technique.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .foregroundColor(.inAppSecondaryLabel)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.inAppTertiarySystemBackground)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                // Setup Block
                VStack(alignment: .leading, spacing: 20) {
                    // Session Length
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Session Length")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.inAppLabel)
                        
                        HStack(spacing: 12) {
                            ForEach(SessionLength.allCases, id: \.self) { length in
                                SessionLengthCard(
                                    length: length,
                                    isSelected: selectedSessionLength == length,
                                    action: { selectedSessionLength = length }
                                )
                            }
                        }
                    }
                    
                    // Difficulty Level
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Difficulty Level")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.inAppLabel)
                        
                        HStack(spacing: 12) {
                            ForEach(ExperienceLevel.allCases, id: \.self) { difficulty in
                                DifficultyCard(
                                    difficulty: difficulty,
                                    isSelected: selectedDifficulty == difficulty,
                                    action: { selectedDifficulty = difficulty }
                                )
                            }
                        }
                    }
                    
                    // Breathing Pattern
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Breathing Pattern")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.inAppLabel)
                        
                        BreathingPatternView(durations: adjustedDurations)
                    }
                    
                    // Start Session Button
                    Button(action: {
                        showingSession = true
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Session")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.inAppBlue)
                        .cornerRadius(16)
                    }
                }
                .padding(20)
                .background(Color.inAppSecondarySystemBackground)
                .cornerRadius(16)
            }
            .padding(32)
        }
        .background(Color.inAppSystemBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingSession) {
            SessionPlayView(
                techniqueSetup: TechniqueSetup(
                    technique: technique,
                    customDurations: adjustedDurations,
                    customTotalDuration: selectedSessionLength.minutes,
                    customDifficulty: selectedDifficulty
                )
            )
        }
    }
}

struct CategoryBadge: View {
    let category: BreathingTechnique.BreathingTechniqueTypes
    
    var body: some View {
        Text(category.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.inAppBlue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.inAppBlue.opacity(0.1))
            .cornerRadius(12)
    }
}

struct DifficultyBadge: View {
    let difficulty: ExperienceLevel
    
    var body: some View {
        Text(difficulty.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.inAppOrange)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.inAppOrange.opacity(0.1))
            .cornerRadius(12)
    }
}

struct DurationBadge: View {
    let duration: Int
    
    var body: some View {
        Text("\(duration) min")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.inAppGreen)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.inAppGreen.opacity(0.1))
            .cornerRadius(12)
    }
}

struct BenefitCard: View {
    let benefit: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.inAppGreen)
                .font(.caption)
            Text(benefit)
                .font(.caption)
                .foregroundColor(.inAppSecondaryLabel)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.inAppTertiarySystemBackground)
        .cornerRadius(8)
    }
}

struct BreathingPatternView: View {
    let durations: [BreathingTechnique.BreathPhase: Double]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                ForEach(BreathingTechnique.BreathPhase.allCases, id: \.self) { phase in
                    VStack(spacing: 4) {
                        ZStack {
                            Image(balloonImageName(for: phase))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .opacity((durations[phase] ?? 0) > 0 ? 1.0 : 0.3)
                        }
                        
                        Text(phase.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.inAppSecondaryLabel)
                            .opacity((durations[phase] ?? 0) > 0 ? 1.0 : 0.3)
                        
                        HStack(spacing: 4) {
                            Image(systemName: phase.phaseIcon)
                                .font(.caption2)
                                .foregroundColor(.inAppSecondaryLabel)
                                .opacity((durations[phase] ?? 0) > 0 ? 1.0 : 0.3)
                            
                            Text("\(durations[phase] ?? 0, specifier: "%.1f")s")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.inAppLabel)
                        }
                    }
                }
            }
            
            // Pattern visualization
            HStack(spacing: 4) {
                ForEach(BreathingTechnique.BreathPhase.allCases, id: \.self) { phase in
                    Rectangle()
                        .fill((durations[phase] ?? 0) > 0 ? phaseColor(for: phase) : Color.inAppLabel.opacity(0.1))
                        .frame(height: 8)
                        .cornerRadius(4)
                        .frame(width: max(CGFloat(durations[phase] ?? 0) * 10, 4)) // Minimum width for visibility
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(8)
        .background(Color.inAppTertiarySystemBackground)
        .cornerRadius(16)
    }
    
    private func phaseColor(for phase: BreathingTechnique.BreathPhase) -> Color {
        switch phase {
        case .inhale: return .inhaleColor
        case .holdIn: return .holdInColor
        case .exhale: return .exhaleColor
        case .holdOut: return .holdOutColor
        }
    }
    
    private func balloonImageName(for phase: BreathingTechnique.BreathPhase) -> String {
        switch phase {
        case .inhale: return .inhaleBalloon
        case .holdIn: return .holdInBalloon
        case .exhale: return .exhaleBalloon
        case .holdOut: return .holdOutBalloon
        }
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        let positions: [CGPoint]
        let size: CGSize
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var currentPosition = CGPoint.zero
            var lineHeight: CGFloat = 0
            var maxWidth = maxWidth
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentPosition.x + size.width > maxWidth && currentPosition.x > 0 {
                    currentPosition.x = 0
                    currentPosition.y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(currentPosition)
                currentPosition.x += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.positions = positions
            self.size = CGSize(width: maxWidth, height: currentPosition.y + lineHeight)
        }
    }
}

// Helper views from SessionSetupView, now used here
struct SessionLengthCard: View {
    let length: SessionLength
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(length.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .inAppLabel)
                
                Text("\(length.minutes) min")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .inAppSecondaryLabel)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.inAppBlue : Color.inAppTertiarySystemBackground)
            .cornerRadius(12)
        }
    }
}

struct DifficultyCard: View {
    let difficulty: ExperienceLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(difficulty.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .inAppLabel)
                
                Text("×\(String(format: "%.1f", difficulty.multiplier))")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .inAppSecondaryLabel)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.inAppOrange : Color.inAppTertiarySystemBackground)
            .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationView {
        TechniqueDetailView(technique: loadTechniques().first!)
    }
    .preferredColorScheme(.dark)
} 
