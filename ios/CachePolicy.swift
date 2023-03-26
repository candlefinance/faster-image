import Nuke

/// How aggressively the cache should be used.
enum CachePolicy: String {
    case memory, discWithCacheContol, discNoCacheControl
    
    var pipeline: ImagePipeline {
        switch self {
        case .memory:
            return .shared
        case .discWithCacheContol:
            return ImagePipeline(configuration: .withURLCache)
        case .discNoCacheControl:
            return ImagePipeline(configuration: .withDataCache)
        }
    }
}
