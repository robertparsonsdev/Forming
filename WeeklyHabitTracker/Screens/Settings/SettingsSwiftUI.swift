//
//  SettingsSwiftUI.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 7/7/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import SwiftUI

struct SettingsSwiftUI: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                TipButton(buttonNumber: 1)
                TipButton(buttonNumber: 2)
                TipButton(buttonNumber: 3)
                SettingsList()
            }.navigationBarTitle(Text("Settings"))
        }
    }
}

struct SettingsSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSwiftUI()
    }
}

struct TipButton: View {
    let buttonNumber: Int
    var body: some View {
        Button(action: {
            print(self.buttonNumber)
        }) {
            Text(String(buttonNumber))
                .padding()
                .padding()
                .background(Color(.tertiarySystemFill))
                .cornerRadius(14)
        }
    }
}

struct SettingsList: View {
    var body: some View {
        List {
            Text("First Row")
        }.listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
    }
}
