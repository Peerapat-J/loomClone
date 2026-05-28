import AppKit
import Foundation

struct IconSpec {
    let filename: String
    let pixels: Int
}

let specs = [
    IconSpec(filename: "icon_16x16.png", pixels: 16),
    IconSpec(filename: "icon_16x16@2x.png", pixels: 32),
    IconSpec(filename: "icon_32x32.png", pixels: 32),
    IconSpec(filename: "icon_32x32@2x.png", pixels: 64),
    IconSpec(filename: "icon_128x128.png", pixels: 128),
    IconSpec(filename: "icon_128x128@2x.png", pixels: 256),
    IconSpec(filename: "icon_256x256.png", pixels: 256),
    IconSpec(filename: "icon_256x256@2x.png", pixels: 512),
    IconSpec(filename: "icon_512x512.png", pixels: 512),
    IconSpec(filename: "icon_512x512@2x.png", pixels: 1024)
]

guard CommandLine.arguments.count == 2 else {
    FileHandle.standardError.write(Data("usage: generate_app_icon.swift <iconset-output-dir>\n".utf8))
    exit(2)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

func drawIcon(pixels: Int) -> Data? {
    let size = CGFloat(pixels)
    guard
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixels,
            pixelsHigh: pixels,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ),
        let context = NSGraphicsContext(bitmapImageRep: bitmap)
    else {
        return nil
    }

    bitmap.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    defer { NSGraphicsContext.restoreGraphicsState() }

    let bounds = NSRect(x: 0, y: 0, width: size, height: size)
    NSColor(calibratedRed: 0.082, green: 0.125, blue: 0.169, alpha: 1).setFill()
    NSBezierPath(roundedRect: bounds, xRadius: size * 0.215, yRadius: size * 0.215).fill()

    NSColor(calibratedRed: 0.251, green: 0.851, blue: 0.659, alpha: 1).setStroke()
    let ring = NSBezierPath(ovalIn: bounds.insetBy(dx: size * 0.225, dy: size * 0.225))
    ring.lineWidth = max(size * 0.07, 1)
    ring.stroke()

    NSColor.white.setFill()
    NSBezierPath(ovalIn: bounds.insetBy(dx: size * 0.39, dy: size * 0.39)).fill()

    NSColor(calibratedRed: 0.251, green: 0.851, blue: 0.659, alpha: 1).setFill()
    let cameraBody = NSRect(
        x: size * 0.67,
        y: size * 0.39,
        width: size * 0.17,
        height: size * 0.22
    )
    NSBezierPath(roundedRect: cameraBody, xRadius: size * 0.035, yRadius: size * 0.035).fill()

    return bitmap.representation(using: .png, properties: [:])
}

for spec in specs {
    autoreleasepool {
        guard let png = drawIcon(pixels: spec.pixels) else {
            FileHandle.standardError.write(Data("failed to render \(spec.filename)\n".utf8))
            exit(1)
        }

        let fileURL = outputURL.appendingPathComponent(spec.filename)
        do {
            try png.write(to: fileURL, options: .atomic)
        } catch {
            FileHandle.standardError.write(Data("failed to write \(spec.filename): \(error)\n".utf8))
            exit(1)
        }
    }
}
