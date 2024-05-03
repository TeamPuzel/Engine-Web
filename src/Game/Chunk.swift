
final class Chunk {
    static var side: Int = 32
    static var depth: Int = 128
    
    private var storage: [Block]
    
    init() {
        self.storage = .init(repeating: Air(), count: Self.side * Self.side * Self.depth)
        
        for x in 0..<Self.side {
            for y in 0..<Self.side {
                for z in 0..<Self.depth {
                    if z <= 64 { self[x, y, z] = Stone() }
                    if z == 65 && x == 0 || x == 31 || y == 0 || y == 31 { self[x, y, z] = Stone() }
                }
            }
        }
    }
    
    subscript(x: Int, y: Int, z: Int) -> Block {
        get { self.storage[x * (Self.side * Self.depth) + y * Self.depth + z] }
        set { self.storage[x * (Self.side * Self.depth) + y * Self.depth + z] = newValue }
    }
}
