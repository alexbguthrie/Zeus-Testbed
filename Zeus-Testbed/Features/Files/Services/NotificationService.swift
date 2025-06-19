//
//  NotificationService.swift
//  Zeus-Testbed
//
//  A service and view for displaying non-intrusive, "toast-style" notifications.
//

import SwiftUI
import Combine

// The message to be displayed
struct AppNotification: Equatable {
    let message: String
    let type: NotificationType
}

enum NotificationType {
    case success, error
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return FilesTheme.current.colors.destructive
        }
    }
}

// The service that manages showing and hiding notifications
class NotificationService: ObservableObject {
    @Published private(set) var notification: AppNotification?
    private var task: Task<Void, Error>?
    
    func show(type: NotificationType, message: String) {
        // If a notification is already showing, cancel its dismissal task
        task?.cancel()
        
        let newNotification = AppNotification(message: message, type: type)
        
        // Use a task to automatically dismiss the notification after a delay
        task = Task {
            // Set the notification immediately
            await MainActor.run {
                self.notification = newNotification
            }
            // Wait for 3 seconds
            try await Task.sleep(nanoseconds: 3_000_000_000)
            
            // Clear the notification
            await MainActor.run {
                self.notification = nil
            }
        }
    }
}

// The SwiftUI view for the notification
struct NotificationView: View {
    let notification: AppNotification
    private let theme = FilesTheme.current
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.type.icon)
                .font(.title2)
                .foregroundColor(notification.type.color)
            
            Text(notification.message)
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.textPrimary)
        }
        .padding()
        .background(theme.colors.secondaryBackground)
        .cornerRadius(theme.layout.cornerRadius)
        .shadow(color: theme.layout.shadow.color, radius: theme.layout.shadow.radius, x: theme.layout.shadow.x, y: theme.layout.shadow.y)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: notification)
    }
}

#if DEBUG
struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        let theme = FilesTheme.current
        return ZStack(alignment: .top) {
            theme.colors.background.ignoresSafeArea()
            VStack {
                NotificationView(notification: AppNotification(message: "File deleted successfully.", type: .success))
                NotificationView(notification: AppNotification(message: "Could not save the file.", type: .error))
            }
        }
        .preferredColorScheme(.dark)
    }
}
#endif 