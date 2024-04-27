
import Runtime

struct Environment {
    @_extern(c) @_extern(wasm, module: "env", name: "random")
    static func random() -> Double
    
    @_extern(c) @_extern(wasm, module: "env", name: "draw")
    static func draw(buf: UnsafeRawPointer)
    
    @_extern(c) @_extern(wasm, module: "env", name: "setDisplaySize")
    static func setDisplaySize(w: UInt, h: UInt)
    
    @_extern(c) @_extern(wasm, module: "env", name: "getMouseX")
    static func getMouseX() -> Int
    
    @_extern(c) @_extern(wasm, module: "env", name: "getMouseY")
    static func getMouseY() -> Int
    
    @_extern(c) @_extern(wasm, module: "env", name: "log")
    static func log(string: UnsafePointer<CChar>, count: Int)
    
    @_extern(c) @_extern(wasm, module: "env", name: "warn")
    static func warn(string: UnsafePointer<CChar>, count: Int)
    
    @_extern(c) @_extern(wasm, module: "env", name: "error")
    static func error(string: UnsafePointer<CChar>, count: Int)
    
    @_extern(c) @_extern(wasm, module: "env", name: "getAvailableWidth")
    static func getAvailableWidth() -> Int
    
    @_extern(c) @_extern(wasm, module: "env", name: "getAvailableHeight")
    static func getAvailableHeight() -> Int
}

var instance: Main! // TODO(!) Use `any Game` once existentials are supported
var renderer: Renderer!
var input = Input()

@_expose(wasm, "main")
internal func main() {
    initialize() // Set up runtime
    
    instance = .init()
    renderer = Renderer(width: 128, height: 128)
    Environment.setDisplaySize(w: UInt(renderer.width), h: UInt(renderer.height))
}

@_expose(wasm, "resume")
internal func resume() {
    let newWidth = Environment.getAvailableWidth() / 4
    let newHeight = Environment.getAvailableHeight() / 4
    if newWidth != renderer.width || newHeight != renderer.height {
        renderer.resize(width: newWidth, height: newHeight)
        Environment.setDisplaySize(w: UInt(renderer.width), h: UInt(renderer.height))
    }
    
    // TODO(!): Timestamp
    
    input.mouse.x = Environment.getMouseX()
    input.mouse.y = Environment.getMouseY()
    
    instance.update(input: input)
    instance.frame(renderer: &renderer)
    
    Environment.draw(buf: renderer.display.data)
}


// MARK: - Swift Runtime

fileprivate let pageSize: UInt = 65536

func initialize() {
    memory_end = .init(bitPattern: UInt(memory_size()) * pageSize)
}

@_cdecl("impl_posix_memalign")
func posix_memalign(memptr: UnsafeMutablePointer<UnsafeMutableRawPointer>, alignment: UInt, size: UInt) -> Int32 {
    if UInt(bitPattern: memory_end) + size > UInt(memory_size()) * pageSize {
        memory_grow(UInt32(1 + size / pageSize))
    }
    
    memptr.pointee = memory_end
    memory_end = .init(bitPattern: UInt(bitPattern: memory_end) + size)
    
    return 0
}

@_cdecl("impl_free")
func free(_ ptr: UnsafeMutableRawPointer?) {
    // :)
}

@_cdecl("memset")
func memset(str: UnsafeMutableRawPointer, c: Int32, n: Int) -> UnsafeMutableRawPointer {
    for i in 0..<n { str.storeBytes(of: c, toByteOffset: i, as: Int32.self) }
    return str
}

@_cdecl("impl_arc4random")
func arc4random() -> UInt32 { UInt32(Environment.random().normalized(from: 0...1, to: 0...Double.greatestFiniteMagnitude)) }

@_cdecl("impl_arc4random_buf")
func arc4random_buf(_ buf: UnsafeMutableRawPointer, _ count: UInt) {
    for i in 0..<count {
        buf.storeBytes(of: UInt8(truncatingIfNeeded: arc4random()), toByteOffset: Int(i), as: UInt8.self)
    }
}
