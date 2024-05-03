
class Entity {
    var x: Int = 0
    var y: Int = 0
    var z: Int = 0
}

class Player: Entity {
    init(x: Int = 0, y: Int = 0, z: Int = 0) {
        super.init()
        self.x = x
        self.y = y
        self.z = z
    }
}
