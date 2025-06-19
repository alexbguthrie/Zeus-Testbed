//
//  PlaceholderView.swift
//  Zeus-Testbed
//
//  Created by User on 2024-07-29.
//

import SwiftUI

struct PlaceholderView: View {
    let title: String

    var body: some View {
        Text("\(title) View")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.background)
    }
}

struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView(title: "Placeholder")
    }
} 