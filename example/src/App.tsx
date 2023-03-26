import * as React from 'react';

import { FasterImageView } from '@candlefinance/faster-image';
// import FastImage from 'react-native-fast-image';
import { Dimensions, FlatList, SafeAreaView, StyleSheet } from 'react-native';

export default function App() {
  const imageURLs = Array.from(
    { length: 1000 },
    (_, i) => `https://picsum.photos/seed/${i}/100/100`
  );
  const screenWidth = Dimensions.get('window').width;
  return (
    <SafeAreaView style={styles.container}>
      <FlatList
        keyExtractor={(item) => item}
        data={imageURLs}
        numColumns={3}
        getItemLayout={(_, index) => ({
          length: 100,
          offset: 100 * index,
          index,
        })}
        renderItem={({ item }) => (
          <FasterImageView
            onError={(event) => console.warn(event.nativeEvent.error)}
            // eslint-disable-next-line react-native/no-inline-styles
            style={{ width: screenWidth / 3, height: 100 }}
            transitionDuration={0}
            cachePolicy="discWithCacheControl"
            url={item}
          />
          // <FastImage
          //   style={{ width: screenWidth / 3, height: 100 }}
          //   source={{
          //     uri: item,
          //   }}
          //   resizeMode={FastImage.resizeMode.cover}
          // />
        )}
      />
    </SafeAreaView>
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
