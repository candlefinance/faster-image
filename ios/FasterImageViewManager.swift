@objc(FasterImageViewManager)
final class FasterImageViewManager: RCTViewManager {
  
  override func view() -> (FasterImageView) {
    return FasterImageView()
  }
  
  @objc override static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  @objc(clearCache:rejecter:)
  func clearCache(_ resolve: @escaping RCTPromiseResolveBlock,
                  reject: RCTPromiseRejectBlock) {
    DispatchQueue.global(qos: .userInteractive).async {
      ImagePipeline.shared.cache.removeAll()
      ImageCache.shared.removeAll()
      DataLoader.sharedUrlCache.removeAllCachedResponses()
      URLSession.shared.invalidateAndCancel()
      DispatchQueue.main.async {
        resolve(true)
      }
    }
  }
  
  @objc(prefetch:withResolver:withRejecter:)
  func prefetch(sources: [String],
                resolve: @escaping RCTPromiseResolveBlock,
                reject: @escaping RCTPromiseRejectBlock) {
    let prefetcher = ImagePrefetcher()
    prefetcher.startPrefetching(with: sources.compactMap(URL.init(string:)))
    resolve(true)
  }
}

struct ContentPosition: Decodable {
    var top: String?
    var bottom: String?
    var right: String?
    var left: String?
    
    static let center = Self()
    
    func offsetX(contentWidth: CGFloat, containerWidth: CGFloat) -> CGFloat {
      let diff = containerWidth - contentWidth
      
      if let leftDistance = distance(from: left) {
        return -diff / 2 + leftDistance
      }
      
      if let rightDistance = distance(from: right) {
        return diff / 2 - rightDistance
      }
      
      if let factor = factor(from: left) {
        return -diff / 2 + diff * factor
      }
      
      if let factor = factor(from: right) {
        return diff / 2 - diff * factor
      }

      return 0
    }
    
    func offsetY(contentHeight: CGFloat, containerHeight: CGFloat) -> CGFloat {
        let diff = containerHeight - contentHeight
        
        if let topDistance = distance(from: top) {
          return -diff / 2 + topDistance
        }

        if let bottomDistance = distance(from: bottom) {
          return diff / 2 - bottomDistance
        }
        
        if let factor = factor(from: top) {
          return -diff / 2 + diff * factor
        }
        
        if let factor = factor(from: bottom) {
          return diff / 2 - diff * factor
        }

        return 0
    }
    
    func offset(contentSize: CGSize, containerSize: CGSize) -> CGPoint {
      return CGPoint(
        x: offsetX(contentWidth: contentSize.width, containerWidth: containerSize.width),
        y: offsetY(contentHeight: contentSize.height, containerHeight: containerSize.height)
      )
    }

    private func distance(from value: String?) -> CGFloat? {
      guard let value = value else { return nil }
      return CGFloat(Double(value) ?? 0)
    }

    private func factor(from value: String?) -> CGFloat? {
      guard let value = value else { return nil }
      if value == "center" {
          return 0.5
      }
      guard value.contains("%"), let percentage = Double(value.replacingOccurrences(of: "%", with: "")) else {
          return nil
      }
      return CGFloat(percentage / 100)
    }
}

struct ImageOptions: Decodable {
  let blurhash: String?
  let thumbhash: String?
  let resizeMode: String?
  let showActivityIndicator: Bool?
  let activityColor: String?
  let transitionDuration: Double?
  let cachePolicy: String?
  let contentPosition: String?
  let failureImage: String?
  let base64Placeholder: String?
  let progressiveLoadingEnabled: Bool?
  let borderRadius: Double?
  let borderTopLeftRadius: Double?
  let borderTopRightRadius: Double?
  let borderBottomLeftRadius: Double?
  let borderBottomRightRadius: Double?
  let url: String
  let headers: [String: String]?
  let grayscale: Double?
  let colorMatrix: [[Double]]?
  let ignoreQueryParamsForCacheKey: Bool?
  let priority: String?
}

