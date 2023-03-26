[![npm version](https://badge.fury.io/js/@candlefinance%2Ffaster-image.svg)](https://badge.fury.io/js/@candlefinance%2Ffaster-image)

[![Watch the video](https://user-images.githubusercontent.com/12258850/227793826-c568d6b4-7cee-4c9f-b1ac-1beef3a2b3c5.png)](https://user-images.githubusercontent.com/12258850/227793749-d231199d-6058-4e6a-bb07-51b0ebfe9db5.mp4)

A performant way to render images in React Native (**iOS only**) with a focus on speed and memory usage. Powered by [Nuke](https://github.com/kean/nuke), the smallest and most performant image loading library for iOS and macOS.

> The framework is lean and compiles in under 2 seconds¹. Nuke has an automated test suite 2x the size of the codebase itself, ensuring excellent reliability. Every feature is carefully designed and optimized for performance.

## Features

- [x] Fast image loading
- [x] Memory and disk caching
- [x] Placeholder support: base64, blurhash, thumbhash and UIActivityIndicatorView
- [x] Animated transition
- [x] Typescript support
- [x] Written in Swift

## Installation

```sh
yarn add @candlefinance/faster-image
```

## Usage

```js
import { FasterImageView } from '@candlefinance/faster-image';

<FasterImageView
  onError={(event) => console.warn(event.nativeEvent.error)}
  style={{ width: 400, height: 300 }}
  resizeMode="contain"
  thumbhash="k0oGLQaSVsJ0BVhn2oq2Z5SQUQcZ"
  cachePolicy="discNoCacheControl"
  transitionDuration={0.3}
  url="https://picsum.photos/seed/3240/4000/3000"
/>;
```

## Props

| Prop                                            | Type     | Default | Description                                                                                          |
| ----------------------------------------------- | -------- | ------- | ---------------------------------------------------------------------------------------------------- |
| url                                             | string   |         | The URL of the image                                                                                 |
| style                                           | object   |         | The style of the image                                                                               |
| resizeMode                                      | string   | contain | The resize mode of the image                                                                         |
| [thumbhash](https://github.com/evanw/thumbhash) | string   |         | The thumbhash of the image as a base64 encoded string to show while loading                          |
| [blurhash](https://github.com/woltapp/blurhash) | string   |         | The blurhash of the image to show while loading                                                      |
| showActivityIndicator                           | boolean  | false   | Whether to show the UIActivityIndicatorView indicator when the image is loading                      |
| base64Placeholder                               | string   |         | The base64 encoded placeholder image to show while the image is loading                              |
| cachePolicy                                     | string   | memory  | The cache policy of the image                                                                        |
| transitionDuration                              | number   | 0.75    | The transition duration of the image                                                                 |
| onError                                         | function |         | The function to call when an error occurs. The error is passed as the first argument of the function |
| onSucess                                        | function |         | The function to call when the image is successfully loaded                                           |

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
