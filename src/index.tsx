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

/*
 * FasterImageView Props
 * @style: ViewStyle
 * @url: string
 * @base64Placeholder: string
 * @blurhash: string
 * @resizeMode: 'cover' | 'contain' | 'center' | 'fill'
 * @showActivityIndicator: boolean
 * @onError: (result: { nativeEvent: { error: string } }) => void
 * @onSuccess: (result: {
 *  nativeEvent: {
 *   width: number;
 *  height: number;
 * isCached: boolean;
 * cacheKey: string;
 * source: string;
 * };
 * }) => void
 * */
export type FasterImageProps = {
  style: ViewStyle;
  url: string;
  base64Placeholder?: string;
  blurhash?: string;
  resizeMode?: 'cover' | 'contain' | 'center' | 'fill';
  showActivityIndicator?: boolean;
  onError?: (result: { nativeEvent: { error: string } }) => void;
  onSuccess?: (result: {
    nativeEvent: {
      width: number;
      height: number;
      isCached: boolean;
      cacheKey: string;
      source: string;
    };
  }) => void;
};

const ComponentName = 'FasterImageView';

/**
 * FasterImageView is a React Native component that renders an UIImageView on iOS.
 * * Android is not supported.
 * * Image types supported: PNG, JPEG, and GIF.
 * * Supports blurhash, base64 placeholders, and caching.
 * * Backed by Kingfisher, a powerful, pure-Swift library for downloading and caching images from the web.
 * * Check out the docs for more info: https://github.com/onevcat/Kingfisher
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
