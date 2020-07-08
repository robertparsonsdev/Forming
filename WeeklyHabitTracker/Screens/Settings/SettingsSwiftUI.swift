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
            List {
                Section(header:
                    VStack(spacing: 15) {
                        TipButton(title: "$0.99 Tip",
                                  message: "Thank you so much for your support!",
                                  leftMemoji: Memoji(imageName: "thumbsup-left"),
                                  rightMemoji: Memoji(imageName: "thumbsup-right"))
                        TipButton(title: "$4.99 Tip",
                                  message: "You're awesome! Thank you so much!",
                                  leftMemoji: Memoji(imageName: "celebration-left"),
                                  rightMemoji: Memoji(imageName: "celebration-right"))
                        TipButton(title: "$9.99 Tip",
                                  message: "Wow! I really appreciate it! Thank you!",
                                  leftMemoji: Memoji(imageName: "explosion-left"),
                                  rightMemoji: Memoji(imageName: "explosion-right"))
                }.frame(width: UIScreen.main.bounds.width, height: (3 * 90) + (3 * 15), alignment: .center)) {
                    Text("Row")
                }
            }.listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
                .navigationBarTitle(Text("Settings"))
        }
    }
}

struct SettingsSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
           SettingsSwiftUI()
              .environment(\.colorScheme, .dark)

           SettingsSwiftUI()
              .environment(\.colorScheme, .light)
        }
    }
}

struct TipButton: View {
    let title: String
    let message: String
    let leftMemoji: Memoji
    let rightMemoji: Memoji
    
    var body: some View {
        Button(action: {
            print(self.title)
        }) {
            HStack(spacing: 0) {
                leftMemoji
                VStack {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .default))
                    Text(message)
                        .font(.system(size: 17))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .frame(width: 200, height: 50, alignment: .center)
                }
                rightMemoji
            }
        }.frame(width: UIScreen.main.bounds.width - 40, height: 90, alignment: .center)
            .background(Color(.tertiarySystemFill))
            .foregroundColor(Color(.label))
            .cornerRadius(14)
    }
}

struct Memoji: View {
    let imageName: String
    var body: some View {
        Image(imageName)
            .renderingMode(.original)
            .resizable()
            .frame(width: 65, height: 65, alignment: .center)
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
