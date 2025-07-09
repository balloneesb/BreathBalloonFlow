//
//  Models.swift
//  breath
//
//  Created by pc on 24.06.25.
//

import Foundation

struct BreathingTechnique: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let tags: [String]
    let defaultDurations: [String: Double]
    let category: BreathingTechniqueTypes
    let totalDuration: Int // in minutes
    let difficulty: ExperienceLevel
    let benefits: [String]
    
    var isLiked: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description, tags, defaultDurations, category, totalDuration, difficulty, benefits
    }
    
    var t: [BreathingTechnique.BreathPhase: Double] {
        Dictionary(uniqueKeysWithValues: self.defaultDurations.compactMap { (key, value) in
            guard let phase = BreathingTechnique.BreathPhase(rawValue: key) else { return nil }
            return (phase, value)
        })
    }
    
    enum BreathPhase: String, Codable, CaseIterable {
        case inhale = "inhale"
        case holdIn = "holdIn"
        case exhale = "exhale"
        case holdOut = "holdOut"
        
        var phaseIcon: String {
            switch self {
            case .inhale: return "arrow.down.circle.fill"
            case .holdIn: return "pause.circle.fill"
            case .exhale: return "arrow.up.circle.fill"
            case .holdOut: return "pause.circle.fill"
            }
        }
    }
    
    enum BreathingTechniqueTypes: String, Codable, CaseIterable {
        case relaxationSleep = "relaxationSleep"
        case energyWakefulness = "energyWakefulness"
        case coldExposureStressResilience = "coldExposureStressResilience"
        case emotionalRegulationNervousSystem = "emotionalRegulationNervousSystem"
        
        var displayName: String {
            switch self {
            case .relaxationSleep:
                return "Relaxation & Sleep"
            case .energyWakefulness:
                return "Energy & Wakefulness"
            case .coldExposureStressResilience:
                return "Cold Exposure & Resilience"
            case .emotionalRegulationNervousSystem:
                return "Emotional Regulation"
            }
        }
    }
    
    var displayName: String {
        return name
    }
    
    var categoryDisplayName: String {
        return category.displayName
    }
    
    var difficultyDisplayName: String {
        return difficulty.displayName
    }
}

struct TechniqueSetup: Identifiable, Codable {
    let id: String
    let techniqueId: String
    let customDurations: [BreathingTechnique.BreathPhase: Double]
    let customTotalDuration: Int // in minutes
    let customDifficulty: ExperienceLevel
    
    init(technique: BreathingTechnique, customDurations: [BreathingTechnique.BreathPhase: Double]? = nil, customTotalDuration: Int? = nil, customDifficulty: ExperienceLevel? = nil) {
        self.id = UUID().uuidString
        self.techniqueId = technique.id
        self.customDurations = customDurations ?? technique.t
        self.customTotalDuration = customTotalDuration ?? technique.totalDuration
        self.customDifficulty = customDifficulty ?? technique.difficulty
    }
    
    func getEffectiveDurations() -> [BreathingTechnique.BreathPhase: Double] {
        return customDurations
    }
    
    func getEffectiveTotalDuration() -> Int {
        return customTotalDuration
    }
    
    func getEffectiveDifficulty() -> ExperienceLevel {
        return customDifficulty
    }
}

enum SessionLength: String, CaseIterable, Identifiable {
    case short, medium, long
    var id: String { self.rawValue }
    var minutes: Int {
        switch self {
        case .short: return 2
        case .medium: return 5
        case .long: return 10
        }
    }
    
    var displayName: String {
        switch self {
        case .short: return "Short"
        case .medium: return "Medium"
        case .long: return "Long"
        }
    }
}

enum ExperienceLevel: String, CaseIterable, Identifiable, Codable {
    case beginner, intermediate, advanced
    var id: String { self.rawValue }
    var multiplier: Double {
        switch self {
        case .beginner: return 0.8
        case .intermediate: return 1.0
        case .advanced: return 1.5
        }
    }
    
    var displayName: String {
        return rawValue.capitalized
    }
}

func loadTechniques() -> [BreathingTechnique] {
    print("🔍 Attempting to load techniques.json...")
    
    guard let url = Bundle.main.url(forResource: "techniques", withExtension: "json") else {
        print("❌ Could not find techniques.json in bundle")
        print("📁 Bundle path: \(Bundle.main.bundlePath)")
        print("📋 Bundle contents:")
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)
            contents.forEach { print("   - \($0)") }
        } catch {
            print("   Error listing bundle contents: \(error)")
        }
        return []
    }
    
    print("✅ Found techniques.json at: \(url)")
    
    guard let data = try? Data(contentsOf: url) else {
        print("❌ Could not read data from techniques.json")
        return []
    }
    
    print("✅ Successfully read \(data.count) bytes from techniques.json")
    
    do {
        let techniques = try JSONDecoder().decode([BreathingTechnique].self, from: data)
        print("✅ Successfully decoded \(techniques.count) techniques")
        return techniques
    } catch {
        print("❌ JSON decoding error: \(error)")
        print("📄 JSON content (first 500 chars): \(String(data: data, encoding: .utf8)?.prefix(500) ?? "Could not decode as string")")
        
        // Try to decode with more detailed error info
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🔍 Attempting to parse JSON manually...")
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                print("✅ JSON is valid, issue is with Swift model decoding")
                print("📋 First object keys: \(json)")
            } catch {
                print("❌ JSON is invalid: \(error)")
            }
        }
        return []
    }
}

// Helper functions for filtering and grouping
extension Array where Element == BreathingTechnique {
    func filtered(by category: BreathingTechnique.BreathingTechniqueTypes? = nil, 
                 difficulty: ExperienceLevel? = nil,
                 benefits: [String]? = nil) -> [BreathingTechnique] {
        return self.filter { technique in
            let categoryMatch = category == nil || technique.category == category
            let difficultyMatch = difficulty == nil || technique.difficulty == difficulty
            let benefitsMatch = benefits == nil || benefits!.isEmpty || benefits!.contains { benefit in
                technique.benefits.contains(benefit)
            }
            return categoryMatch && difficultyMatch && benefitsMatch
        }
    }
    
    func sortedByLikes() -> [BreathingTechnique] {
        return self.sorted { t1, t2 in
            if t1.isLiked != t2.isLiked {
                return t1.isLiked
            }
            return t1.name < t2.name
        }
    }
    
    func groupedByCategory() -> [BreathingTechnique.BreathingTechniqueTypes: [BreathingTechnique]] {
        return Dictionary(grouping: self) { $0.category }
    }
    
    func groupedByDifficulty() -> [ExperienceLevel: [BreathingTechnique]] {
        return Dictionary(grouping: self) { $0.difficulty }
    }
}