struct BorderRadii {
  var uniform: Double = 0.0
  var topLeft: Double = 0.0
  var topRight: Double = 0.0
  var bottomLeft: Double = 0.0
  var bottomRight: Double = 0.0
  
  func sum() -> Double {
    return uniform + topLeft + topRight + bottomLeft + bottomRight
  }
}

extension ImageRequest.Priority {
  init(_ value: String? = "normal") {
    switch value {
    case "normal":
      self = .normal
    case "veryLow":
      self = .veryLow
    case "low":
      self = .low
    case "high":
      self = .high
    case "veryHigh":
      self = .veryHigh
    default:
      self = .normal
    }
  }
}

/// A wrapper around `LazyImageView` to make it compatible with React Native.
final class FasterImageView: UIView {
  
  // MARK: - Initializers
  
  init() {
    self.priority = .normal
    
    super.init(frame: .zero)
    addSubview(lazyImageView)
    lazyImageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      lazyImageView.topAnchor.constraint(equalTo: topAnchor),
      lazyImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      lazyImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      lazyImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
    lazyImageView.pipeline = .shared
    lazyImageView.onCompletion = { [weak self] result in
      DispatchQueue.main.async {
        self?.completionHandler(with: result)
      }
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Views
  
  private lazy var lazyImageView = LazyImageView()
  
  // MARK: - Callbacks
  
  @objc var onError: RCTDirectEventBlock?
  @objc var onSuccess: RCTDirectEventBlock?
  
  // MARK: - Properties
  @objc var source: NSDictionary? = nil {
    didSet {
      guard let source = source else {
        onError?([
          "error": "Expected a valid source but got: \("nil")",
        ])
        return
      }
      do {
        let options = try DictionaryDecoder().decode(ImageOptions.self, from: source)
        if let base64Placeholder = options.base64Placeholder {
          self.base64Placeholder = base64Placeholder
        }
        
        borderRadii = BorderRadii(
          uniform: options.borderRadius ?? 0.0,
          topLeft: options.borderTopLeftRadius ?? 0.0,
          topRight: options.borderTopRightRadius ?? 0.0,
          bottomLeft: options.borderBottomLeftRadius ?? 0.0,
          bottomRight: options.borderBottomRightRadius ?? 0.0
        )

        if let position = options.contentPosition {
          self.contentPositionString = position
        }
        
        if let priority = options.priority {
          self.priority = ImageRequest.Priority.init(priority)
        }
        
        if let blurhash = options.blurhash {
          self.blurhash = blurhash
        }
        if let thumbhash = options.thumbhash {
          self.thumbhash = thumbhash
        }
        resizeMode = options.resizeMode ?? "contain"
        if let activityColor = options.activityColor {
          self.activityColor = UIColor(hex: activityColor)
        }
        if let showActivityIndicator = options.showActivityIndicator {
          self.showActivityIndicator = showActivityIndicator
        }
        transitionDuration = NSNumber(value: options.transitionDuration ?? 0.5)
        cachePolicy = options.cachePolicy ?? "memory"
        if let failureImage = options.failureImage {
          self.failureImage = failureImage
        }
        progressiveLoadingEnabled = options.progressiveLoadingEnabled ?? false
        grayscale = options.grayscale ?? 0.0
        colorMatrix = options.colorMatrix ?? [[1.0, 0.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 0.0, 1.0, 0.0]]
        ignoreQueryParamsForCacheKey = options.ignoreQueryParamsForCacheKey ?? false
        
        if let url = URL(string: options.url) {
          var urlRequestFromOptions = URLRequest(url: url)
          urlRequestFromOptions.allHTTPHeaderFields = options.headers
          
          urlRequest = urlRequestFromOptions
          
          if ignoreQueryParamsForCacheKey {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.query = nil
            let url = components?.url?.absoluteString ?? url.absoluteString
            lazyImageView.request?.userInfo[.imageIdKey] = url
          }
        } else {
          onError?([
            "error": "Expected a valid url but got: \(options.url)",
          ])
        }
      } catch {
        onError?([
          "error": error.localizedDescription,
        ])
      }
    }
  }
  
  private func applyBorderRadii() {
    let radiiSum = borderRadii.sum()
    
    if radiiSum != 0.0 {
      let nonUniformRadiiiSum = radiiSum - borderRadii.uniform
      
      if nonUniformRadiiiSum == 0.0 || nonUniformRadiiiSum == borderRadii.uniform {
        lazyImageView.layer.cornerRadius = CGFloat(borderRadii.uniform)
      } else {
        let path = UIBezierPath()
        let bounds = lazyImageView.bounds
        
        path.move(to: CGPoint(x: bounds.minX, y: bounds.minY + borderRadii.topLeft))
        path.addArc(withCenter: CGPoint(x: bounds.minX + borderRadii.topLeft, y: bounds.minY + borderRadii.topLeft),
                    radius: borderRadii.topLeft,
                    startAngle: CGFloat.pi,
                    endAngle: 3 * CGFloat.pi / 2,
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: bounds.maxX - borderRadii.topRight, y: bounds.minY))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - borderRadii.topRight, y: bounds.minY + borderRadii.topRight),
                    radius: borderRadii.topRight,
                    startAngle: 3 * CGFloat.pi / 2,
                    endAngle: 0,
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - borderRadii.bottomRight))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - borderRadii.bottomRight, y: bounds.maxY - borderRadii.bottomRight),
                    radius: borderRadii.bottomRight,
                    startAngle: 0,
                    endAngle: CGFloat.pi / 2,
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: bounds.minX + borderRadii.bottomLeft, y: bounds.maxY))
        path.addArc(withCenter: CGPoint(x: bounds.minX + borderRadii.bottomLeft, y: bounds.maxY - borderRadii.bottomLeft),
                    radius: borderRadii.bottomLeft,
                    startAngle: CGFloat.pi / 2,
                    endAngle: CGFloat.pi,
                    clockwise: true)
        
        path.close()
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        lazyImageView.layer.mask = mask
      }
      
      lazyImageView.layer.masksToBounds = true
      self.clipsToBounds = true
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    applyBorderRadii()
    applyContentPosition()
  }

  private var needsContentPositioning = false

  var contentPosition = ContentPosition()

  var contentPositionString: String? {
    didSet {
        guard let positionString = contentPositionString else { return }
        
        switch positionString {
          case "center":
            contentPosition = ContentPosition()
          case "left":
            contentPosition = ContentPosition(right: nil, left: "0")
          case "right":
            contentPosition = ContentPosition(right: "0", left: nil)
          case "top":
            contentPosition = ContentPosition(top: "0", bottom: nil)
          case "bottom":
            contentPosition = ContentPosition(top: nil, bottom: "0")
          case "topLeft":
            contentPosition = ContentPosition(top: "0", bottom: nil, right: nil, left: "0")
          case "topRight":
            contentPosition = ContentPosition(top: "0", bottom: nil, right: "0", left: nil)
          case "bottomLeft":
            contentPosition = ContentPosition(top: nil, bottom: "0", right: nil, left: "0")
          case "bottomRight":
            contentPosition = ContentPosition(top: nil, bottom: "0", right: "0", left: nil)
          default:
            contentPosition = ContentPosition()
        }

        if lazyImageView.imageView.image != nil {
          applyContentPosition()
        } else {
          needsContentPositioning = true
        }
    }
  }

  private func applyContentPosition() {
    guard let imageSize = lazyImageView.imageView.image?.size else { return }
    
    let containerSize = bounds.size
    let contentSize: CGSize
    let imageAspect = imageSize.width / imageSize.height
    let containerAspect = containerSize.width / containerSize.height
    
    if imageAspect > containerAspect {
        contentSize = CGSize(
            width: containerSize.width,
            height: containerSize.width / imageAspect
        )
    } else {
        contentSize = CGSize(
            width: containerSize.height * imageAspect,
            height: containerSize.height
        )
    }
    
    let offset = contentPosition.offset(contentSize: contentSize, containerSize: containerSize)
    lazyImageView.imageView.frame.origin = offset
  }
  
  var borderRadii = BorderRadii() {
    didSet {
      lazyImageView.setNeedsLayout()
      applyBorderRadii()
    }
  }
  
  var grayscale = 0.0 {
    didSet {
      if grayscale > 0 {
        lazyImageView.processors = [
          ImageProcessors.CoreImageFilter(
            name: "CIColorControls",
            parameters: [
              "inputSaturation": 1.0 - grayscale,
            ],
            identifier: "custom.grayscale.\(grayscale)"
          )
        ]
      }
    }
  }
    
  var colorMatrix = [[1.0, 0.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 0.0, 1.0, 0.0]] {
      didSet {
          if !colorMatrix.isEmpty && colorMatrix.count == 4 && colorMatrix.allSatisfy(({ $0.count == 5 })) {
              lazyImageView.processors = [
                  ImageProcessors.CoreImageFilter(
                      name: "CIColorMatrix",
                      parameters: [
                        "inputRVector": CIVector(x: colorMatrix[0][0], y: colorMatrix[0][1], z: colorMatrix[0][2], w: colorMatrix[0][3]),
                        "inputGVector": CIVector(x: colorMatrix[1][0], y: colorMatrix[1][1], z: colorMatrix[1][2], w: colorMatrix[1][3]),
                        "inputBVector": CIVector(x: colorMatrix[2][0], y: colorMatrix[2][1], z: colorMatrix[2][2], w: colorMatrix[2][3]),
                        "inputAVector": CIVector(x: colorMatrix[3][0], y: colorMatrix[3][1], z: colorMatrix[3][2], w: colorMatrix[3][3]),
                        "inputBiasVector": CIVector(x: colorMatrix[0][4], y: colorMatrix[1][4], z: colorMatrix[2][4], w: colorMatrix[3][4]),
                      ],
                      identifier: "custom.colorMatrix"
                  )
              ]
          }
      }
  }
  
  var showActivityIndicator = false {
    didSet {
      let activity = UIActivityIndicatorView()
      if self.activityColor != nil {
        activity.color = self.activityColor
      }
      lazyImageView.placeholderView = activity
    }
  }
  
  var activityColor: UIColor?
  
  var resizeMode = "contain" {
    didSet {
      let mode = ResizeMode(rawValue: resizeMode)
      lazyImageView.imageView.contentMode = mode?.contentMode ?? .scaleAspectFit
    }
  }
  
  var priority: ImageRequest.Priority {
    didSet {
      lazyImageView.priority = priority
    }
  }
  
  var transitionDuration: NSNumber = 0.5 {
    didSet {
      lazyImageView.transition = .fadeIn(duration: transitionDuration.doubleValue)
    }
  }
  
  var progressiveLoadingEnabled = false {
    didSet {
      lazyImageView.isProgressiveImageRenderingEnabled = progressiveLoadingEnabled
    }
  }
  
  var cachePolicy = "memory" {
    didSet {
      lazyImageView.pipeline = CachePolicy(rawValue: cachePolicy)?.pipeline ?? .shared
    }
  }
  
  var ignoreQueryParamsForCacheKey = false
  
  // MARK: - Optional Properties
  
  var base64Placeholder: String? {
    didSet {
      guard let base64Placeholder else {
        return
      }
      DispatchQueue.global(qos: .userInteractive).async { [weak self] in
        guard let self else { return }
        guard let image = UIImage(base64Placeholder: base64Placeholder) else {
          return
        }
        DispatchQueue.main.async { [weak self] in
          self?.lazyImageView.placeholderImage = image
        }
      }
    }
  }
  
  var blurhash: String? {
    didSet {
      guard let blurhash else {
        return
      }
      DispatchQueue.global(qos: .userInteractive).async { [weak self] in
        guard let self else { return }
        guard let image = UIImage(
          blurHash: blurhash,
          size: .init(width: 32, height: 32)
        ) else {
          return
        }
        DispatchQueue.main.async { [weak self] in
          self?.lazyImageView.placeholderImage = image
        }
      }
    }
  }
  
  var failureImage: String? {
    didSet {
      guard let failureImage else {
        return
      }
      DispatchQueue.global(qos: .userInteractive).async { [weak self] in
        guard let self else { return }
        guard
          let image =
            UIImage(blurHash: failureImage, size: .init(width: 32, height: 32))
            ?? UIImage(base64Placeholder: failureImage)
            ?? UIImage(base64Hash: failureImage) else {
          return
        }
        DispatchQueue.main.async { [weak self] in
          self?.lazyImageView.failureImage = image
        }
      }
    }
  }
  
  var thumbhash: String? {
    didSet {
      guard let thumbhash else {
        return
      }
      DispatchQueue.global(qos: .userInteractive).async { [weak self] in
        guard let self else { return }
        guard let image = UIImage(base64Hash: thumbhash) else {
          return
        }
        DispatchQueue.main.async { [weak self] in
          self?.lazyImageView.placeholderImage = image
        }
      }
    }
  }
  
  var urlRequest: URLRequest? = nil {
    didSet {
      lazyImageView.request = ImageRequest(urlRequest: urlRequest!, priority: priority)
    }
  }
  
}

