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
            DispatchQueue.main.async {
                resolve(true)
            }
        }
    }

  @objc
  func prefetch(_ sources: [String],
                resolve: @escaping RCTPromiseResolveBlock,
                reject: @escaping RCTPromiseRejectBlock) {
                do {
    let prefetcher = ImagePrefetcher()
    let urls = sources.map { url in URL(string: url )}.compactMap{ $0 }
    prefetcher.startPrefetching(with: urls)
    resolve(true)
    } catch { reject() }
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

/// A wrapper around `LazyImageView` to make it compatible with React Native.
final class FasterImageView: UIView {

    // MARK: - Initializers

    init() {
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
        lazyImageView.priority = .high
        lazyImageView.onCompletion = { [weak self] result in
            self?.completionHandler(with: result)
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

                if let url = URL(string: options.url) {
                    var urlRequestFromOptions = URLRequest(url: url)
                    urlRequestFromOptions.allHTTPHeaderFields = options.headers
                    
                    urlRequest = urlRequestFromOptions
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
            lazyImageView.request = ImageRequest(urlRequest: urlRequest!)
        }
    }

}

// MARK: - Extensions

fileprivate extension FasterImageView {

    func completionHandler(with result: Result<ImageResponse, Error>) {
        switch result {
        case .success(let value):
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
