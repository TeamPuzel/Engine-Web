
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

