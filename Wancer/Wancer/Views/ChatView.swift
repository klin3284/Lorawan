import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var userManager = UserManager.shared
    @State var user = UserManager.shared.retrieveUser()!
    @State private var newMessageText = ""
    var bluetoothManager: BluetoothManager
    
    private var currentGroup: Group
    
    init(group: Group) {
        self.bluetoothManager = gBluetoothManager
        self.currentGroup = group
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(currentGroup.id)
            Text(currentGroup.users?.map{$0.firstName}.joined(separator: " ") ?? "Bad")
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
        .navigationTitle(currentGroup.name)
        .padding()
    }
    
    private func sendMessage() {
        if newMessageText != "" {
            print(currentGroup.messages.count)
            let newMessage = Message(id: currentGroup.messages.count, text: newMessageText, createdAt: Date(), author: user, seen: false, group: nil)
            currentGroup.addMessage(newMessage)
            if let messageSignal = newMessage.buildString() {
                bluetoothManager.write(value: messageSignal, characteristic: bluetoothManager.characteristics[0])
            } else {
                print("Could not build string for signal")
            }
            newMessageText = ""
        }
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
