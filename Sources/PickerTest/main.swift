import SwiftTUI

struct PickerTestView: View {
    @State private var selectedColor = "Red"
    @State private var selectedSize = 2
    @State private var selectedLanguage = "Swift"
    
    let colors = ["Red", "Green", "Blue", "Yellow", "Purple"]
    let sizes: [(Int, String)] = [
        (1, "Small"),
        (2, "Medium"),
        (3, "Large"),
        (4, "Extra Large")
    ]
    let languages = ["Swift", "Python", "JavaScript", "Rust", "Go", "Ruby"]
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Picker Component Test")
                .bold()
                .padding()
                .border()
            
            VStack(spacing: 2) {
                Picker("Color", selection: $selectedColor, options: colors)
                    .padding()
                
                Picker("Size", selection: $selectedSize, options: sizes)
                    .padding()
                
                Picker("Language", selection: $selectedLanguage, options: languages)
                    .padding()
            }
            .border()
            .padding()
            
            VStack(spacing: 1) {
                Text("Current Selections:")
                    .bold()
                    .padding(.bottom)
                
                HStack {
                    Text("Color:")
                    Text(selectedColor)
                        .foregroundColor(.cyan)
                }
                
                HStack {
                    Text("Size:")
                    Text(sizes.first(where: { $0.0 == selectedSize })?.1 ?? "Unknown")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Language:")
                    Text(selectedLanguage)
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .border()
            
            Text("Instructions:")
                .foregroundColor(.cyan)
                .padding(.top)
            
            VStack {
                Text("• Tab: Move focus between pickers")
                Text("• Enter/Space: Open/close dropdown")
                Text("• ↑/↓: Navigate options (when open)")
                Text("• Enter: Select option")
                Text("• ESC: Close dropdown / Exit program")
            }
            .foregroundColor(.white)
            .padding()
        }
    }
}

SwiftTUI.run {
    PickerTestView()
}