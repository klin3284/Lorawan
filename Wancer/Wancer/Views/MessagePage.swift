import SwiftUI
import SwiftData

struct ChatView: View {
    @EnvironmentObject var user: User
    //  @StateObject var viewModel: ChatViewModel // View model for chat data
    @State private var newMessageText: String = ""
    @State private var messages: [String] = []
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ZStack(alignment: .leading) {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Text("EL")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .contentShape(Circle())
                        .offset(x: 16)
                }
                
                Text("Ethan Liu")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            
            Spacer()
            
            List {
                ForEach(messages, id: \.self) { message in
                    HStack {
                        Spacer()
                        Text(message)
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(alignment: .trailing)
                            }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(PlainListStyle())
            .frame(maxHeight: .infinity)
            
            //      List(viewModel.messages) { message in
            //        BubbleView(message: message, user: user)
            //      }
            //      .listStyle(.plain)
            //      .frame(maxHeight: .infinity)
            
            HStack(spacing: 16) {
                TextField("Type your message", text: $newMessageText)
                // $viewModel.newMessageText 
                    .disableAutocorrection(true)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                
            }
        }
        .padding()
        .onAppear {
            // viewModel.loadMessages()
        }
    }
    func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        messages.append(newMessageText)
        newMessageText = ""
    }

}

struct BubbleView: View {
  let message: Message
  let user: User
  
  var body: some View {
    Text(message.text)
      .padding()
      .background(Color.blue)
      .foregroundColor(.white)
      .cornerRadius(10)
      .fixedSize(horizontal: false, vertical: true)
      .frame(alignment: .trailing)
  }
}
class ChatViewModel: ObservableObject {
    @Published var contactName: String = ""
    @Published var messages: [Message] = []
    @Published var newMessageText: String = ""
    @Query private var group: [Group]
    
    private var currentGroup: Group?
    
    init(groupId: Int) {
        self.currentGroup = group.first(where: { $0.id == groupId }) ?? nil
        fetchContactName()
    }

    func loadMessages() -> [Message] {
        if let currentGroup {
            return currentGroup.messages
        }
        return []
    }
    
    func sendMessage(text: String, user: User) {
//        var msg : Message = Message(id: user.id, text: text, createdAt: Date.now, author: user, seen: false, group: currentGroup)
//        messages.append(msg)
    }
    
    private func fetchContactName() -> [User] {
        if let currentGroup {
            return currentGroup.users
        }
        return []
        
    }
}

#Preview {
    ChatView()
}

