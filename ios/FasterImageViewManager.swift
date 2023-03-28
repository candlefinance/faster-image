import Nuke
import NukeUI

@objc(FasterImageViewManager)
final class FasterImageViewManager: RCTViewManager {
    
    override func view() -> (FasterImageView) {
        return FasterImageView()
    }
    
    @objc override static func requiresMainQueueSetup() -> Bool {
        return false
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
        lazyImageView.priority = .normal
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
    
    @objc var showActivityIndicator = false {
        didSet {
            lazyImageView.placeholderView = UIActivityIndicatorView()
        }
    }
    
    @objc var resizeMode = "contain" {
        didSet {
            lazyImageView.contentMode = ResizeMode(rawValue: resizeMode)?.contentMode ?? .scaleAspectFit
        }
    }
    
    @objc var transitionDuration: NSNumber = 0.5 {
        didSet {
            lazyImageView.transition = .fadeIn(duration: transitionDuration.doubleValue)
        }
    }
    
    @objc var progressiveLoadingEnabled = false {
        didSet {
            lazyImageView.isProgressiveImageRenderingEnabled = progressiveLoadingEnabled
        }
    }
    
    @objc var cachePolicy = "memory" {
        didSet {
            lazyImageView.pipeline = CachePolicy(rawValue: cachePolicy)?.pipeline ?? .shared
        }
    }
    
    @objc var rounded: Bool = false {
        didSet {
            guard rounded else {
                return
            }
            lazyImageView.processors = [
                ImageProcessors.Circle()
            ]
        }
    }
    
    // MARK: - Optional Properties
    
    @objc var base64Placeholder: String? {
        didSet {
            guard let base64Placeholder else {
                return
            }
            DispatchQueue.global(qos: .userInteractive).async {
                guard var image = UIImage(base64Placeholder: base64Placeholder) else {
                    return
                }
                if self.rounded {
                    let processor = ImageProcessors.Circle()
                    if let newImage = processor.process(image) {
                        image = newImage
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    self?.lazyImageView.placeholderImage = image
                }
            }
        }
    }
    
    @objc var blurhash: String? {
        didSet {
            guard let blurhash else {
                return
            }
            DispatchQueue.global(qos: .userInteractive).async {
                guard var image = UIImage(
                    blurHash: blurhash,
                    size: .init(width: 32, height: 32)
                ) else {
                    return
                }
                if self.rounded {
                    let processor = ImageProcessors.Circle()
                    if let newImage = processor.process(image) {
                        image = newImage
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    self?.lazyImageView.placeholderImage = image
                }
            }
        }
    }
    
    @objc var failureImage: String? {
        didSet {
            guard let failureImage else {
                return
            }
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self else { return }
                guard
                    var image =
                        UIImage(blurHash: failureImage, size: .init(width: 32, height: 32))
                        ?? UIImage(base64Placeholder: failureImage)
                        ?? UIImage(base64Hash: failureImage) else {
                    return
                }
                if self.rounded {
                    let processor = ImageProcessors.Circle()
                    if let newImage = processor.process(image) {
                        image = newImage
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    self?.lazyImageView.failureImage = image
                }
            }
        }
    }
    
    @objc var thumbhash: String? {
        didSet {
            guard let thumbhash else {
                return
            }
            DispatchQueue.global(qos: .userInteractive).async {
                guard var image = UIImage(base64Hash: thumbhash) else {
                    return
                }
                if self.rounded {
                    let processor = ImageProcessors.Circle()
                    if let newImage = processor.process(image) {
                        image = newImage
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    self?.lazyImageView.placeholderImage = image
                }
            }
        }
    }
    
    @objc var url: String? = nil {
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
