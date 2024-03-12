import * as React from 'react';

import { FasterImageView } from '@candlefinance/faster-image';
// import FastImage from 'react-native-fast-image';
import {
  Dimensions,
  FlatList,
  Platform,
  SafeAreaView,
  StyleSheet,
} from 'react-native';

const size = Dimensions.get('window').width / 3;
const imageURLs = Array.from(
  { length: 1000 },
  (_, i) => `https://picsum.photos/200/200?random=${4000 + i}`
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
          length: size - 16,
          offset: (size - 16) * index,
          index,
        })}
        renderItem={({ item }) => (
          <FasterImageView
            onError={(event) => console.warn(event.nativeEvent.error)}
            style={styles.image}
            onSuccess={(event) => {
              console.log(event.nativeEvent);
            }}
            source={{
              transitionDuration: 0.3,
              borderRadius:
                Platform.OS === 'android' ? size * 2 : (size - 16) / 2,
              cachePolicy: 'discWithCacheControl',
              showActivityIndicator: true,
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
    width: size - 16,
    height: size - 16,
    borderRadius: (size - 16) / 2,
    overflow: 'hidden',
    backgroundColor: 'white',
  },
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#f1f1f1',
  },
  column: {
    justifyContent: 'space-between',
    marginVertical: 8,
    marginHorizontal: 8,
    gap: 8,
  },
});
