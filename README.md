<br/>
<div align="center">
 <a href="https://www.npmjs.com/package/@candlefinance%2Ffaster-image">
  <img src="https://img.shields.io/npm/dm/@candlefinance%2Ffaster-image" alt="npm downloads" />
</a>
  <a alt="discord users online" href="https://discord.gg/qnAgjxhg6n"
  target="_blank"
  rel="noopener noreferrer">
    <img alt="discord users online" src="https://img.shields.io/discord/986610142768406548?label=Discord&logo=discord&logoColor=white&cacheSeconds=3600"/>
  </a>
</div>

<br/>

https://github.com/candlefinance/faster-image/assets/12258850/ede91008-4dca-417c-a2ca-4d2177066316

A performant way to render images in React Native with a focus on speed and memory usage. Powered by [Nuke](https://github.com/kean/nuke), the smallest and most performant image loading library for iOS and macOS and [Coil](https://github.com/coil-kt/coil) on Android.

> The framework is lean and compiles in under 2 seconds¹. Nuke has an automated test suite 2x the size of the codebase itself, ensuring excellent reliability. Every feature is carefully designed and optimized for performance.

> Coil performs a number of optimizations including memory and disk caching, downsampling the image in memory, automatically pausing/cancelling requests, and more.

## Features

- [x] Supports visionOS
- [x] Fast image loading
- [x] Memory and disk caching
- [x] Placeholder support:
  - [x] [blurhash](https://github.com/woltapp/blurhash) (iOS only)
  - [x] [thumbhash](https://github.com/evanw/thumbhash) (iOS only)
  - [x] Base64 encoded image
- [x] Animated transition
- [x] Failure image
- [x] Typescript support
- [x] Written in Swift/Kotlin

## To be added

- [ ] GIF support


## Installation

```sh
yarn add @candlefinance/faster-image
```

## Usage

```js
import { FasterImageView, clearCache } from '@candlefinance/faster-image';

<FasterImageView
  style={styles.image}
  onSuccess={(event) => {
    console.log(event.nativeEvent);
  }}
  onError={(event) => console.warn(event.nativeEvent.error)}
  source={{
    transitionDuration: 0.3,
    borderRadius: 50,
    cachePolicy: 'discWithCacheControl',
    showActivityIndicator: true,
    url: 'https://picsum.photos/200/200?random=1',
  }}
/>;

// Clear memory and disk cache
await clearCache();
```

## Props

| Prop                      | Type                   | Default                  | Description                                                                                          |
| ------------------------- | ---------------------- | ------------------------ | ---------------------------------------------------------------------------------------------------- |
| url                       | string                 |                          | The URL of the image                                                                                 |
| style                     | object                 |                          | The style of the image                                                                               |
| resizeMode                | string                 | contain                  | The resize mode of the image                                                                         |
| thumbhash                 | string                 |                          | The thumbhash of the image as a base64 encoded string to show while loading (Android not tested)     |
| blurhash                  | string                 |                          | The blurhash of the image to show while loading (iOS only)                                           |
| showActivityIndicator     | boolean                | false (iOS only)         | Whether to show the UIActivityIndicatorView indicator when the image is loading   
| activityColor             | ColorValue             | undefined (iOS only)     | Activity indicator color. Changed default activity indicator color. Only hex supported     |
| base64Placeholder         | string                 |                          | The base64 encoded placeholder image to show while the image is loading                              |
| cachePolicy               | string                 | memory                   | The cache policy of the image                                                                        |
| transitionDuration        | number                 | 0.75 (iOS) Android (100) | The transition duration of the image                                                                 |
| borderRadius              | number                 | 0                        | border radius of image                                                                               |
| borderTopLeftRadius       | number                 | 0                        | top left border radius of image                                                                      |
| borderTopRightRadius      | number                 | 0                        | top right border radius of image                                                                     |
| borderBottomLeftRadius    | number                 | 0                        | bottom left border radius of image                                                                   |
| borderBottomRightRadius   | number                 | 0                        | bottom right border radius of image                                                                  |
| failureImage              | string                 |                          | If the image fails to download this will be set (blurhash, thumbhash, base64)                        |
| progressiveLoadingEnabled | boolean                | false                    | Progressively load images (iOS only)                                                                 |
| onError                   | function               |                          | The function to call when an error occurs. The error is passed as the first argument of the function |
| onSuccess                 | function               |                          | The function to call when the image is successfully loaded                                           |
| grayscale                 | number                 | 0                        | Filter or transformation that converts the image into shades of gray (0-1).                          |
| allowHardware             | boolean                | true                     | Allow hardware rendering (Android only)                                                              |
| headers                   | Record<string, string> | undefined                | Pass in headers                                                                                      |
| accessibilityLabel        | string                 | undefined                | accessibility label                                                                                  |
| accessible                | boolean                | undefined                | is accessible                                                                                        |

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
