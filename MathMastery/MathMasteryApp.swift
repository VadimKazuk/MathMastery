//
//  MathMasteryApp.swift
//  MathMastery
//
//  Created by Vadim Kazuk on 23/06/2026.
//

import SwiftUI
import SwiftData

@main
struct MathMasteryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var serviceContainer: ServiceContainer = DefaultServiceContainer()

    var body: some Scene {
        WindowGroup {
            MainContainerView(viewModel: .init(serviceContainer: serviceContainer))
                .accentColor(.orange)
                .environmentObject(serviceContainer)
                .onAppear {
                    self.delegate.serviceContainer = serviceContainer
                }
        }
    }
}
