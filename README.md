<br/>
<div align="center">
 <a href="https://www.npmjs.com/package/@candlefinance%2Ffaster-image">
  <img src="https://img.shields.io/npm/dm/@candlefinance%2Ffaster-image" alt="npm downloads" />
</a>
  <a alt="discord users online" href="https://discord.gg/qnAgjxhg6n" 
  target="_blank"
  rel="noopener noreferrer">
    <img alt="discord users online" src="https://img.shields.io/discord/986610142768406548?label=Discord&logo=discord&logoColor=white&cacheSeconds=3600"/>
</div>

<br/>

[![Watch the video](https://github-production-user-asset-6210df.s3.amazonaws.com/12258850/312097840-543e2f67-0d2b-4813-8993-7672e1d33fac.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20240312%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20240312T134017Z&X-Amz-Expires=300&X-Amz-Signature=4c43bc8467188be3e4af67fba56a093362c60232e701d999f6a6b2fcde2f18e5&X-Amz-SignedHeaders=host&actor_id=12258850&key_id=0&repo_id=618961414)](https://github-production-user-asset-6210df.s3.amazonaws.com/12258850/312097064-7095b50f-2a48-4cb5-a614-32f5b8e6f9c3.mp4)

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

## Installation

```sh
yarn add @candlefinance/faster-image
```

## Usage

```js
import { FasterImageView } from '@candlefinance/faster-image';

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
    url: item,
  }}
/>;
```

## Props

| Prop                      | Type     | Default                  | Description                                                                                          |
| ------------------------- | -------- | ------------------------ | ---------------------------------------------------------------------------------------------------- |
| url                       | string   |                          | The URL of the image                                                                                 |
| style                     | object   |                          | The style of the image                                                                               |
| resizeMode                | string   | contain                  | The resize mode of the image                                                                         |
| thumbhash                 | string   |                          | The thumbhash of the image as a base64 encoded string to show while loading (Android not tested)     |
| blurhash                  | string   |                          | The blurhash of the image to show while loading (iOS only)                                           |
| showActivityIndicator     | boolean  | false (iOS only)         | Whether to show the UIActivityIndicatorView indicator when the image is loading                      |
| base64Placeholder         | string   |                          | The base64 encoded placeholder image to show while the image is loading                              |
| cachePolicy               | string   | memory                   | The cache policy of the image                                                                        |
| transitionDuration        | number   | 0.75 (iOS) Android (100) | The transition duration of the image                                                                 |
| borderRadius              | number   | 0                        | border radius of image                                                                               |
| failureImage              | string   |                          | If the image fails to download this will be set (blurhash, thumbhash, base64)                        |
| progressiveLoadingEnabled | boolean  | false                    | Progressively load images (iOS only)                                                                 |
| onError                   | function |                          | The function to call when an error occurs. The error is passed as the first argument of the function |
| onSuccess                 | function |                          | The function to call when the image is successfully loaded                                           |

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
