//
//  TaskManager_SwiftUIApp.swift
//  TaskManager-SwiftUI
//
//  Created by Aniket Rao on 20/03/25.
//

import SwiftUI

@main
struct TaskManager_SwiftUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
