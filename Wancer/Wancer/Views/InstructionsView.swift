//
//  InstructionView.swift
//  Wancer
//
//  Created by Kenny Lin on 3/24/24.
//

import SwiftUI

struct InstructionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingBluetoothView = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 20) {
                Text("Please follow the instructions below to connect")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Image("ConnectionDiagram")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("1. Make sure batteries are attached to Arduino")
                        .font(.body)
                    Text("2. Turn the device on")
                        .font(.body)
                    Text("3. Turn Bluetooth on and connect to respective device")
                        .font(.body)
                }
                .padding(.top, 20)
                
                Button(action: {
                    isShowingBluetoothView = true
                }) {
                    Text("I have read the instructions and understand")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.top, 50)
            }
            .navigationDestination(isPresented: $isShowingBluetoothView) {
                BleConnectionView()
            }
        }
        .padding(.horizontal, 40)
    }
}

struct InstructionsPage_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
