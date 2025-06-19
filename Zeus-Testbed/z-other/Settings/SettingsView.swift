//
//  SettingsView.swift
//  Zeus-Testbed
//
//  Created by User on 2024-07-29.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = true
    @State private var selectedLanguage = "English"

    let languages = ["English", "Spanish", "French", "German", "Japanese"]

    var body: some View {
        Form {
            Section(header: Text("General")) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                Toggle("Enable Dark Mode", isOn: $darkModeEnabled)
            }

            Section(header: Text("Localization")) {
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(languages, id: \.self) {
                        Text($0)
                    }
                }
            }
            
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 