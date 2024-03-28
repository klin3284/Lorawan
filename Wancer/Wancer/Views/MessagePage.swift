import SwiftUI
import SwiftData

struct ChatView: View {
    @StateObject var user: User
    @StateObject var viewModel: ChatViewModel // View model for chat data
    
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
                ForEach(viewModel.messages) { message in
                    HStack {
                        Spacer()
                        BubbleView(message: message, user: user)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                }
              }
              .listStyle(PlainListStyle())
              .frame(maxHeight: .infinity)
            
            HStack(spacing: 16) {
                TextField("Type your message", text: $viewModel.newMessageText )
                    .disableAutocorrection(true)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                
                Button(action: {
                    viewModel.sendMessage(user: user)
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.loadMessages()
        }
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
    @Published var messages: [Message] = []
    @Published var newMessageText: String = ""
    @Query private var groups: [Group]
    @Query private var users: [User]
    @Environment(\.modelContext) var modelContext
    private var currentGroup: Group?

    func fetchGroup(with id: String) -> Group? {
        return groups.first(where: {$0.id == Int(id)})
    }

    func fetchUser(with id: String) -> User? {
        return users.first(where: {$0.id == Int(id)})
    }
    
    init(groupId: Int) {
        self.currentGroup = groups.first(where: { $0.id == groupId })
    }

    func loadMessages() -> [Message] {
        if let currentGroup {
            return currentGroup.messages
        }
        return []
    }
    
    func sendMessage(user: User) {
        let msg : Message = Message(id: messages.count + 1, text: newMessageText, createdAt: Date.now, author: user, seen: false, group: currentGroup!)
        
        messages.append(msg)
        newMessageText = ""
    }
}

#Preview {
    if let container = try? ModelContainer(for: Message.self, User.self, Group.self) {
        let container = try? ModelContainer(for: Message.self, User.self, Group.self)
        let user = User(id: 104, firstName: "Ethan", lastName: "Liu", groups: [])

        let group = Group(id: 204, name: "group", users: [user], messages: [])
        
        container!.mainContext.insert(user)
        container!.mainContext.insert(group)
        
        user.groups.append(group)
        
        let message1 = Message(id: 300, text: "Hello!", createdAt: Date.now, author: user, seen: false, group: group)
        let message2 = Message(id: 400, text: "Hi!", createdAt: Date.now, author: user, seen: true, group: group)
        group.addMessage(message1)
        group.addMessage(message2)

        do {
            try container!.mainContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        do {
            try container?.mainContext.delete(model: User.self)
        }
        catch {
            print("Error saving context: \(error)")
        }
        
        do {
            try container?.mainContext.delete(model: Group.self)
        }
        catch {
            print("Error saving context: \(error)")
        }
    
        return ChatView(user: user, viewModel: ChatViewModel(groupId: group.id))
        
     } else {
       print("Error creating container")
       return AnyView(EmptyView())
     }
}

