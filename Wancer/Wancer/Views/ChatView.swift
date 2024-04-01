import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @State var user = UserManager.shared.retrieveUser()!
    @State private var newMessageText = ""
    
    private var currentGroup: Group
    
    init(group: Group) {
        self.currentGroup = group
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ZStack(alignment: .leading) {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Text("\(user.firstName.prefix(1).uppercased())\(user.lastName.prefix(1).uppercased())")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .contentShape(Circle())
                        .offset(x: 16)
                }
                
                Text("\(user.firstName) \(user.lastName)")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            
            Spacer()
            
            List {
                ForEach(currentGroup.messages) { message in
                    HStack {
                        Spacer()
                        BubbleView(message: message, user: user)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(PlainListStyle())
            .frame(maxHeight: .infinity)
            
            HStack(spacing: 16) {
                TextField("Type your message", text: $newMessageText )
                    .disableAutocorrection(true)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 26))
                }
            }
        }
        .padding()
    }
    
    private func sendMessage() {
        print(newMessageText)
        newMessageText = ""
    }
}

struct BubbleView: View {
    let message: Message
    let user: User
    
    var body: some View {
        Text(message.text)
            .padding()
            .background(message.author == user ? Color.blue : Color.gray.opacity(0.4))
            .foregroundColor(message.author == user ? .white : .black)
            .cornerRadius(10)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: message.author == user ? .trailing : .leading)
    }
}
