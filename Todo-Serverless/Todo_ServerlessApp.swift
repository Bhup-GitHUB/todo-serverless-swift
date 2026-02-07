import SwiftUI

@main
struct Todo_ServerlessApp: App {
    private let service = TodoAPIClient()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: TodoListViewModel(service: service))
        }
    }
}
