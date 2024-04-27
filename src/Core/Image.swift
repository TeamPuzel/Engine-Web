
public struct Image<T: Color>: Drawable {
    public private(set) var data: [T]
    public let width, height: Int
    
    public init(width: Int, height: Int, color: T = RGBA.clear) {
        self.width = width
        self.height = height
        self.data = .init(repeating: color, count: width * height)
    }
    
    public subscript(x: Int, y: Int) -> T {
        get { data[x + y * width] }
        set { data[x + y * width] = newValue }
    }
}

extension Image: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = [T]
    
    public init(arrayLiteral elements: [T]...) {
        self.width = elements[0].count
        self.height = elements.count
        self.data = elements.joined()
    }
}

public enum Images {
    public enum UI {
        public static let cursor: Image<RGBA> = [
            [.clear, .black, .clear, .clear, .clear, .clear],
            [.black, .white, .black, .clear, .clear, .clear],
            [.black, .white, .white, .black, .clear, .clear],
            [.black, .white, .white, .white, .black, .clear],
            [.black, .white, .white, .white, .white, .black],
            [.black, .white, .white, .black, .black, .clear],
            [.clear, .black, .black, .white, .black, .clear]
        ]
    }
}
