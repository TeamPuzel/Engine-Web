window.addEventListener("load", main)

/** @type WebAssembly.WebAssemblyInstantiatedSource */
let wasm
/** @type WebGLRenderingContext | null */
let context = null
/** @type WebGLTexture | null */
let displayTexture = null

let displayWidth = 128
let displayHeight = 128

let mouseX = 0
let mouseY = 0
let mouseLeft = false
let mouseRight = false

/** 
 * @param { string } code
 * @returns { number | null }
 */
function parseKey(code) {
    // console.log(code)
    switch (code) {
        case "KeyW": return 0
        case "ArrowUp": return 0
        
        case "KeyA": return 1
        case "ArrowLeft": return 1
        
        case "KeyS": return 2
        case "ArrowDown": return 2
        
        case "KeyD": return 3
        case "ArrowRight": return 3
        
        case "Comma": return 4
        case "Period": return 5
        default: return null
    }
}

async function main() {
    wasm = await WebAssembly.instantiateStreaming(
        fetch("/game.wasm"),
        { env }
    )
    await run()
}

async function run() {
    wasm.instance.exports.main()
        
    /** @type HTMLCanvasElement */
    const surface = document.getElementById("surface")
    surface.width = displayWidth
    surface.height = displayHeight
    surface.style.width = displayWidth * 4 + "px"
    surface.style.height = displayHeight * 4 + "px"
    surface.style.cursor = "none"
    surface.style.imageRendering = "pixelated"
    
    document.addEventListener("keydown", (event) => {
        if (event.key == "F10") surface.requestFullscreen()
    })
    
    document.addEventListener("mousemove", (event) => {
        const rect = surface.getBoundingClientRect()
        mouseX = Math.floor((event.pageX - rect.x) / 4)
        mouseY = Math.floor((event.pageY - rect.y) / 4)
    })
    
    surface.addEventListener("mousedown", (event) => {
        switch (event.button) {
            case 0: mouseLeft = true
            case 2: mouseRight = true
        }
    })
    
    document.addEventListener("mouseup", (event) => {
        switch (event.button) {
            case 0: mouseLeft = false
            case 2: mouseRight = false
        }
    })
    
    surface.addEventListener("contextmenu", (event) => {
        event.preventDefault()
        event.stopPropagation()
    })
    
    // WebGL setup
    
    context = surface.getContext("webgl")
    if (!context) { console.error("Could not create context."); return }
    
    context.clearColor(0, 0, 0, 1)
    context.clear(context.COLOR_BUFFER_BIT)
    
    const shader = createShader(context)
    
    // Coordinates
    
    const testRectangle = [
        -1.0, -1.0,    0, 1,
        -1.0,  1.0,    0, 0,
         1.0, -1.0,    1, 1,
        
         1.0, -1.0,    1, 1,
        -1.0,  1.0,    0, 0,
         1.0,  1.0,    1, 0
    ]
    
    const buf = context.createBuffer()
    context.bindBuffer(context.ARRAY_BUFFER, buf)
    context.bufferData(
        context.ARRAY_BUFFER,
        new Float32Array(testRectangle),
        context.STATIC_DRAW
    )
    
    const v_position = context.getAttribLocation(shader, "v_position")
    const v_texCoord = context.getAttribLocation(shader, "v_texCoord")
    
    context.vertexAttribPointer(v_position, 2, context.FLOAT, false, 16, 0)
    context.enableVertexAttribArray(v_position)
    
    context.vertexAttribPointer(v_texCoord, 2, context.FLOAT, false, 16,  8)
    context.enableVertexAttribArray(v_texCoord)
    
    // Texture
    
    displayTexture = context.createTexture()
    context.bindTexture(context.TEXTURE_2D, displayTexture)
    context.texParameteri(
        context.TEXTURE_2D,
        context.TEXTURE_WRAP_S,
        context.CLAMP_TO_EDGE
    )
    context.texParameteri(
        context.TEXTURE_2D,
        context.TEXTURE_WRAP_T,
        context.CLAMP_TO_EDGE
    )
    context.texParameteri(
        context.TEXTURE_2D,
        context.TEXTURE_MIN_FILTER,
        context.NEAREST
    )
    context.texParameteri(
        context.TEXTURE_2D,
        context.TEXTURE_MAG_FILTER,
        context.NEAREST
    )
    context.activeTexture(context.TEXTURE0)
    
    context.useProgram(shader)
    
    loop()
}

