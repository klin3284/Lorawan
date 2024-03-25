import SwiftUI
import SwiftData

struct ConversationView: View {
    // TODO: Make singleton User struct
    private var user : User
    @State private var newMessageText: String = ""
    @State private var messages: [Message] = []
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Avatar(size: 50, initials: "\(user.firstName.prefix(1).uppercased())\(user.lastName.prefix(1).uppercased())")
                
                Text("\(user.firstName) \(user.lastName)")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            
            Spacer()
            
            ScrollView {
                ForEach(messages) { message in
                    TextBubble(message: message, isCurrentUser: message.author.id == user.id)
                }
            }
            
            HStack(spacing: 16) {
                TextField("Type your message", text: $newMessageText)
                    .disableAutocorrection(true)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                
                Button(action: {
                    // TODO: Store message in db and send signal
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .onAppear {
            // TODO: Fetch messages from VM
        }
    }
}

// View Model Skeleton
class ConversationViewModel: ObservableObject {
    // Properties and methods for the view model
}
