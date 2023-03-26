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
    
    @objc var showActivityIndicator = false
    @objc var resizeMode = "contain"
    @objc var transitionDuration = 0.75
    @objc var cachePolicy = "memory"

    // MARK: - Optional Properties

    @objc var base64Placeholder: String?
    @objc var blurhash: String?
    @objc var thumbhash: String?

    // MARK: - Setters

    @objc var url: String? = nil {
        didSet {
            guard let url = url else {
                onError?([
                    "error": "Expected a valid url but got: \(url ?? "nil")",
                ])
                return
            }
            if let placeholder =
                UIImage(base64Placeholder: base64Placeholder) ??
                UIImage(
                    blurHash: blurhash,
                    size: .init(width: 32, height: 32)
                ) ??
                UIImage(base64Hash: thumbhash) {
                lazyImageView.placeholderImage = placeholder
                lazyImageView.failureImage = placeholder
            }
            
            if showActivityIndicator {
                lazyImageView.placeholderView = UIActivityIndicatorView()
            }
            
            lazyImageView.contentMode = ResizeMode(rawValue: resizeMode)?.contentMode ?? .scaleAspectFit
            lazyImageView.priority = .normal
            lazyImageView.transition = .fadeIn(duration: transitionDuration)
            
            lazyImageView.onCompletion = { [weak self] result in
                self?.completionHandler(with: result)
            }

            lazyImageView.pipeline = CachePolicy(rawValue: cachePolicy)?.pipeline ?? .shared

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
