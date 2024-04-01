//
//  ContentView.swift
//  Wancer
//
//  Created by Kenny Lin on 3/18/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isShowingInstructionView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Welcome View content
                VStack {
                    Text("Welcome to Wancer")
                        .font(.largeTitle)
                        .padding()
                    Text("Explore the possibilities of long range\nmessaging without cellular")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                
                    
                    Button(action: {
                        isShowingInstructionView = true
                    }) {
                        Text("Get Started")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $isShowingInstructionView) {
                InstructionsView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

