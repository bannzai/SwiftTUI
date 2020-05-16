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

#### ncurses version
Required ncurses version is over 6.1. See also [HOW TO INSTALL ncurses on MacOSX](https://gist.github.com/cnruby/960344)

#### Environment
- DEBUG_LOGGER_PATH: SwiftTUI debug log path. e.g) ~/development/SwiftTUI/debug.log.d
- PKG_CONFIG_PATH: your ncurses package config file path. e.g) "/usr/local/opt/ncurses/lib/pkgconfig"


#### Quoted
If you want to generate a Xcode project, use the following command:

```shell
swift package generate-xcodeproj
```


## LICENSE
SwiftTUI is available under the MIT license. See the LICENSE file for more info.


