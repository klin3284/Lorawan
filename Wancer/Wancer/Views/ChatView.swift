import SwiftUI
import SwiftData

struct ChatView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var userManager = UserManager.shared
    @State var user = UserManager.shared.retrieveUser()!
    @State private var newMessageText = ""
    @State private var groupMembers: [User] = []
    
    private var currentGroup: Group
    
    init(group: Group) {
        self.currentGroup = group
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(currentGroup.secret)
            Text(groupMembers.map{$0.firstName}.joined(separator: " "))
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
        .onAppear() {
            self.groupMembers = databaseManager.getUsersByGroupId(currentGroup.id)
        }
        .navigationTitle(currentGroup.name)
        .padding()
    }
    
    private func sendMessage() {
        if newMessageText != "" {
            let chunks = stride(from: 0, to: currentGroup.secret.count, by: 4).map { index in
                let startIndex = currentGroup.secret.index(currentGroup.secret.startIndex,
                                                           offsetBy: index)
                let endIndex = currentGroup.secret.index(startIndex, offsetBy: 4,
                                                         limitedBy: currentGroup.secret.endIndex) ?? currentGroup.secret.endIndex
                return String(currentGroup.secret[startIndex..<endIndex])
            }
            
            guard let position = chunks.firstIndex(of: String(user.phoneNumber.suffix(4))) else {
                print("User not found in the group")
                return
            }
            let messageSecret = String(databaseManager.getMessageCountByUser(user.id, currentGroup.id) + (position * 100_000))
            print(messageSecret)
            if let messageId = databaseManager.insertMessage(user.id, currentGroup.id, newMessageText, Date(), messageSecret, nil) {
                databaseManager.getAllGroups()
                
                if let messageSignal = databaseManager.getMessageById(messageId) {
                    bluetoothManager.write(value: messageSignal.buildString(currentGroup.secret, user.phoneNumber), characteristic: bluetoothManager.characteristics[0])
                } else {
                    print("Could not build string for signal")
                }
            }
            
            databaseManager.getAllGroups()
            newMessageText = ""
        }
    }
}

struct BubbleView: View {
    let message: Message
    @State var user = UserManager.shared.retrieveUser()!
    
    var body: some View {
        VStack {
            Text(message.text)
                .padding()
                .background(message.userId == user.id ? Color.blue : Color.gray.opacity(0.4))
                .foregroundColor(.white)
                .cornerRadius(10)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: message.userId == user.id ? .trailing : .leading)
            if let strength = message.signalStrength {
                Text(strength)
                    .font(.system(size: 10))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
            }
        }
    }
}
