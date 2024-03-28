@objc(FasterImageViewManager)
final class FasterImageViewManager: RCTViewManager {

    override func view() -> (FasterImageView) {
        return FasterImageView()
    }

    @objc override static func requiresMainQueueSetup() -> Bool {
        return true
    }
}

struct ImageOptions: Decodable {
    let blurhash: String?
    let thumbhash: String?
    let resizeMode: String?
    let showActivityIndicator: Bool?
    let transitionDuration: Double?
    let cachePolicy: String?
    let failureImage: String?
    let base64Placeholder: String?
    let progressiveLoadingEnabled: Bool?
    let borderRadius: Double?
    let url: String
    let grayscale: Double?
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
                if let borderRadius = options.borderRadius {
                    lazyImageView.layer.cornerRadius = CGFloat(borderRadius)
                    lazyImageView.layer.masksToBounds = true
                    self.clipsToBounds = true
                }
                if let blurhash = options.blurhash {
                    self.blurhash = blurhash
                }
                if let thumbhash = options.thumbhash {
                    self.thumbhash = thumbhash
                }
                resizeMode = options.resizeMode ?? "contain"
                if let showActivityIndicator = options.showActivityIndicator {
                    self.showActivityIndicator = showActivityIndicator
                }
                transitionDuration = NSNumber(value: options.transitionDuration ?? 0.5)
                cachePolicy = options.cachePolicy ?? "memory"
                if let failureImage = options.failureImage {
                    self.failureImage = failureImage
                }
                progressiveLoadingEnabled = options.progressiveLoadingEnabled ?? false
                url = options.url

                grayscale = options.grayscale ?? 0.0
            } catch {
                onError?([
                    "error": error.localizedDescription,
                ])
            }
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
            lazyImageView.placeholderView = UIActivityIndicatorView()
        }
    }

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

    var url: String? = nil {
        didSet {
            guard let url else {
                onError?([
                    "error": "Expected a valid url but got: \(url ?? "nil")",
                ])
                return
            }
            lazyImageView.url = URL(string: url)
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
