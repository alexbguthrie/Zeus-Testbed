//
//  LearnView.swift
//  Zeus-Testbed
//
//  Created by User on 2024-07-29.
//

import SwiftUI

struct LearnView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            Text("Learn")
                .font(.largeTitle.bold())

            featuredCourse
            
            popularTutorials

            Spacer()
        }
        .padding(AppTheme.Spacing.xlarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppTheme.Colors.background)
    }

    private var featuredCourse: some View {
        VStack(alignment: .leading) {
            Text("FEATURED COURSE")
                .font(.headline)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text("Creating Your First 3D Game")
                .font(.title2.bold())
                
            Text("Learn the fundamentals of game development with our comprehensive course designed for beginners.")
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.bottom, AppTheme.Spacing.small)

            HStack {
                Button("Start Learning") {}
                    .buttonStyle(.borderedProminent)
                Button("Save for Later") {}
                    .buttonStyle(.bordered)
            }
        }
        .padding(AppTheme.Spacing.large)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(16)
    }

    private var popularTutorials: some View {
        VStack(alignment: .leading) {
            Text("Popular Tutorials")
                .font(.title2.bold())
            
            Text("Tutorial cards would go here.")
                .foregroundColor(AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
    }
} 