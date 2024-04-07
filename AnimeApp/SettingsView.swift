//
//  SettingsView.swift
//  AnimeApp
//
//  Created by Preston Clayton on 2/1/24.
//

import SwiftUI

// look into swiftdata singleton model for settings storage
// Appstorage is more annoying to use for detailed models
struct SettingsView: View {
    @AppStorage("url") private var gogoanimeURL: String = ""
    @AppStorage("homeLayout2") private var categorySortSettings: [RowViewSetting] = defaultHomeScreen

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("gogoanime URL", text: $gogoanimeURL)
                } header: {
                    Text("API")
                }
                Section {
                    NavigationLink("Edit Categories") {
                        List($categorySortSettings, id: \.type.rawValue, editActions: .move) { $setting in
                            Toggle(setting.type.getTitle(), isOn: $setting.on)
                        }
                        .navigationTitle("Categories")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                } header: {
                    Text("Home Screen")
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

//#Preview {
//    SettingsView(categorySortSettings: <#Binding<[RowViewSetting]>#>)
//}
