import * as React from 'react';

import { FasterImageView } from '@candlefinance/faster-image';
// import FastImage from 'react-native-fast-image';
import { Dimensions, FlatList, SafeAreaView, StyleSheet } from 'react-native';

const size = Dimensions.get('window').width / 3;
const imageURLs = Array.from(
  { length: 10 },
  (_, i) => `https://picsum.photos/200/200?random=${i}`
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
            // rounded
            source={{
              transitionDuration: 0.3,
              cachePolicy: 'discWithCacheControl',
              showActivityIndicator: true,
              failureImage: 'k0oGLQaSVsJ0BVhn2oq2Z5SQUQcZ',
              url: item,
            }}
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
    borderRadius: size / 2,
    overflow: 'hidden',
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
