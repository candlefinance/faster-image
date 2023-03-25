import * as React from 'react';

import { FasterImageView } from '@candlefinance/faster-image';
import { StyleSheet, View } from 'react-native';

export default function App() {
  return (
    <View style={styles.container}>
      <FasterImageView
        url="https://picsum.photos/seed/210/4000/3000"
        onSuccess={(event) => console.warn(event.nativeEvent.cacheKey)}
        onError={(event) => console.warn(event.nativeEvent.error)}
        style={styles.box}
        showActivityIndicator
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
    width: 200,
    height: 200,
    aspectRatio: 1,
    marginVertical: 20,
  },
});
