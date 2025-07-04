//
//  OnboardingView.swift
//  breath
//
//  Created by pc on 24.06.25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Welcome to BreathBalloonFlow")
                    .font(.system(size: 36, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(.indigo)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // Illustration
                Image("gr")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 280)
                //                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                
                // Description
                Text("Discover the power of conscious breathing with our curated collection of proven techniques. From better sleep to increased energy, find your perfect breathing practice.")
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Spacer()
                
                // Get Started Button
                Button(action: {
                    withAnimation {
                        hasCompletedOnboarding = true
                    }
                }) {
                    Text("Get Started")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.inAppBlue)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                Spacer()
            }
            .padding(32)
        }
        .background(
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

#Preview {
    OnboardingView()
}
