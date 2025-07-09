//
//  SessionPlayView.swift
//  breath
//
//  Created by pc on 24.06.25.
//

import SwiftUI

struct SessionPlayView: View {
    let techniqueSetup: TechniqueSetup
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPhase: BreathingTechnique.BreathPhase = .inhale
    @State private var phaseProgress: Double = 0.0
    @State private var sessionProgress: Double = 0.0
    @State private var isPaused = false
    @State private var showingPauseMenu = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var totalTime: TimeInterval = 0
    @State private var balloonOpacity: Double = 1.0
    @State private var initialScale: Double = 0.8 // Start with small size
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.inAppSystemBackground, Color.inAppBlue.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("\(Int(elapsedTime / 60)):\(String(format: "%02d", Int(elapsedTime.truncatingRemainder(dividingBy: 60)))) / \(Int(totalTime / 60)):\(String(format: "%02d", Int(totalTime.truncatingRemainder(dividingBy: 60))))")
                        .font(.subheadline)
                        .foregroundColor(.inAppSecondaryLabel)
                }
                
                // Breathing Balloon Animation
                ZStack {
                    // Progress ring
                    Circle()
                        .stroke(Color.inAppLabel.opacity(0.2), lineWidth: 8)
                        .frame(width: 260, height: 260)
                    
                    Circle()
                        .trim(from: 0, to: sessionProgress)
                        .stroke(Color.inAppBlue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 260, height: 260)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: sessionProgress)
                    
                    // Breathing balloon
                    Image(balloonImageName(for: currentPhase))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 190, height: 190)
                        .scaleEffect(targetScale)
                        .opacity(balloonOpacity)
                        .rotationEffect(.degrees(phaseProgress * 5))
                        .animation(
                            currentPhase == .inhale || currentPhase == .exhale
                            ? .easeInOut(duration: phaseDuration)
                            : .none,
                            value: targetScale
                        )
                        .animation(.easeInOut(duration: 0.3), value: balloonOpacity)
                        .animation(
                            currentPhase == .inhale || currentPhase == .exhale
                            ? .linear(duration: phaseDuration)
                            : .none,
                            value: phaseProgress
                        )
                }
                
                // Phase progress with balloon indicators
                VStack(spacing: 8) {
                    Text("Current Phase")
                        .font(.subheadline)
                        .foregroundColor(.inAppSecondaryLabel)
                    
                    // Current phase info
                    HStack(spacing: 8) {
                        Image(systemName: currentPhase.phaseIcon)
                            .font(.title2)
                            .foregroundColor(phaseColor(for: currentPhase))
                        
                        Text(currentPhase.rawValue.capitalized)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.inAppLabel)
                        
                        Text("\(Int(phaseTimeRemaining))s")
                            .font(.subheadline)
                            .foregroundColor(.inAppSecondaryLabel)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.inAppTertiarySystemBackground)
                    .cornerRadius(12)
                    
                    HStack(spacing: 8) {
                        ForEach(activePhases, id: \.self) { phase in
                            VStack(spacing: 4) {
                                Image(balloonImageName(for: phase))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .opacity(phase == currentPhase ? 1.0 : (techniqueSetup.getEffectiveDurations()[phase] ?? 0 > 0 ? 0.4 : 0.2))
                                    .scaleEffect(phase == currentPhase ? 1.2 : 1.0)
                                    .offset(y: phase == currentPhase ? -2 : 0)
                                    .animation(.easeInOut(duration: 0.2), value: currentPhase)
                                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: phase == currentPhase)
                                
                                // Phase label
                                VStack(spacing: 2) {
                                    HStack(spacing: 2) {
                                        Image(systemName: phase.phaseIcon)
                                            .font(.caption2)
                                            .foregroundColor(phase == currentPhase ? phaseColor(for: phase) : .inAppSecondaryLabel)
                                        
                                        Text(phase.rawValue.capitalized)
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundColor(phase == currentPhase ? .inAppLabel : .inAppSecondaryLabel)
                                    }
                                    
                                    Text("\(Int(techniqueSetup.getEffectiveDurations()[phase] ?? 0))s")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(phase == currentPhase ? phaseColor(for: phase) : .inAppSecondaryLabel)
                                }
                                
                                Rectangle()
                                    .fill(phase == currentPhase ? phaseColor(for: phase) : Color.inAppLabel.opacity(0.3))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                // Controls
                HStack(spacing: 40) {
                    Button(action: {
                        showingPauseMenu = true
                    }) {
                        Image(systemName: "pause.fill")
                            .font(.title2)
                            .foregroundColor(.inAppLabel)
                            .frame(width: 60, height: 60)
                            .background(Color.inAppLabel.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.red.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(40)
        }
        .onAppear {
            startSession()
        }
        .onReceive(timer) { _ in
            if !isPaused {
                updateSession()
            }
        }
        .sheet(isPresented: $showingPauseMenu) {
            PauseMenuView(
                isPaused: $isPaused,
                onResume: { showingPauseMenu = false },
                onEnd: { dismiss() }
            )
        }
    }
    
    // MARK: - Computed Properties
    
    // Balloon scale: only two sizes (small & big). Inhale animates small→big, Exhale animates big→small.
    private var targetScale: Double {
        switch currentPhase {
        case .inhale:
            return 1.3 // Always animate to big size
        case .holdIn:
            return 1.3 // Big size
        case .exhale:
            return 0.8 // Small size
        case .holdOut:
            return 0.8 // Small size
        }
    }
    
    private var phaseDuration: Double {
        return techniqueSetup.getEffectiveDurations()[currentPhase] ?? 4.0
    }
    
    private var phaseTimeRemaining: Double {
        return phaseDuration * (1.0 - phaseProgress)
    }
    
    // MARK: - Methods
    
    private func startSession() {
        totalTime = TimeInterval(techniqueSetup.getEffectiveTotalDuration() * 60)
        currentPhase = .inhale
        phaseProgress = 0.0
        sessionProgress = 0.0
        elapsedTime = 0.0
        balloonOpacity = 1.0
        initialScale = 1.0 // Start with small size
    }
    
    private func updateSession() {
        elapsedTime += 0.1
        sessionProgress = min(elapsedTime / totalTime, 1.0)
        
        phaseProgress += 0.1 / phaseDuration
        
        if phaseProgress >= 1.0 {
            phaseProgress = 0.0
            moveToNextPhase()
        }
        
        if sessionProgress >= 1.0 {
            // Session completed
            dismiss()
        }
    }
    
    private func moveToNextPhase() {
        let phases = BreathingTechnique.BreathPhase.allCases
        if let currentIndex = phases.firstIndex(of: currentPhase) {
            var nextIndex = (currentIndex + 1) % phases.count
            
            // Skip phases with 0 duration
            while techniqueSetup.getEffectiveDurations()[phases[nextIndex]] == 0 {
                nextIndex = (nextIndex + 1) % phases.count
                // Prevent infinite loop if all phases have 0 duration
                if nextIndex == currentIndex {
                    break
                }
            }
            
            // Smoother transition between balloons
            withAnimation(.easeInOut(duration: 0.3)) {
                balloonOpacity = 0.0
            }
            
            // Change phase and fade in new balloon
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                currentPhase = phases[nextIndex]
                // Update initialScale based on the current phase
                if currentPhase == .exhale || currentPhase == .holdOut {
                    initialScale = 0.8
                } else {
                    initialScale = 1.3
                }
                withAnimation(.easeInOut(duration: 0.4)) {
                    balloonOpacity = 1.0
                }
            }
        }
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
    
    // Get phases with non-zero duration for progress display
    private var activePhases: [BreathingTechnique.BreathPhase] {
        return BreathingTechnique.BreathPhase.allCases.filter { phase in
            techniqueSetup.getEffectiveDurations()[phase] ?? 0 > 0
        }
    }
}

struct PauseMenuView: View {
    @Binding var isPaused: Bool
    let onResume: () -> Void
    let onEnd: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Session Paused")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.inAppLabel)
            
            VStack(spacing: 16) {
                Button(action: {
                    isPaused = false
                    dismiss()
                    onResume()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Resume")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.inAppBlue)
                    .cornerRadius(16)
                }
                
                Button(action: {
                    dismiss()
                    onEnd()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("End Session")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red)
                    .cornerRadius(16)
                }
            }
        }
        .padding(40)
        .background(Color.inAppSystemBackground)
        .cornerRadius(20)
        .padding(40)
    }
}

#Preview {
    SessionPlayView(
        techniqueSetup: TechniqueSetup(
            technique: loadTechniques().first!,
            customDurations: [
                .inhale: 4.0,
                .holdIn: 7.0,
                .exhale: 8.0,
                .holdOut: 0.0
            ],
            customTotalDuration: 5,
            customDifficulty: .beginner
        )
    )
} 
