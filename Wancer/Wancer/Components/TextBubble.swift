//
//  TextBubble.swift
//  Wancer
//
//  Created by Kenny Lin on 3/24/24.
//

import SwiftUI

struct TextBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Text(message.text)
                .padding(12)
                .background(isCurrentUser ? Color.blue : Color.gray)
                .foregroundColor(isCurrentUser ? .white : .black)
                .cornerRadius(16)
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }
}
