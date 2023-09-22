import * as React from 'react';

import { FasterImageView } from '@candlefinance/faster-image';
// import FastImage from 'react-native-fast-image';
import { Dimensions, FlatList, SafeAreaView, StyleSheet } from 'react-native';

const size = Dimensions.get('window').width / 3;
const imageURLs = Array.from(
  { length: 100 },
  (_, i) => `https://cataas.com/cat?width=200&height=200&${i}`
);

export default function App() {
  return (
    <SafeAreaView style={styles.container}>
      <FlatList
        keyExtractor={(item) => item}
        data={imageURLs}
        numColumns={3}
        columnWrapperStyle={styles.column}
        getItemLayout={(_, index) => ({
          length: size,
          offset: size * index,
          index,
        })}
        renderItem={({ item }) => (
          <FasterImageView
            onError={(event) => console.warn(event.nativeEvent.error)}
            style={styles.image}
            rounded
            transitionDuration={0.3}
            cachePolicy="memory"
            thumbhash="k0oGLQaSVsJ0BVhn2oq2Z5SQUQcZ"
            failureImage="k0oGLQaSVsJ0BVhn2oq2Z5SQUQcZ"
            url={item}
          />
        )}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  sep: { height: 24 },
  image: {
    width: size,
    height: size,
  },
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  column: {
    justifyContent: 'space-between',
    width: Dimensions.get('window').width,
  },
});
