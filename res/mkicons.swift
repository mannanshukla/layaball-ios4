import AppKit
func bitmap(_ w: Int, _ h: Int) -> NSBitmapImageRep { return NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)! }
func save(_ rep: NSBitmapImageRep, _ path: String) { try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path)) }
// app icon: lime background, monochrome white 8-ball glyph (matches the train on Next Train)
func icon(_ size: Int, _ path: String) {
    let rep = bitmap(size, size); NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let s = CGFloat(size)
    NSGradient(starting: NSColor(deviceRed: 0.79, green: 0.94, blue: 0.23, alpha: 1), ending: NSColor(deviceRed: 0.69, green: 0.89, blue: 0.02, alpha: 1))!.draw(in: NSRect(x: 0, y: 0, width: s, height: s), angle: -90)
    let d = s*0.70, ball = NSRect(x: (s-d)/2, y: (s-d)/2, width: d, height: d)
    NSColor(white: 0, alpha: 0.18).setFill(); NSBezierPath(ovalIn: ball.offsetBy(dx: 0, dy: -s*0.015)).fill()
    NSColor.white.setFill(); NSBezierPath(ovalIn: ball).fill()
    let wd = d*0.46, win = NSRect(x: s/2 - wd/2, y: s/2 - wd/2, width: wd, height: wd)
    NSColor(deviceRed: 0.72, green: 0.90, blue: 0.10, alpha: 1).setFill(); NSBezierPath(ovalIn: win).fill()
    let p = NSMutableParagraphStyle(); p.alignment = .center
    ("8" as NSString).draw(in: NSRect(x: win.minX, y: win.minY + wd*0.05, width: wd, height: wd*0.9), withAttributes: [.font: NSFont.boldSystemFont(ofSize: wd*0.72), .foregroundColor: NSColor.white, .paragraphStyle: p])
    NSGraphicsContext.restoreGraphicsState(); save(rep, path)
}
icon(57, "Icon.png"); icon(114, "Icon@2x.png"); icon(256, "Icon-preview.png")
// tab bar glyphs: white alpha silhouettes, 30x30 and 60x60
func glyph(_ name: String, _ draw: (CGFloat) -> Void) {
    for (sz, suffix) in [(30, ""), (60, "@2x")] {
        let rep = bitmap(sz, sz); NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        NSColor.white.set(); draw(CGFloat(sz)); NSGraphicsContext.restoreGraphicsState(); save(rep, "\(name)\(suffix).png")
    }
}
glyph("tab-ball") { s in NSBezierPath(ovalIn: NSRect(x: s*0.1, y: s*0.1, width: s*0.8, height: s*0.8)).fill(); NSColor.clear.set()
    let w = NSBezierPath(ovalIn: NSRect(x: s*0.33, y: s*0.33, width: s*0.34, height: s*0.34)); NSGraphicsContext.current!.cgContext.setBlendMode(.clear); w.fill(); NSGraphicsContext.current!.cgContext.setBlendMode(.normal) }
glyph("tab-decide") { s in for i in 0..<3 { let y = s*0.15 + CGFloat(i)*s*0.27; NSBezierPath(roundedRect: NSRect(x: s*0.1, y: y, width: s*(0.8 - CGFloat(i)*0.2), height: s*0.18), xRadius: s*0.09, yRadius: s*0.09).fill() } }
glyph("tab-rps") { s in NSBezierPath(ovalIn: NSRect(x: s*0.08, y: s*0.2, width: s*0.38, height: s*0.38)).fill(); NSBezierPath(rect: NSRect(x: s*0.52, y: s*0.18, width: s*0.4, height: s*0.5)).fill(); let p = NSBezierPath(); p.move(to: NSPoint(x: s*0.2, y: s*0.9)); p.line(to: NSPoint(x: s*0.8, y: s*0.65)); p.lineWidth = s*0.1; p.stroke() }
glyph("tab-vibe") { s in let p = NSBezierPath(); p.move(to: NSPoint(x: s*0.1, y: s*0.5)); for i in 1...8 { let x = s*0.1 + CGFloat(i)*s*0.1; p.line(to: NSPoint(x: x, y: s*0.5 + (i % 2 == 0 ? -1 : 1) * s*0.25)) }; p.lineWidth = s*0.12; p.lineJoinStyle = .round; p.stroke() }
print("icons ok")
