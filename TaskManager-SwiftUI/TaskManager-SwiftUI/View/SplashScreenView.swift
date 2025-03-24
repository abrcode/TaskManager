//
//  TaskManager_SwiftUIApp.swift
//  TaskManager-SwiftUI
//
//  Created by Aniket Rao on 20/03/25.
//
import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        ZStack {
            // Make sure ContentView is ready before showing it
            ContentView()
                .opacity(isActive ? 1 : 0)
            
            // Splash screen overlay
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("TaskManager")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Get Things Done")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .scaleEffect(size)
                .opacity(opacity)
            }
            .opacity(isActive ? 0 : 1)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                self.size = 1.0
                self.opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