// MARK: - Extensions

fileprivate extension FasterImageView {
  
  func completionHandler(with result: Result<ImageResponse, Error>) {
    switch result {
    case .success(let value):
      if needsContentPositioning {
          applyContentPosition()
      }
      onSuccess?([
        "width": value.image.size.width,
        "height": value.image.size.height,
        "source": value.urlResponse?.url?.absoluteString ?? ""
      ])
    case .failure(let error):
      onError?([
        "error": error.localizedDescription,
      ])
    }
  }
  
}

fileprivate extension UIColor {
  convenience init?(hex: String) {
    if !hex.starts(with: "#") {
      return nil
    }
    
    let input = hex
      .replacingOccurrences(of: "#", with: "")
      .uppercased()
    var alpha: CGFloat = 1.0
    var red: CGFloat = 0
    var blue: CGFloat = 0
    var green: CGFloat = 0
    
    switch (input.count) {
    case 3 /* #RGB */:
      red = Self.colorComponent(from: input, start: 0, length: 1)
      green = Self.colorComponent(from: input, start: 1, length: 1)
      blue = Self.colorComponent(from: input, start: 2, length: 1)
      break
    case 4 /* #ARGB */:
      alpha = Self.colorComponent(from: input, start: 0, length: 1)
      red = Self.colorComponent(from: input, start: 1, length: 1)
      green = Self.colorComponent(from: input, start: 2, length: 1)
      blue = Self.colorComponent(from: input, start: 3, length: 1)
      break
    case 6 /* #RRGGBB */:
      red = Self.colorComponent(from: input, start: 0, length: 2)
      green = Self.colorComponent(from: input, start: 2, length: 2)
      blue = Self.colorComponent(from: input, start: 4, length: 2)
      break
    case 8 /* #AARRGGBB */:
      alpha = Self.colorComponent(from: input, start: 0, length: 2)
      red = Self.colorComponent(from: input, start: 2, length: 2)
      green = Self.colorComponent(from: input, start: 4, length: 2)
      blue = Self.colorComponent(from: input, start: 6, length: 2)
      break
    default:
      return nil
    }
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
  
  static func colorComponent(from: String, start: Int, length: Int) -> CGFloat {
    let substring = (from as NSString)
      .substring(with: NSRange(location: start, length: length))
    let fullHex = length == 2 ? substring : "\(substring)\(substring)"
    var hexComponent: UInt64 = 0
    Scanner(string: fullHex)
      .scanHexInt64(&hexComponent)
    return CGFloat(Double(hexComponent) / 255.0)
  }
}
