//
//  StoreAppCard.swift | Zeus
//  Alex Guthrie
import SwiftUI

struct StoreAppCard: View {
    let app: StoreApp
    
    var body: some View {
        VStack(spacing: 22) {
            // Icon with big glass effect
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 92, height: 92)
                    .shadow(color: .white.opacity(0.09), radius: 18, y: 2)
                Image(systemName: app.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.white)
            }
            .padding(.top, 10)
            
            // App name
            Text(app.name)
                .font(.title.bold())
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
            
            // Description
            Text(app.description)
                .font(.body)
                .foregroundStyle(.secondary.opacity(0.86))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 6)
            
            // Author row
            HStack(spacing: 10) {
                Circle()
                    .fill(.thinMaterial)
                    .overlay(
                        Text(app.author.prefix(1))
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                    )
                    .frame(width: 32, height: 32)
                    .shadow(color: .white.opacity(0.11), radius: 2, y: 1)
                
                Text(app.author)
                    .font(.callout)
                    .foregroundStyle(.secondary.opacity(0.87))
                    .padding(.trailing, 2)
            }
            
            Spacer(minLength: 0)
            
            // Install Button
            Button(action: {}) {
                Text("Install Extension")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 11)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(.ultraThinMaterial)
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.17), lineWidth: 1.4)
                        }
                    )
            }
            .buttonStyle(.plain)
            .padding(.bottom, 16)
        }
        .frame(width: 288, height: 368)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.10), radius: 22, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1.2)
                )
        )
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
    }
}

#Preview {
    StoreAppCard(app: StoreApp(
        name: "Zen Browser",
        description: "Search and open tabs from bookmarks and history in Zen Browser.",
        author: "Lucas",
        imageName: "app.fill"
    ))
    .background(Color.black)
}
