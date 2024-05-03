
import Assets

struct Main: Game {
    var mouse: (x: Int, y: Int) = (0, 0)
    
    mutating func update(input: borrowing Input) {
        self.mouse = input.mouse
    }
    
    mutating func frame(renderer: inout Renderer) {
        renderer.clear(with: RGBA.darkBlue)
        renderer.draw(Images.UI.cursor, x: self.mouse.x - 1, y: self.mouse.y - 1)
        renderer.text("Hello, world!", x: 1, y: 1)
    }
}

