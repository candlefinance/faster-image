import * as React from 'react';

import { FasterImageView } from '@candlefinance/faster-image';
// import FastImage from 'react-native-fast-image';
import { Dimensions, FlatList, SafeAreaView, StyleSheet } from 'react-native';

const size = Dimensions.get('window').width / 3;

export default function App() {
  const imageURLs = Array.from(
    { length: 1000 },
    (_, i) => `https://picsum.photos/seed/${i}/1000/1000`
  );

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
            transitionDuration={0.75}
            cachePolicy="discNoCacheControl"
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
