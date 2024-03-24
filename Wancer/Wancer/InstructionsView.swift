//
//  InstructionView.swift
//  Wancer
//
//  Created by Kenny Lin on 3/24/24.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
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
            
            Text("I have read the instructions and understand")
                .font(.body)
                .fontWeight(.bold)
                .underline()
                .padding(.top, 30)
        }
        .padding(.horizontal, 40)
    }
}

struct InstructionsPage_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
