
// Since the embedded mode doesn't yet have some features this is a place
// for placeholder implementations.

struct CString {
    var buffer: [CChar]
}

extension CString: ExpressibleByStringLiteral {
    init(stringLiteral value: StaticString) {
        self.buffer = [CChar]()
        value.withUTF8Buffer { ptr in
            self.buffer.reserveCapacity(ptr.count + 1)
            for char in ptr { self.buffer.append(CChar(char)) }
            self.buffer.append(0)
        }
    }
    
    init(_ value: StaticString) {
        self.buffer = []
        assert(value.isASCII)
        value.withUTF8Buffer { ptr in
            self.buffer.reserveCapacity(ptr.count + 1)
            for char in ptr {
                self.buffer.append(CChar(char))
            }
            self.buffer.append(0)
        }
    }
}

extension Array where Element: Collection {
    func joined() -> [Element.Element] {
        self.reduce(into: []) { acc, el in acc.append(contentsOf: el) }
    }
}

extension BinaryInteger {
    func normalized(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
        (to.upperBound - to.lowerBound) / (from.upperBound - from.lowerBound) * (self - from.lowerBound) + to.upperBound
    }
}

extension FloatingPoint {
    func normalized(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
        (to.upperBound - to.lowerBound) / (from.upperBound - from.lowerBound) * (self - from.lowerBound) + to.upperBound
    }
}
