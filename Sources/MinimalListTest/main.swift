import SwiftTUI

struct MinimalListView: View {
    var body: some View {
        List {
            VStack {
                Text("Item 1")
                Text("Item 2")
            }
        }
    }
}

SwiftTUI.run {
    MinimalListView()
}