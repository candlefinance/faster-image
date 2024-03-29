import UIKit

/// Resize mode for the image.
/// - fill: Scale the image to fill the view.
/// - contain: Scale the image to fit the view.
/// - cover: Scale the image to fill the view, cropping if necessary.
/// - center: Center the image in the view.
enum ResizeMode: String {
    case fill, contain, cover, center, top, bottom, left, right, topLeft, topRight, bottomLeft, bottomRight
    
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
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .left:
            return .left
        case .right:
            return .right
        case .topLeft:
            return .topLeft
        case .topRight:
            return .topRight
        case .bottomLeft:
            return .bottomLeft
        case .bottomRight:
            return .bottomRight
        }
    }
}
