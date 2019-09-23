# ⚠️  This Project Work In Progress ⚠️  

# SwiftTUI
**SwiftTUI** is framework for easily build **TUI** with swift.


## Usage

```swift
import SwiftTUI

struct Main: View {
  @State var model = Main.ViewModel

  var body: some View {
    List(model.items, action: model.selectItem) { item in
      Triangle()
      VStack(alignment: .leading) {
        Text(item.title)
        Text(item.subTitle)
          .color(.gray)
      }
    }
  }
}
```

## LICENSE
SwiftTUI is available under the MIT license. See the LICENSE file for more info.


