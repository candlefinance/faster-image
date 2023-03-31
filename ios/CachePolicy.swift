/// How aggressively the cache should be used.
enum CachePolicy: String {
    case memory, discWithCacheControl, discNoCacheControl
    
    var pipeline: ImagePipeline {
        switch self {
        case .memory:
            return .shared
        case .discWithCacheControl:
            return ImagePipeline(configuration: .withURLCache)
        case .discNoCacheControl:
            return ImagePipeline(configuration: .withDataCache)
        }
    }
}
