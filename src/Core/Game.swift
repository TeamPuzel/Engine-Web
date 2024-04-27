
/// A target independent game that can be run by a runtime for any platform.
protocol Game {
    init()
    // TODO(!!): Not actually called reliably. Make this framerate independed like the Rust version.
    /// Called reliably every tick.
    mutating func update(input: borrowing Input)
    /// Called every frame, does not guarantee timing and can even be skipped.
    mutating func frame(renderer: inout Renderer)
}
