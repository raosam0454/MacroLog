//
//  RootView.swift
//  MacroLog
//
//  Created by Sumangala Rao on 24/9/2026.
//
import SwiftUI

/// The top of the interface: five tabs that follow the woman's workflow.
/// Today is where she lives day to day; Symptoms and Cycle are how she records
/// how her body responds; History is for spotting patterns; Plan is where she
/// sets the target everything else is measured against.
struct RootView: View {
    let repository: NourishmentRepository

    var body: some View {
        TabView {
            NavigationStack {
                TodayView(repository: repository)
            }
            .tabItem { Label("Today", systemImage: "sun.max") }

            NavigationStack {
                SymptomsView(repository: repository)
            }
            .tabItem { Label("Symptoms", systemImage: "heart.text.square") }

            NavigationStack {
                CycleView(repository: repository)
            }
            .tabItem { Label("Cycle", systemImage: "drop") }

            NavigationStack {
                HistoryView(repository: repository)
            }
            .tabItem { Label("History", systemImage: "calendar") }

            NavigationStack {
                DailyTargetView(repository: repository)
            }
            .tabItem { Label("Plan", systemImage: "target") }
        }
    }
}
