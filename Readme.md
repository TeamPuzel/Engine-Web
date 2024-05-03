# Standalone Swift Game Engine

This is my (work in progress) no dependency platform independent game engine taking advantage of the new experimental Swift Embedded Mode.

It is intended to be built with `make`, but I am trying to get it working as a Swift package to get sourcekit-lsp support. It works but doesn't build properly.

### Example

```swift
import Assets

struct Main: Game {
    var mouse: (x: Int, y: Int) = (0, 0)
    
    mutating func update(input: borrowing Input) {
        self.mouse = input.mouse
    }
    
    mutating func frame(renderer: inout Renderer) {
        renderer.clear(with: RGBA.darkBlue)
        
        renderer.text("Hello, world!", x: 1, y: 1)
        
        let sheet = UnsafeTGAPointer(from: ASSETS_BUNDLE_SHEET_TGA_PTR).grid(itemWidth: 16, itemHeight: 16)
        renderer.draw(sheet[0, 0], x: 1, y: 16)
        
        renderer.draw(Images.UI.cursor, x: self.mouse.x - 1, y: self.mouse.y - 1)
    }
}
```

The renderer is fast and flexible thanks to heavy use of generics, and built around a `Drawable` protocol with methods for lazily operating on pixels, such as:
```swift
func colorMap<C: Color>(map: @escaping (C) -> C) -> ColorMap<Self, C>
```
