import SwiftUI

struct ExtensionAppCard: View {
    let app: ExtensionApp
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 20) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(app.iconColor.opacity(0.19))
                        .frame(width: 64, height: 64)
                    Image(systemName: app.iconName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(app.iconColor)
                        .frame(width: 36, height: 36)
                }
                .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(app.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.95)
                        .padding(.bottom, 2)
                    
                    // Description
                    Text(app.description)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.74))
                        .lineLimit(2)
                }
                Spacer()
                // Improved Install Button
                Button(action: {}) {
                    Text("Install")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 7)
                        .padding(.horizontal, 28)
                        .background(
                            ZStack {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.17),
                                                Color.white.opacity(0.09)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: .white.opacity(0.09), radius: 2, y: 2)
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.20), lineWidth: 1.3)
                            }
                        )
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 16)
            
            // Meta Row
            HStack(spacing: 22) {
                // Author
                HStack(spacing: 7) {
                    Image(systemName: app.authorAvatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 22, height: 22)
                        .clipShape(Circle())
                    Text(app.author)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.74))
                }
                // Command count
                if app.commands > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.58))
                        Text("\(app.commands) Commands")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.58))
                    }
                }
                // Installs
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.58))
                    Text(app.installs.formatted(.number))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.58))
                }
                Spacer()
            }
            .padding(.top, 2)
            .padding(.bottom, 2)
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 28)
        .frame(minWidth: 420, maxWidth: 620, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.07),
                            Color.white.opacity(0.10)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .white.opacity(0.09), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    ExtensionAppCard(app: ExtensionApp(
        name: "Kill Process",
        description: "Terminate processes sorted by CPU or memory usage",
        author: "Roland Leth",
        authorAvatar: "person.crop.circle",
        iconName: "square.fill",
        iconColor: Color.yellow,
        commands: 500,
        installs: 311_669
    ))
    .frame(width: 640)
    .background(Color.black)
}
