import AppKit
import AVFoundation
import QuartzCore

struct SourceSegment {
    let start: Double
    let duration: Double
}

let sourceURL = URL(fileURLWithPath: CommandLine.arguments[1])
let iconURL = URL(fileURLWithPath: CommandLine.arguments[2])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[3])
let musicURL = URL(fileURLWithPath: NSTemporaryDirectory())
    .appendingPathComponent("minibilge_ad_music.caf")

let renderSize = CGSize(width: 1080, height: 1920)
let timescale: CMTimeScale = 600
let segments = [
    SourceSegment(start: 0.0, duration: 3.0),
    SourceSegment(start: 4.0, duration: 3.0),
    SourceSegment(start: 11.8, duration: 5.2),
    SourceSegment(start: 31.8, duration: 7.7),
]

func time(_ seconds: Double) -> CMTime {
    CMTime(seconds: seconds, preferredTimescale: timescale)
}

func color(_ hex: UInt32, alpha: CGFloat = 1) -> CGColor {
    let red = CGFloat((hex >> 16) & 0xff) / 255
    let green = CGFloat((hex >> 8) & 0xff) / 255
    let blue = CGFloat(hex & 0xff) / 255
    return CGColor(red: red, green: green, blue: blue, alpha: alpha)
}

func makeTextLayer(
    text: String,
    frame: CGRect,
    fontSize: CGFloat,
    color: CGColor = NSColor.white.cgColor,
    alignment: CATextLayerAlignmentMode = .center,
    fontName: String = "AvenirNext-Heavy"
) -> CALayer {
    let layer = CALayer()
    layer.frame = frame
    layer.contentsScale = 2
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment == .left ? .left : (alignment == .right ? .right : .center)
    paragraph.lineBreakMode = .byWordWrapping
    let font = NSFont(name: fontName, size: fontSize)
        ?? NSFont.systemFont(ofSize: fontSize, weight: .bold)
    let textColor = NSColor(cgColor: color) ?? .white
    let attributedText = NSAttributedString(
        string: text,
        attributes: [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraph,
        ]
    )
    let image = NSImage(size: frame.size, flipped: true) { rect in
        attributedText.draw(
            with: rect.insetBy(dx: 4, dy: 4),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return true
    }
    layer.contents = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    layer.contentsGravity = .resizeAspect
    layer.shadowColor = NSColor.black.cgColor
    layer.shadowOpacity = 0.28
    layer.shadowOffset = CGSize(width: 0, height: -3)
    layer.shadowRadius = 5
    return layer
}

func addVisibilityAnimation(
    to layer: CALayer,
    start: Double,
    duration: Double,
    fade: Double = 0.22,
    fadeIn: Bool = true,
    fadeOut: Bool = true
) {
    layer.opacity = 0
    let animation = CAKeyframeAnimation(keyPath: "opacity")
    let fadeRatio = min(0.25, fade / duration)
    animation.values = [fadeIn ? 0 : 1, 1, 1, fadeOut ? 0 : 1]
    animation.keyTimes = [0, NSNumber(value: fadeRatio), NSNumber(value: 1 - fadeRatio), 1]
    animation.beginTime = AVCoreAnimationBeginTimeAtZero + start
    animation.duration = duration
    animation.isRemovedOnCompletion = false
    animation.fillMode = .both
    layer.add(animation, forKey: "visibility")
}

func makePill(
    title: String,
    subtitle: String? = nil,
    start: Double,
    duration: Double
) -> CALayer {
    let height: CGFloat = subtitle == nil ? 126 : 164
    let container = CALayer()
    container.frame = CGRect(x: 80, y: 1650 - (height - 126), width: 920, height: height)
    container.backgroundColor = color(0x24145F, alpha: 0.88)
    container.cornerRadius = 42
    container.borderWidth = 3
    container.borderColor = color(0xBFAEFF, alpha: 0.7)
    container.shadowColor = NSColor.black.cgColor
    container.shadowOpacity = 0.3
    container.shadowRadius = 16
    container.shadowOffset = CGSize(width: 0, height: -6)

    let titleLayer = makeTextLayer(
        text: title,
        frame: CGRect(x: 35, y: subtitle == nil ? 27 : 70, width: 850, height: 72),
        fontSize: 45
    )
    container.addSublayer(titleLayer)

    if let subtitle {
        let subtitleLayer = makeTextLayer(
            text: subtitle,
            frame: CGRect(x: 35, y: 25, width: 850, height: 50),
            fontSize: 27,
            color: color(0xE7E0FF),
            fontName: "AvenirNext-DemiBold"
        )
        container.addSublayer(subtitleLayer)
    }

    addVisibilityAnimation(to: container, start: start, duration: duration)
    return container
}

func synthesizeMusic(duration: Double, outputURL: URL) throws {
    try? FileManager.default.removeItem(at: outputURL)
    let sampleRate = 44_100.0
    let channels: AVAudioChannelCount = 2
    let frameCount = AVAudioFrameCount(duration * sampleRate)
    guard
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: channels,
            interleaved: false
        ),
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
    else {
        throw NSError(domain: "MiniBilgeAd", code: 1)
    }

    buffer.frameLength = frameCount
    let melody = [523.25, 659.25, 783.99, 659.25, 587.33, 698.46, 880.0, 698.46]
    let beatLength = 0.42

    for channel in 0..<Int(channels) {
        guard let samples = buffer.floatChannelData?[channel] else { continue }
        for frame in 0..<Int(frameCount) {
            let currentTime = Double(frame) / sampleRate
            let beatIndex = Int(currentTime / beatLength)
            let beatTime = currentTime.truncatingRemainder(dividingBy: beatLength)
            let frequency = melody[beatIndex % melody.count]
            let envelope = exp(-beatTime * 7.5)
            let sparkle = sin(2 * .pi * frequency * currentTime) * envelope * 0.09
            let harmony = sin(2 * .pi * frequency * 0.5 * currentTime) * envelope * 0.035

            let pulseTime = currentTime.truncatingRemainder(dividingBy: beatLength * 2)
            let pulseEnvelope = exp(-pulseTime * 18)
            let pulse = sin(2 * .pi * 110 * currentTime) * pulseEnvelope * 0.05

            let fadeIn = min(1, currentTime / 0.7)
            let fadeOut = min(1, max(0, duration - currentTime) / 1.2)
            samples[frame] = Float((sparkle + harmony + pulse) * fadeIn * fadeOut)
        }
    }

    let audioFile = try AVAudioFile(forWriting: outputURL, settings: format.settings)
    try audioFile.write(from: buffer)
}

