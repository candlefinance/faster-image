/// How aggressively the cache should be used.
enum CachePolicy: String {
    case memory, discWithCacheControl, discNoCacheControl, memoryAndDisc
    
    var pipeline: ImagePipeline {
        switch self {
        case .memory:
            return .shared
        case .discWithCacheControl, .memoryAndDisc:
          // A configuration with an HTTP disk cache (URLCache) with a size limit of 150 MB. This is a default configuration. Also uses shared for in-memory caching.
            return ImagePipeline(configuration: .withURLCache)
        case .discNoCacheControl:
          // A configuration with an aggressive disk cache (DataCache) with a size limit of 150 MB. An HTTP cache (URLCache) is disabled.
            return ImagePipeline(configuration: .withDataCache)
        }
    }
}
