import {
  ColorValue,
  ImageStyle,
  NativeModules,
  Platform,
  requireNativeComponent,
} from 'react-native';

export type IOSImageResizeMode =
  | 'fill'
  | 'contain'
  | 'cover'
  | 'center'
  | 'top'
  | 'bottom'
  | 'left'
  | 'right'
  | 'topLeft'
  | 'topRight'
  | 'bottomLeft'
  | 'bottomRight';

export type AndroidImageResizeMode =
  | 'fill'
  | 'contain'
  | 'cover'
  | 'center'
  | 'top'
  | 'bottom';

/*
 * @property {string} url - URL of the image **required**
 * @property {string} [base64Placeholder] - Base64 encoded placeholder image
 * @property {string} [blurhash] - Blurhash of the image (base64 encoded)
 * @property {string} [thumbhash] - Thumbhash of the image (base64 encoded) (iOS only)
 * @property {('cover' | 'contain' | 'center' | 'fill')} [resizeMode] - Resize mode of the image
 * @property {boolean} [showActivityIndicator] - Show activity indicator while loading, overrides placeholder. Defaults to false (iOS only)
 * @property {ColorValue} [activityColor] - Activity indicator color. Changed default activity indicator color if specified. Defaults to undefined (iOS only)
 * @property {number} [transitionDuration] - Duration of the transition animation in seconds, defaults to 0.75
 * @property {string} [failureImage] - Image to show when the image fails to load, pass blurhash, thumbhash or base64 encoded image
 * @property {boolean} [progressiveLoadingEnabled] - Enable progressive loading, defaults to false
 * @property {('memory' | 'discWithCacheControl' | 'discNoCacheControl')} [cachePolicy] - Cache [policy](https://kean-docs.github.io/nuke/documentation/nuke/imagepipeline), defaults to 'memory'. 'discWithCacheControl' will cache the image in the disc and use the cache control headers to determine if the image should be re-fetched. 'discNoCacheControl' will cache the image in the disc and never re-fetch it.
 * @property {number} [borderRadius] - Border radius of the image
 * @property {number} [borderTopLeftRadius] - Top left border radius of the image
 * @property {number} [borderTopRightRadius] - Top right border radius of the image
 * @property {number} [borderBottomLeftRadius] - Bottom left border radius of the image
 * @property {number} [borderBottomRightRadius] - Bottom right border radius of the image
 * @property {number} [grayscale] - Grayscale value of the image, 0-1
 * @property {boolean} [allowHardware] - Allow hardware rendering, defaults to true (Android only)
 */
export type ImageOptions = {
  blurhash?: string;
  accessible?: boolean;
  accessibilityLabel?: string;
  thumbhash?: string;
  resizeMode?: IOSImageResizeMode | AndroidImageResizeMode;
  borderRadius?: number;
  borderTopLeftRadius?: number;
  borderTopRightRadius?: number;
  borderBottomLeftRadius?: number;
  borderBottomRightRadius?: number;
  showActivityIndicator?: boolean;
  activityColor?: ColorValue;
  transitionDuration?: number;
  cachePolicy?: 'memory' | 'discWithCacheControl' | 'discNoCacheControl';
  failureImage?: string;
  progressiveLoadingEnabled?: boolean;
  base64Placeholder?: string;
  url: string;
  headers?: Record<string, string>;
  grayscale?: number;
  allowHardware?: boolean;
};

/**
 * FasterImageProps
 * @typedef FasterImageProps
 * @property {ViewStyle} style - Style of the image
 * @property {ImageOptions} source - Image source
 * @property {(result: { nativeEvent: { error: string } }) => void} [onError] - Callback for when an error occurs
 * @property {(result: { nativeEvent: { width: number; height: number; source: string; } }) => void} [onSuccess] - Callback for when the image loads successfully
 * */
export type FasterImageProps = {
  style: ImageStyle | ImageStyle[];
  source: ImageOptions;
  onError?: (result: { nativeEvent: { error: string } }) => void;
  onSuccess?: (result: {
    nativeEvent: {
      width: number;
      height: number;
      source: string;
    };
  }) => void;
};

const ComponentName = 'FasterImageView';

/**
 * FasterImageView is a React Native component that renders an Image on iOS.
 * * Image types supported: PNG & JPEG.
 * * Supports blurhash, base64 placeholders, and caching.
 * * Backed by [Nuke](https://github.com/kean/Nuke.git), a small, performant image loading library written in Swift.
 * @param props: FasterImageProps
 * @returns FasterImageView
 * @example
 * import { FasterImageView } from '@candlefinance/faster-image';
 *
 * <FasterImageView
 *    onSuccess={(event) => console.warn(event.nativeEvent.cacheKey)}
 *    onError={(event) => console.warn(event.nativeEvent.error)}
 *    style={{ width: 200, height: 200 }}}
 *  source={{
 *   transitionDuration: 0.3,
 *   cachePolicy: 'discWithCacheControl',
 *   showActivityIndicator: true,
 *   failureImage: 'k0oGLQaSVsJ0BVhn2oq2Z5SQUQcZ',
 *   url: 'https://picsum.photos/200/200?random=1',
 * }}
 * />
 * */
export const FasterImageView =
  requireNativeComponent<FasterImageProps>(ComponentName);

export const clearCache = async () => {
  if (Platform.OS === 'ios') {
    const { FasterImageViewManager } = NativeModules;
    return FasterImageViewManager.clearCache();
  } else {
    const { FasterImageModule } = NativeModules;
    return FasterImageModule.clearCache();
  }
};

export const prefetch(sources: string[]): Promise<void> {
  if (Platform.OS === 'ios') {
    const { FasterImageViewManager } = NativeModules;
    return FasterImageViewManager.prefetch(sources);
  } else {
    const { FasterImageModule } = NativeModules;
    return FasterImageModule.prefetch(sources);
  }
}