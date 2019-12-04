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
## Development
Great helpful stackoverflow exists. reference from https://stackoverflow.com/questions/56251835/swift-package-manager-unable-to-compile-ncurses-installed-through-homebrew.
This section is quoted above stackoverflow links.

#### Quoted
If you want to generate a Xcode project, use the following command:

```shell
swift package generate-xcodeproj
```
- select the project node
- in Build settings enter Preprocessor in the search field in the upper right
- under Apple Clang - Preprocessing / Preprocess Macros add __NCURSES_H=1 for Debug and Release


## LICENSE
SwiftTUI is available under the MIT license. See the LICENSE file for more info.


