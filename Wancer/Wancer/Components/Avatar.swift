//
//  Avatar.swift
//  Wancer
//
//  Created by Kenny Lin on 3/24/24.
//

import SwiftUI
import Foundation

struct Avatar: View {
    let size: CGFloat
    let initials: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: size, height: size)
            
            Text(initials)
                .font(.system(size: size / 3, weight: .semibold))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    Avatar(size: 20, initials: "KL")
}
