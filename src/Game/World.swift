
final class World {
    private(set) var chunk: Chunk = .init()
    private(set) var entities: [Entity] = []
    private var viewLevel: Int = 65
    
    init() {
        self.addEntity(Player(x: 4, y: 4, z: 65))
    }
    
    func addEntity(_ entity: Entity) {
        self.entities.append(entity)
    }
    
    func step() {
        for entity in self.entities {
            
        }
    }
    
    func draw(renderer: inout Renderer) {
        for x in 0..<Chunk.side {
            for y in 0..<Chunk.side {
                
            }
        }
        
        for entity in self.entities {
            
        }
    }
}
