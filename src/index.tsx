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

type FasterImageProps = {
  color: string;
  style: ViewStyle;
};

const ComponentName = 'FasterImageView';

export const FasterImageView =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<FasterImageProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };
