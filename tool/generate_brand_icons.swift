import AppKit
import ImageIO
import UniformTypeIdentifiers

private let arguments = CommandLine.arguments
guard arguments.count == 3 else {
  fputs("Usage: generate_brand_icons.swift <source-logo.png> <project-root>\n", stderr)
  exit(64)
}

let sourcePath = arguments[1]
let projectRoot = arguments[2]

guard let source = NSImage(contentsOfFile: sourcePath) else {
  fputs("Could not read source logo at \(sourcePath)\n", stderr)
  exit(66)
}

guard let sourceImage = source.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
  fputs("Could not rasterize source logo at \(sourcePath)\n", stderr)
  exit(65)
}

func writeIcon(size: Int, relativePath: String) throws {
  guard let context = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: size * 4,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
  ) else {
    throw NSError(domain: "KokAiIconGenerator", code: 1)
  }

  context.setFillColor(
    red: 247 / 255,
    green: 245 / 255,
    blue: 239 / 255,
    alpha: 1
  )
  context.fill(CGRect(x: 0, y: 0, width: size, height: size))
  context.interpolationQuality = .high

  let inset = CGFloat(size) * 0.095
  context.draw(
    sourceImage,
    in: CGRect(
      x: inset,
      y: inset,
      width: CGFloat(size) - (inset * 2),
      height: CGFloat(size) - (inset * 2)
    )
  )

  guard let outputImage = context.makeImage() else {
    throw NSError(domain: "KokAiIconGenerator", code: 2)
  }

  let output = URL(fileURLWithPath: projectRoot).appendingPathComponent(relativePath)
  guard let destination = CGImageDestinationCreateWithURL(
    output as CFURL,
    UTType.png.identifier as CFString,
    1,
    nil
  ) else {
    throw NSError(domain: "KokAiIconGenerator", code: 3)
  }

  CGImageDestinationAddImage(destination, outputImage, nil)
  guard CGImageDestinationFinalize(destination) else {
    throw NSError(domain: "KokAiIconGenerator", code: 4)
  }
}

let androidIcons: [(Int, String)] = [
  (48, "android/app/src/main/res/mipmap-mdpi/ic_launcher.png"),
  (72, "android/app/src/main/res/mipmap-hdpi/ic_launcher.png"),
  (96, "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"),
  (144, "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"),
  (192, "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"),
]

let iosIcons: [(Int, String)] = [
  (20, "Icon-App-20x20@1x.png"),
  (40, "Icon-App-20x20@2x.png"),
  (60, "Icon-App-20x20@3x.png"),
  (29, "Icon-App-29x29@1x.png"),
  (58, "Icon-App-29x29@2x.png"),
  (87, "Icon-App-29x29@3x.png"),
  (40, "Icon-App-40x40@1x.png"),
  (80, "Icon-App-40x40@2x.png"),
  (120, "Icon-App-40x40@3x.png"),
  (120, "Icon-App-60x60@2x.png"),
  (180, "Icon-App-60x60@3x.png"),
  (76, "Icon-App-76x76@1x.png"),
  (152, "Icon-App-76x76@2x.png"),
  (167, "Icon-App-83.5x83.5@2x.png"),
  (1024, "Icon-App-1024x1024@1x.png"),
]

do {
  for (size, path) in androidIcons {
    try writeIcon(size: size, relativePath: path)
  }

  let iosDirectory = "ios/Runner/Assets.xcassets/AppIcon.appiconset/"
  for (size, filename) in iosIcons {
    try writeIcon(size: size, relativePath: iosDirectory + filename)
  }
} catch {
  fputs("Failed to generate app icons: \(error)\n", stderr)
  exit(1)
}