func run() async throws {
    try? FileManager.default.removeItem(at: outputURL)

    let sourceAsset = AVURLAsset(url: sourceURL)
    guard let sourceVideoTrack = try await sourceAsset.loadTracks(withMediaType: .video).first else {
        throw NSError(
            domain: "MiniBilgeAd",
            code: 2,
            userInfo: [NSLocalizedDescriptionKey: "Kaynak video bulunamadı"]
        )
    }

    let naturalSize = try await sourceVideoTrack.load(.naturalSize)
    let preferredTransform = try await sourceVideoTrack.load(.preferredTransform)
    let transformedRect = CGRect(origin: .zero, size: naturalSize).applying(preferredTransform)
    let displaySize = CGSize(
        width: abs(transformedRect.width),
        height: abs(transformedRect.height)
    )

    let composition = AVMutableComposition()
    guard
        let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )
    else {
        throw NSError(domain: "MiniBilgeAd", code: 3)
    }

    var cursor = CMTime.zero
    for segment in segments {
        let range = CMTimeRange(start: time(segment.start), duration: time(segment.duration))
        try compositionVideoTrack.insertTimeRange(range, of: sourceVideoTrack, at: cursor)
        cursor = cursor + range.duration
    }
    let totalDuration = CMTimeGetSeconds(cursor)

    try synthesizeMusic(duration: totalDuration, outputURL: musicURL)
    let musicAsset = AVURLAsset(url: musicURL)
    if
        let sourceMusicTrack = try await musicAsset.loadTracks(withMediaType: .audio).first,
        let compositionAudioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )
    {
        try compositionAudioTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: cursor),
            of: sourceMusicTrack,
            at: .zero
        )
    }

    let videoComposition = AVMutableVideoComposition()
    videoComposition.renderSize = renderSize
    videoComposition.frameDuration = CMTime(value: 1, timescale: 30)

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRange(start: .zero, duration: cursor)
    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)

    let normalizedTransform = preferredTransform.concatenating(
        CGAffineTransform(
            translationX: -transformedRect.origin.x,
            y: -transformedRect.origin.y
        )
    )
    let scale = min(renderSize.width / displaySize.width, renderSize.height / displaySize.height)
    let scaledSize = CGSize(width: displaySize.width * scale, height: displaySize.height * scale)
    let translateX = (renderSize.width - scaledSize.width) / 2
    let translateY = (renderSize.height - scaledSize.height) / 2
    let finalTransform = normalizedTransform
        .concatenating(CGAffineTransform(scaleX: scale, y: scale))
        .concatenating(CGAffineTransform(translationX: translateX, y: translateY))
    layerInstruction.setTransform(finalTransform, at: .zero)
    instruction.layerInstructions = [layerInstruction]
    videoComposition.instructions = [instruction]

    let parentLayer = CALayer()
    parentLayer.frame = CGRect(origin: .zero, size: renderSize)
    parentLayer.isGeometryFlipped = false

    let background = CAGradientLayer()
    background.frame = parentLayer.bounds
    background.colors = [
        color(0x7CCAF0),
        color(0x8A83E8),
        color(0xB18BE0),
    ]
    background.startPoint = CGPoint(x: 0.5, y: 1)
    background.endPoint = CGPoint(x: 0.5, y: 0)
    parentLayer.addSublayer(background)

    let glow = CALayer()
    glow.frame = CGRect(x: 25, y: 0, width: 1030, height: 1920)
    glow.backgroundColor = color(0xFFFFFF, alpha: 0.10)
    glow.cornerRadius = 55
    parentLayer.addSublayer(glow)

    let videoLayer = CALayer()
    videoLayer.frame = parentLayer.bounds
    parentLayer.addSublayer(videoLayer)

    let sideShadeLeft = CAGradientLayer()
    sideShadeLeft.frame = CGRect(x: 0, y: 0, width: 140, height: 1920)
    sideShadeLeft.colors = [color(0x22104B, alpha: 0.62), color(0x22104B, alpha: 0)]
    sideShadeLeft.startPoint = CGPoint(x: 0, y: 0.5)
    sideShadeLeft.endPoint = CGPoint(x: 1, y: 0.5)
    parentLayer.addSublayer(sideShadeLeft)

    let sideShadeRight = CAGradientLayer()
    sideShadeRight.frame = CGRect(x: 940, y: 0, width: 140, height: 1920)
    sideShadeRight.colors = [color(0x22104B, alpha: 0), color(0x22104B, alpha: 0.62)]
    sideShadeRight.startPoint = CGPoint(x: 0, y: 0.5)
    sideShadeRight.endPoint = CGPoint(x: 1, y: 0.5)
    parentLayer.addSublayer(sideShadeRight)

    let intro = CALayer()
    intro.frame = parentLayer.bounds
    intro.backgroundColor = color(0x6E55DF, alpha: 0.97)

    if let iconImage = NSImage(contentsOf: iconURL), let iconCG = iconImage.cgImage(
        forProposedRect: nil,
        context: nil,
        hints: nil
    ) {
        let iconLayer = CALayer()
        iconLayer.frame = CGRect(x: 330, y: 820, width: 420, height: 420)
        iconLayer.contents = iconCG
        iconLayer.contentsGravity = .resizeAspectFill
        iconLayer.cornerRadius = 88
        iconLayer.masksToBounds = true
        iconLayer.borderWidth = 5
        iconLayer.borderColor = color(0xFFFFFF, alpha: 0.75)
        iconLayer.shadowColor = NSColor.black.cgColor
        iconLayer.shadowOpacity = 0.35
        iconLayer.shadowRadius = 26
        iconLayer.shadowOffset = CGSize(width: 0, height: -10)
        intro.addSublayer(iconLayer)
    }

    intro.addSublayer(
        makeTextLayer(
            text: "ÖĞREN • YARIŞ • EĞLEN",
            frame: CGRect(x: 70, y: 685, width: 940, height: 90),
            fontSize: 54
        )
    )
    intro.addSublayer(
        makeTextLayer(
            text: "MiniBilge ile bilgi eğlenceye dönüşür!",
            frame: CGRect(x: 110, y: 610, width: 860, height: 60),
            fontSize: 30,
            color: color(0xEEE9FF),
            fontName: "AvenirNext-DemiBold"
        )
    )
    addVisibilityAnimation(
        to: intro,
        start: 0,
        duration: 1.45,
        fade: 0.18,
        fadeIn: false
    )
    parentLayer.addSublayer(intro)

    parentLayer.addSublayer(
        makePill(
            title: "HER YAŞA UYGUN EĞLENCE",
            subtitle: "Matematik • İngilizce • Eğlence",
            start: 1.35,
            duration: 1.55
        )
    )
    parentLayer.addSublayer(
        makePill(
            title: "EĞLENCE QUIZLERİNİ KEŞFET",
            start: 3.05,
            duration: 2.8
        )
    )
    parentLayer.addSublayer(
        makePill(
            title: "BİLGİNİ TEST ET",
            subtitle: "Cevapla, öğren ve ilerle",
            start: 6.1,
            duration: 4.8
        )
    )
    parentLayer.addSublayer(
        makePill(
            title: "ARKADAŞLARINA MEYDAN OKU",
            start: 11.45,
            duration: 4.5
        )
    )

    let endCardStart = totalDuration - 2.75
    let endCard = CALayer()
    endCard.frame = parentLayer.bounds
    endCard.backgroundColor = color(0x4B2FC9, alpha: 0.97)

    if let iconImage = NSImage(contentsOf: iconURL), let iconCG = iconImage.cgImage(
        forProposedRect: nil,
        context: nil,
        hints: nil
    ) {
        let endIcon = CALayer()
        endIcon.frame = CGRect(x: 340, y: 980, width: 400, height: 400)
        endIcon.contents = iconCG
        endIcon.contentsGravity = .resizeAspectFill
        endIcon.cornerRadius = 82
        endIcon.masksToBounds = true
        endIcon.borderWidth = 5
        endIcon.borderColor = color(0xFFFFFF, alpha: 0.8)
        endCard.addSublayer(endIcon)
    }

    endCard.addSublayer(
        makeTextLayer(
            text: "MİNİBİLGE",
            frame: CGRect(x: 90, y: 820, width: 900, height: 110),
            fontSize: 78
        )
    )
    endCard.addSublayer(
        makeTextLayer(
            text: "Öğren, yarış, eğlen!",
            frame: CGRect(x: 120, y: 745, width: 840, height: 70),
            fontSize: 37,
            color: color(0xF0EBFF),
            fontName: "AvenirNext-DemiBold"
        )
    )

    let button = CALayer()
    button.frame = CGRect(x: 170, y: 545, width: 740, height: 132)
    button.backgroundColor = color(0xFFFFFF)
    button.cornerRadius = 42
    button.shadowColor = NSColor.black.cgColor
    button.shadowOpacity = 0.3
    button.shadowRadius = 18
    button.shadowOffset = CGSize(width: 0, height: -8)
    button.addSublayer(
        makeTextLayer(
            text: "ŞİMDİ APP STORE'DA",
            frame: CGRect(x: 25, y: 34, width: 690, height: 68),
            fontSize: 42,
            color: color(0x34216E)
        )
    )
    endCard.addSublayer(button)
    endCard.addSublayer(
        makeTextLayer(
            text: "App Store'da “MiniBilge” diye ara",
            frame: CGRect(x: 100, y: 455, width: 880, height: 60),
            fontSize: 29,
            color: color(0xDFD7FF),
            fontName: "AvenirNext-DemiBold"
        )
    )

    addVisibilityAnimation(
        to: endCard,
        start: endCardStart,
        duration: totalDuration - endCardStart,
        fade: 0.25,
        fadeOut: false
    )
    parentLayer.addSublayer(endCard)

    videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
        postProcessingAsVideoLayer: videoLayer,
        in: parentLayer
    )

    guard let exporter = AVAssetExportSession(
        asset: composition,
        presetName: AVAssetExportPresetHighestQuality
    ) else {
        throw NSError(domain: "MiniBilgeAd", code: 4)
    }
    exporter.outputURL = outputURL
    exporter.outputFileType = .mp4
    exporter.videoComposition = videoComposition
    exporter.shouldOptimizeForNetworkUse = true
    await exporter.export()

    if exporter.status != .completed {
        throw exporter.error ?? NSError(
            domain: "MiniBilgeAd",
            code: 5,
            userInfo: [NSLocalizedDescriptionKey: "Video dışa aktarılamadı"]
        )
    }
    print("OUTPUT=\(outputURL.path)")
    print("DURATION=\(totalDuration)")
}

let semaphore = DispatchSemaphore(value: 0)
Task {
    do {
        try await run()
    } catch {
        fputs("ERROR: \(error)\n", stderr)
        exit(1)
    }
    semaphore.signal()
}
semaphore.wait()
