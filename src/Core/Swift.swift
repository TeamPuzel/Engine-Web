
// Since the embedded mode doesn't yet have some features this is a place
// for placeholder implementations.

public typealias CString = [CChar]

extension Array: @retroactive ExpressibleByUnicodeScalarLiteral where Element == CChar {}
extension Array: @retroactive ExpressibleByExtendedGraphemeClusterLiteral where Element == CChar {}

extension Array: @retroactive ExpressibleByStringLiteral where Element == CChar {
    public init(stringLiteral value: StaticString) {
        self = [CChar]()
        assert(value.isASCII)
        value.withUTF8Buffer { ptr in
            self.reserveCapacity(ptr.count + 1)
            for char in ptr { self.append(CChar(char)) }
            self.append(0)
        }
    }
    
    public init(_ value: StaticString) {
        self = []
        assert(value.isASCII)
        value.withUTF8Buffer { ptr in
            self.reserveCapacity(ptr.count + 1)
            for char in ptr {
                self.append(CChar(char))
            }
            self.append(0)
        }
    }
}

extension CChar: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension CChar: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}

extension CChar: @retroactive ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        assert(value.isASCII)
        self.init()
        value.withUTF8Buffer { ptr in
            self = Int8(bitPattern: ptr.first!)
        }
    }
}

public extension Array where Element: Collection {
    func joined() -> [Element.Element] {
        self.reduce(into: []) { acc, el in acc.append(contentsOf: el) }
    }
}

public extension BinaryInteger {
    func normalized(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
        (to.upperBound - to.lowerBound) / (from.upperBound - from.lowerBound) * (self - from.lowerBound) + to.upperBound
    }
}

public extension FloatingPoint {
    func normalized(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
        (to.upperBound - to.lowerBound) / (from.upperBound - from.lowerBound) * (self - from.lowerBound) + to.upperBound
    }
}
