import * as React from 'react';

import { FasterImageView } from '@candlefinance/faster-image';
import { StyleSheet, View } from 'react-native';

export default function App() {
  return (
    <View style={styles.container}>
      <FasterImageView
        url="https://picsum.photos/seed/3240/4000/3000"
        onError={(event) => console.warn(event.nativeEvent.error)}
        style={styles.box}
        resizeMode="contain"
        thumbhash="k0oGLQaSVsJ0BVhn2oq2Z5SQUQcZ"
        cachePolicy="discWithCacheContol"
        transitionDuration={0.3}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    borderWidth: 1,
    width: 300,
    height: 300,
  },
});
