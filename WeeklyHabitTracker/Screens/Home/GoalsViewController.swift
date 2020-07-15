//
//  GoalsViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 7/10/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit
import SwiftUI

class GoalsViewController: UIHostingController<AnyView> {
    private var goals: GoalsData
    
    init(weeklyGoal: Int64?, habitGoal: Int64?) {
        self.goals = GoalsData(weeklyGoal: weeklyGoal, habitGoal: habitGoal)
        super.init(rootView: AnyView(GoalsSwiftUI().environmentObject(self.goals)))
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            print(self.goals.weeklyGoal as Any)
        }
    }
}

class GoalsData: ObservableObject {
    @Published var weeklyGoal: Int64?
    @Published var habitGoal: Int64?
    
    init(weeklyGoal: Int64?, habitGoal: Int64?) {
        self.weeklyGoal = weeklyGoal
        self.habitGoal = habitGoal
    }
}

struct GoalsSwiftUI: View {
    @EnvironmentObject var test: GoalsData
    
    var body: some View {
        List {
            Section(header: EmptyView()) {
                WeeklyGoalView(value: test.weeklyGoal)
            }
            
            Section(header: EmptyView()) {
                HabitGoalsView(value: test.habitGoal)
            }
        }.listStyle(GroupedListStyle())
         .environment(\.horizontalSizeClass, .regular)
         .navigationBarTitle("Goals")
    }
}

struct WeeklyGoalView: View {
    @State private var isExpanded: Bool
    @State private var weeklyGoalValue: Int64
    
    init(value: Int64?) {
        _isExpanded = State(initialValue: value != nil)
        _weeklyGoalValue = State(initialValue: value ?? 0)
    }

    var body: some View {
        VStack {
            Toggle("Weekly Goal", isOn: $isExpanded)
                .font(.system(size: 17, weight: .bold, design: .default))
//                .onTapGesture {
//                    if !self.isExpanded { self.weeklyGoalValue = -1 }
//            }
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
    @State private var textField: String
    
    init(value: Int64?) {
        _isExpanded = State(initialValue: value != nil)
        _textField = State(initialValue: "\(value ?? 0)")
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
