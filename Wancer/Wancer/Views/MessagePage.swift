import SwiftUI
import SwiftData

struct ChatView: View {
    @EnvironmentObject var user: User
    //  @StateObject var viewModel: ChatViewModel // View model for chat data
    @State private var newMessageText: String = ""
    @State private var messages: [Message] = []
    
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
            
            //      List(viewModel.messages) { message in
            //        BubbleView(message: message, user: user)
            //      }
            //      .listStyle(.plain)
            //      .frame(maxHeight: .infinity)
            
            HStack(spacing: 16) {
                TextField("Type your message", text: $newMessageText)
                    .disableAutocorrection(true)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                
                Button(action: {
                    // viewModel.sendMessage() to do
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

}

struct BubbleView: View {
  let message: Message
  let user: User
  
  var body: some View {
    Text(message.text)
      .padding()
      .background(message.author.id == user.id ? Color.blue : Color.gray)
      .foregroundColor(message.author.id == user.id ? .white : .black)
      .cornerRadius(10)
      .fixedSize(horizontal: false, vertical: true)
      .frame(alignment: message.author.id == user.id ? .trailing : .leading)
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
    
    func sendMessage(text: String) {
        // TODO: Redo the paramaters to create a new Message and add
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

