import {
  requireNativeComponent,
  UIManager,
  Platform,
  ViewStyle,
} from 'react-native';

const LINKING_ERROR =
  `The package '@candlefinance/faster-image' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

/**
 * FasterImageProps
 * @typedef FasterImageProps
 * @property {ViewStyle} style - Style of the image
 * @property {string} url - URL of the image **required**
 * @property {string} [base64Placeholder] - Base64 encoded placeholder image
 * @property {string} [blurhash] - Blurhash of the image (base64 encoded)
 * @property {string} [thumbhash] - Thumbhash of the image (base64 encoded)
 * @property {('cover' | 'contain' | 'center' | 'fill')} [resizeMode] - Resize mode of the image
 * @property {boolean} [showActivityIndicator] - Show activity indicator while loading, overrides placeholder. Defaults to false
 * @property {number} [transitionDuration] - Duration of the transition animation in seconds, defaults to 0.75
 * @property {number} [borderRadius] - Border radius of the image
 * @property {string} [failureImage] - Image to show when the image fails to load, pass blurhash, thumbhash or base64 encoded image
 * @property {boolean} [progressiveLoadingEnabled] - Enable progressive loading, defaults to false
 * @property {('memory' | 'discWithCacheControl' | 'discNoCacheControl')} [cachePolicy] - Cache [policy](https://kean-docs.github.io/nuke/documentation/nuke/imagepipeline), defaults to 'memory'. 'discWithCacheControl' will cache the image in the disc and use the cache control headers to determine if the image should be re-fetched. 'discNoCacheControl' will cache the image in the disc and never re-fetch it.
 * @property {(result: { nativeEvent: { error: string } }) => void} [onError] - Callback for when an error occurs
 * @property {(result: { nativeEvent: { width: number; height: number; source: string; } }) => void} [onSuccess] - Callback for when the image loads successfully
 * */
export type FasterImageProps = {
  style: ViewStyle;
  base64Placeholder?: string;
  blurhash?: string;
  thumbhash?: string;
  resizeMode?: 'cover' | 'contain' | 'center' | 'fill';
  showActivityIndicator?: boolean;
  transitionDuration?: number;
  cachePolicy?: 'memory' | 'discWithCacheControl' | 'discNoCacheControl';
  rounded?: boolean;
  failureImage?: string;
  progressiveLoadingEnabled?: boolean;
  url: string;
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
 *    url="https://cataas.com/cat?width=200&height=200"
 *    onSuccess={(event) => console.warn(event.nativeEvent.cacheKey)}
 *    onError={(event) => console.warn(event.nativeEvent.error)}
 *    style={{ width: 200, height: 200 }}}
 *    blurhash="URCP@fof00WBWBa|ofj[00WB~qt7xufQRjay"
 * />
 * */
export const FasterImageView =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<FasterImageProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };
