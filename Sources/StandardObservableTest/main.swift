import SwiftTUI
import Foundation

#if canImport(Observation)
import Observation

// Swift標準の@Observableマクロを使用したモデル
@Observable
class StandardUserModel {
    var name = "Guest"
    var age = 25
    var isVIP = false
    
    func updateName(to newName: String) {
        name = newName
    }
    
    func incrementAge() {
        age += 1
    }
    
    func toggleVIP() {
        isVIP.toggle()
    }
}

struct StandardObservableView: View {
    @Environment(StandardUserModel.self) var user: StandardUserModel?
    
    var body: some View {
        if let user = user {
            VStack(spacing: 2) {
                Text("Standard Observable Test")
                    .bold()
                    .padding(.bottom)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Name: \(user.name)")
                        .foregroundColor(user.isVIP ? .yellow : .white)
                    Text("Age: \(user.age)")
                    Text("VIP: \(user.isVIP ? "Yes" : "No")")
                        .foregroundColor(user.isVIP ? .green : .red)
                }
                .padding()
                .border()
                
                HStack(spacing: 2) {
                    Button("John") {
                        user.updateName(to: "John")
                    }
                    
                    Button("Jane") {
                        user.updateName(to: "Jane")
                    }
                    
                    Button("Age+") {
                        user.incrementAge()
                    }
                    
                    Button("VIP") {
                        user.toggleVIP()
                    }
                }
                .padding(.top)
                
                Text("Use buttons to update values")
                    .foregroundColor(.white)
                    .padding(.top)
            }
            .padding()
        } else {
            Text("No user model in environment")
                .foregroundColor(.red)
        }
    }
}

// テスト実行
let userModel = StandardUserModel()
SwiftTUI.run(
    StandardObservableView()
        .environment(userModel)
)

#else

// Observation frameworkが利用できない環境用のフォールバック
import SwiftTUI

struct FallbackView: View {
    var body: some View {
        VStack {
            Text("Standard Observable Test")
                .bold()
                .padding(.bottom)
            
            Text("This test requires Swift 5.9+")
                .foregroundColor(.yellow)
            Text("with Observation framework support")
                .foregroundColor(.yellow)
            
            Text("Current environment does not support")
                .padding(.top)
            Text("@Observable macro")
        }
        .padding()
        .border()
    }
}

SwiftTUI.run(FallbackView())

#endif