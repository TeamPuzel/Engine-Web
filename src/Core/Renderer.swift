
// NOTE: Renderer can't be a protocol as that would disallow default arguments.
// To make it generic it would need to delegate the exact functionality to a generic
// `RenderTarget` protocol. Silly thing to do just to work around Swift yet again having missing
// features specifically for protocols. Even more annoying than not allowing namespaces.
public struct Renderer/*: ~Copyable */{
    internal var display: Image<RGBA>
    
    public var width: Int { self.display.width }
    public var height: Int { self.display.height }
    
    internal init(width: Int, height: Int) {
        self.display = .init(width: width, height: height, color: .black)
    }
    
    public mutating func resize(width: Int, height: Int) {
        self.display = .init(width: width, height: height, color: .black)
    }
    
    public mutating func clear(with color: some Color = RGBA.black) {
        for x in 0..<self.display.width {
            for y in 0..<self.display.height {
                self.pixel(x: x, y: y, color: color)
            }
        }
    }
    
    public mutating func pixel(x: Int, y: Int, color: some Color = RGBA.white) {
        if x < 0 || y < 0 || x >= display.width || y >= display.height { return }
        self.display[x, y] = .init(color)
    }
    
    public mutating func draw(_ drawable: some Drawable, x: Int, y: Int) {
        for ix in 0..<drawable.width {
            for iy in 0..<drawable.height {
                // TODO(!) Handle opacity with blending modes
                let color = drawable[ix, iy]
                if color.a == 255 {
                    self.pixel(x: ix + x, y: iy + y, color: color)
                }
            }
        }
    }
    
    public mutating func rectangle(x: Int, y: Int, w: Int, h: Int, color: some Color = RGBA.white, fill: Bool = false) {
        for ix in 0..<w {
            for iy in 0..<h {
                if ix + x == x || ix + x == x + w - 1 || iy + y == y || iy + y == y + h - 1 || fill {
                    self.pixel(x: ix + x, y: iy + y, color: color)
                }
            }
        }
    }
    
    public mutating func circle(x: Int, y: Int, r: Int, color: some Color = RGBA.white, fill: Bool = false) {
        guard r >= 0 else { return }
        for ix in (x - r)..<(x + r + 1) {
            for iy in (y - r)..<(y + r + 1) {
                let distance = Int(Double(((ix - x) * (ix - x)) + ((iy - y) * (iy - y))).squareRoot().rounded())
                if fill {
                    if distance <= r { pixel(x: ix, y: iy, color: color) }
                } else {
                    if distance == r { pixel(x: ix, y: iy, color: color) }
                }
            }
        }
    }
    
//    // TODO(!!): Implement text once Embedded Swift has String support
//    public mutating func text(_ string: some StringProtocol, x: Int, y: Int, foreground: Color = .white, background: Color? = nil, wrap: Bool = false) {
//        let symbols = string.compactMap { char in Symbol(char) }
//        for (off, sym) in symbols.enumerated() {
//            if x + (4 * off) < display.width {
//                self.symbol(sym, x: x + (off * 4), y: y, foreground: foreground, background: background)
//            } else if wrap {
//                self.text(
//                    string.suffix(from: string.index(string.startIndex, offsetBy: off)),
//                    x: 1, y: y + 6, foreground: foreground, background: background, wrap: wrap
//                )
//                break
//            } else {
//                break
//            }
//        }
//    }
//    
//    private mutating func symbol(_ sym: Symbol, x: Int, y: Int, foreground: Color, background: Color?) {
//        // Background
//        if let bgc = background {
//            self.rectangle(x: x - 1, y: y - 1, w: 5, h: 7, color: bgc, fill: true)
//        }
//        // Foreground
//        for (iy, column) in sym.data.enumerated() {
//            for (ix, flag) in column.enumerated() {
//                if flag { self.pixel(x: x + ix, y: y + iy, color: foreground) }
//            }
//        }
//    }
}

public protocol Drawable {
    associatedtype Layout: Color
    var width: Int { get }
    var height: Int { get }
    subscript(x: Int, y: Int) -> Layout { get }
}

public extension Drawable {
    func slice(x: Int, y: Int, width: Int, height: Int) -> DrawableSlice<Self> {
        .init(self, x: x, y: y, width: width, height: height)
    }
    
    func grid(itemWidth: Int, itemHeight: Int) -> DrawableGrid<Self> {
        .init(self, itemWidth: itemWidth, itemHeight: itemHeight)
    }
    
    func colorMap<C: Color>(map: @escaping (C) -> C) -> ColorMap<Self, C> { .init(self, map: map) }
    
    func colorMap<C: Color>(_ existing: C, to new: C) -> ColorMap<Self, C> {
        self.colorMap { $0 == existing ? new : $0 }
    }
    
    /// Shorthand for flattening a nested structure of lazy drawables into a trivial image, for
    /// cases where using memory is less costly vs constantly recomputing all operations.
    func flatten() -> Image<Layout> {
        fatalError() // TODO(!!!!!)
    }
}

/// A lazy 2d slice of another abstract `Drawable`, and a `Drawable` in itself.
/// Useful for example for slicing sprites from a sprite sheet.
public struct DrawableSlice<Inner: Drawable>: Drawable {
    public let inner: Inner
    private let x: Int
    private let y: Int
    public let width: Int
    public let height: Int
    
    public init(_ inner: Inner, x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.inner = inner
    }
    
    public subscript(x: Int, y: Int) -> Inner.Layout { inner[x + self.x, y + self.y] }
}

/// A lazy grid of equal size `Drawable` slices, for example a sprite sheet, tile map or tile font.
public struct DrawableGrid<Inner: Drawable>: Drawable {
    public let inner: Inner
    public var width: Int { inner.width }
    public var height: Int { inner.height }
    public let itemWidth: Int
    public let itemHeight: Int
    
    public init(_ inner: Inner, itemWidth: Int, itemHeight: Int) {
        self.inner = inner
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
    }
    
    public subscript(x: Int, y: Int) -> Inner.Layout { inner[x, y] }
    public subscript(x: Int, y: Int) -> DrawableSlice<Inner> {
        inner.slice(x: x * itemWidth, y: y * itemHeight, width: itemWidth, height: itemHeight)
    }
}

/// A lazy wrapper around a drawable, applies a map function to every color it yields.
public struct ColorMap<Inner: Drawable, L: Color>: Drawable {
    public let inner: Inner
    private let map: (L) -> L
    public var width: Int { inner.width }
    public var height: Int { inner.height }
    
    init(_ inner: Inner, map: @escaping (L) -> L) {
        self.inner = inner
        self.map = map
    }
    
    public subscript(x: Int, y: Int) -> Inner.Layout { .init(map(.init(inner[x, y]))) }
}

// TODO(!): This should be a `TileFont`. Use `Font` for a generic font protocol describing only
//          the mapping of characters to abstract drawables.
public struct Font<Source: Drawable> {
    public let inner: DrawableGrid<Source>
    public let map: (CChar) -> (x: Int, y: Int)
    
    public init(source: Source, charWidth: Int, charHeight: Int, map: @escaping (CChar) -> (x: Int, y: Int)) {
        self.inner = source.grid(itemWidth: charWidth, itemHeight: charHeight)
        self.map = map
    }
    
    public subscript(char: CChar) -> DrawableSlice<Source> { inner[map(char).x, map(char).y] }
}
