//
//  LibraryView.swift
//  breath
//
//  Created by pc on 24.06.25.
//

import SwiftUI

struct LibraryView: View {
    @State private var techniques: [BreathingTechnique] = []
    @State private var selectedCategory: BreathingTechnique.BreathingTechniqueTypes?
    @State private var selectedDifficulty: ExperienceLevel?
    @State private var selectedBenefits: Set<String> = []
    
    private var filteredTechniques: [BreathingTechnique] {
        var filtered = techniques
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by difficulty
        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }
        
        // Filter by benefits
        if !selectedBenefits.isEmpty {
            filtered = filtered.filter { technique in
                !Set(technique.benefits).isDisjoint(with: selectedBenefits)
            }
        }
        
        // Sort by likes
        return filtered.sortedByLikes()
    }
    
    private var allBenefits: [String] {
        Array(Set(techniques.flatMap { $0.benefits })).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(allBenefits, id: \.self) { benefit in
                                    FilterChip(
                                        title: benefit,
                                        isSelected: selectedBenefits.contains(benefit),
                                        action: {
                                            if selectedBenefits.contains(benefit) {
                                                selectedBenefits.remove(benefit)
                                            } else {
                                                selectedBenefits.insert(benefit)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(filteredTechniques) { technique in
                            TechniqueCard(
                                technique: technique,
                                onLikeTap: {
                                    if let index = techniques.firstIndex(where: { $0.id == technique.id }) {
                                        techniques[index].isLiked.toggle()
                                    }
                                }
                            )
                            .overlay(
                                NavigationLink(destination: TechniqueDetailView(technique: technique)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.inAppSystemBackground.ignoresSafeArea())
            .navigationTitle("BreathFlow")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Menu("Category") {
                            Button("All Categories") {
                                selectedCategory = nil
                            }
                            ForEach(BreathingTechnique.BreathingTechniqueTypes.allCases, id: \.self) { category in
                                Button(category.displayName) {
                                    selectedCategory = category
                                }
                            }
                        }
                        
                        Menu("Difficulty") {
                            Button("All Difficulties") {
                                selectedDifficulty = nil
                            }
                            ForEach(ExperienceLevel.allCases, id: \.self) { difficulty in
                                Button(difficulty.displayName) {
                                    selectedDifficulty = difficulty
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.inAppLabel)
                    }
                }
            }
        }
        .onAppear {
            techniques = loadTechniques()
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.inAppBlue : Color.inAppTertiarySystemBackground)
                .foregroundColor(isSelected ? .white : .inAppLabel)
                .cornerRadius(20)
        }
    }
}

struct TechniqueCard: View {
    let technique: BreathingTechnique
    let onLikeTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(technique.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.inAppLabel)
                    
                    Text(technique.category.displayName)
                        .font(.caption)
                        .foregroundColor(.inAppBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.inAppBlue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Button(action: onLikeTap) {
                        Image(systemName: technique.isLiked ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(technique.isLiked ? .red : .inAppSecondaryLabel)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text(technique.difficulty.displayName)
                        .font(.caption)
                        .foregroundColor(.inAppOrange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.inAppOrange.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            Text(technique.description)
                .font(.subheadline)
                .foregroundColor(.inAppSecondaryLabel)
                .lineLimit(2)
            
            // Benefits
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(technique.benefits.prefix(4), id: \.self) { benefit in
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.inAppGreen)
                            Text(benefit)
                                .font(.caption2)
                                .foregroundColor(.inAppSecondaryLabel)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.inAppTertiarySystemBackground)
                        .cornerRadius(6)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.inAppSecondarySystemBackground)
        .cornerRadius(16)
    }
}

#Preview {
    LibraryView()
} 
