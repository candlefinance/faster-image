import Kingfisher

@objc(FasterImageViewManager)
final class FasterImageViewManager: RCTViewManager {

  override func view() -> (FasterImageView) {
    return FasterImageView()
  }

  @objc override static func requiresMainQueueSetup() -> Bool {
    return false
  }
}

final class FasterImageView: UIImageView {
    
  enum ResizeMode: String {
    case fill = "fill"
    case contain = "contain"
    case cover = "cover"
    case center = "center"

    var contentMode: UIView.ContentMode {
      switch self {
      case .fill:
        return .scaleToFill
      case .contain:
        return .scaleAspectFit
      case .cover:
        return .scaleAspectFill
      case .center:
        return .center
      }
    }
  }

  @objc var onError: RCTDirectEventBlock?
  @objc var onSuccess: RCTDirectEventBlock?
  @objc var base64Placeholder: String?
  @objc var blurhash: String?
  @objc var thumbhash: String?

  @objc var showActivityIndicator: Bool = false {
    didSet {
      kf.indicatorType = showActivityIndicator ? .activity : .none
    }
  }

  @objc var resizeMode: String = "cover" {
    didSet {
      contentMode = ResizeMode(rawValue: resizeMode)?.contentMode ?? .scaleAspectFit
    }
  }

  @objc var url: String? = nil {
    didSet {
      if let url = url {
        kf.setImage(
          with: URL(string: url),
          placeholder:
            UIImage(base64Placeholder: base64Placeholder) ??
            UIImage(
                blurHash: blurhash,
                size: .init(width: 32, height: 32)
            ),
          options: [
            .transition(.fade(1)),
            .scaleFactor(UIScreen.main.scale),
          ]
        ) { [weak self] result in
            self?.completionHandler(with: result)
        }
      } else {
        onError?([
          "error": "Expected a valid url but got: \(url ?? "nil")",
        ])
      }
    }
  }

}

// MARK: - Extensions

fileprivate extension FasterImageView {
    
    func completionHandler(with result: Result<RetrieveImageResult, KingfisherError>) {
        switch result {
        case .success(let value):
            onSuccess?([
                "width": value.image.size.width,
                "height": value.image.size.height,
                "isCached": value.cacheType.cached,
                "cacheKey": value.source.cacheKey,
                "source": value.source.url?.absoluteURL ?? "nil",
            ])
        case .failure(let error):
            onError?([
                "error": error.localizedDescription,
            ])
        }
    }
    
}