function loop() {
    wasm.instance.exports.resume()
    
    /** @type HTMLCanvasElement */
    const surface = document.getElementById("surface")
    surface.width = displayWidth * 4
    surface.height = displayHeight * 4
    surface.style.width = "100vw"
    surface.style.height = "100vh"
    
    window.requestAnimationFrame(loop)
}

// MARK: - Shaders

const vertexShader =
`
attribute vec2 v_position;
attribute vec2 v_texCoord;
varying   vec2 f_texCoord;

void main() {
    f_texCoord = v_texCoord;
    gl_Position = vec4(v_position, 0.0, 1.0);
}
`

const fragmentShader =
`
precision mediump float;

varying vec2      f_texCoord;
uniform sampler2D f_sampler;

void main() {
    gl_FragColor = texture2D(f_sampler, f_texCoord);
}
`

/** @param { WebGLRenderingContext } context */
function createShader(context) {
    const v = context.createShader(context.VERTEX_SHADER)
    const f = context.createShader(context.FRAGMENT_SHADER)
    
    context.shaderSource(v, vertexShader)
    context.shaderSource(f, fragmentShader)
    
    context.compileShader(v)
    context.compileShader(f)
    
    if (!context.getShaderParameter(v, context.COMPILE_STATUS)) {
        console.error("VERTEX SHADER: ", context.getShaderInfoLog(v))
    }
    if (!context.getShaderParameter(f, context.COMPILE_STATUS)) {
        console.error("FRAGMENT SHADER: ", context.getShaderInfoLog(f))
    }
    
    const p = context.createProgram()
    context.attachShader(p, v)
    context.attachShader(p, f)
    context.linkProgram(p)
    
    return p
}

// MARK: - Runtime

const env = {
    log,
    warn,
    error,
    draw,
    random,
    panicHandler,
    setDisplaySize,
    getAvailableWidth,
    getAvailableHeight,
    getMouseX,
    getMouseY,
    isMouseLeftPressed,
    isMouseRightPressed,
    timestamp
}

function draw(buf) {
    const array = new Uint8Array(
        wasm.instance.exports.memory.buffer,
        buf, displayWidth * displayHeight * 4
    )
    
    context.texImage2D(
        context.TEXTURE_2D, 0,
        context.RGBA, displayWidth, displayHeight, 0, context.RGBA, context.UNSIGNED_BYTE,
        array
    )
    
    context.viewport(0, 0, displayWidth * 4, displayHeight * 4)
    
    context.clear(context.COLOR_BUFFER_BIT)
    context.drawArrays(context.TRIANGLES, 0, 6)
}

function setDisplaySize(w, h) {
    displayWidth = w
    displayHeight = h
}

function getAvailableWidth() {
    return document.body.getBoundingClientRect().width
}
function getAvailableHeight() {
    return document.body.getBoundingClientRect().height
}

function getMouseX() { return mouseX }
function getMouseY() { return mouseY }
function isMouseLeftPressed() { return mouseLeft }
function isMouseRightPressed() { return mouseRight }

function random() { return Math.random() }

function panicHandler(pointer, length) {
    console.error("WASM Panic", decodeString(pointer, length))
    throw "Panic"
}

function decodeString(pointer, length) {
    const slice = new Uint8Array(
        wasm.instance.exports.memory.buffer,
        pointer,
        length
    )
    return new TextDecoder().decode(slice);
}

function log(pointer, length) {
    console.log(decodeString(pointer, length))
}

function warn(pointer, length) {
    console.warn(decodeString(pointer, length))
}

function error(pointer, length) {
    console.error(decodeString(pointer, length))
}

function timestamp() {
    return performance.now()
}
