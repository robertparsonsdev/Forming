//
//  GoalsViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 7/10/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit
import SwiftUI

class GoalsViewController: UIHostingController<GoalsSwiftUI> {
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
    }
}

struct GoalsSwiftUI: View {
    @State private var habitGoals: Bool = false
    
    var body: some View {
        List {
            Section(header: EmptyView()) {
                WeeklyGoalView(isExpanded: false)
            }
            
            Section(header: EmptyView()) {
                HabitGoalsView(isExpanded: true)
            }
        }.listStyle(GroupedListStyle())
         .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Goals")
    }
}

struct WeeklyGoalView: View {
    @State private var isExpanded: Bool
    @State private var weeklyGoalValue = 0
    
    init(isExpanded: Bool) {
        _isExpanded = State(initialValue: isExpanded)
    }

    var body: some View {
        VStack {
            Toggle("Weekly Goal", isOn: $isExpanded)
                .font(.system(size: 17, weight: .bold, design: .default))
            Text("Set a goal to reach every week.")
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            .padding([.bottom], 10)
            if isExpanded {
                HStack {
                    Text("\(self.weeklyGoalValue)")
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(10)
                        .padding([.trailing], 5)
                    Stepper("Label", value: $weeklyGoalValue, in: 1...7)
                    .labelsHidden()
                }
                .padding([.bottom], 10)
                .padding([.top], -5)
            }
        }
    }
}

struct HabitGoalsView: View {
    @State private var isExpanded: Bool
    @State private var textField = ""
    
    init(isExpanded: Bool) {
        _isExpanded = State(initialValue: isExpanded)
    }

    var body: some View {
        VStack() {
            Toggle("Habit Goal", isOn: $isExpanded)
                .font(.system(size: 17, weight: .bold, design: .default))
            Text("Set a habit goal to be notified when you reach a specified number of total completed days for this habit.")
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.bottom], 10)
            if isExpanded {
                TextField("Enter Goal Number", text: $textField)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .frame(height: 40)
                    .background(Color(.tertiarySystemFill))
                    .cornerRadius(10)
                    .padding([.bottom], 10)
                    .padding([.top], -5)
            }
        }
    }
}

struct GoalsViewController_Previews: PreviewProvider {
    static var previews: some View {
        Group {
           GoalsSwiftUI()
              .environment(\.colorScheme, .dark)

           GoalsSwiftUI()
              .environment(\.colorScheme, .light)
        }
    }
}
