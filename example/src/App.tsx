import * as React from 'react';

import { FasterImageView, clearCache } from '@candlefinance/faster-image';
import {
  Button,
  Dimensions,
  FlatList,
  Platform,
  SafeAreaView,
  StyleSheet,
} from 'react-native';

const size = Dimensions.get('window').width / 3;
const imageURLs = Array.from(
  { length: 100 },
  (_, i) => `https://picsum.photos/200/200?random=${4000 + i}`
);

export default function App() {
  return (
    <SafeAreaView style={styles.container}>
      {/* <FasterImageView
        onError={(event) => console.warn(event.nativeEvent.error)}
        style={styles.image}
        onSuccess={(event) => {
          console.log(event.nativeEvent);
        }}
        source={{
          transitionDuration: 0.3,
          // borderRadius: Platform.OS === 'android' ? size * 2 : (size - 16) / 2,
          cachePolicy: 'discWithCacheControl',
          showActivityIndicator: true,
          resizeMode: 'contain',
          base64Placeholder:
            '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Aj366KMOIDb5OeecQy+88IL77JBDDqG33357QIj6Cv3xxx/T6NGj3f9Qxdc+++xDCxcupAMPPLBfzIMPPpgeeughGjVqlIPknnvuoVtvvdXdxz/zfEcccYT7uRAggAOeL6PATz/9RLvvvjvddtttdN1119Fbb73lTP/000/T+eefT2eccQZ9//339Nxzz9HXX39NDM+cOXPoqquuogcffJBuv/12evPNN2n48OE0btw4Ouyww+iZZ55pmsKhhx5KbW1tDsxvv/3WzXf66afTrFmzBozJkNxyyy20bt06N//8+fPplFNOoeuvv54WLVpEK1eupG222WZwQABHGWtgLCvw6quv0qmnnuq2Mtttt50T5dhjj6W9996bZsyYQXvssYd7uo8ZM8Z9dt555zlgFi9eTAcddJAz97Rp09xns2fPpquvvpp+/vlnuuSSS9yWi2PwNXHiRDcHQ8XbuHfeeYeOP/5499mdd95J06dPp19//bVhTJ6Tgfjmm2/ovffec/d99tlnbtViqE888cTmgAAOGL6KAmy87777rnebwvt+Xg3Y7Gy+Y445hn755RfaaaedXPg77riDHnjgAQcBP7VfeeUV9zTni5/mvB3jswWfWU477TR69tln6c8//6SLLrqI3n//feLV4JNPPqHDDz/cAfnPP/+47RYD+eSTTzaNyfCNGDHCQcfbKz6L7LjjjvTII4/Q5Zdf3hgQwFHFGrhnSwXY4HwW4bPHBx984M4hF154If3777/U0tLihvP25rLLLnNbI14h3n33XTr66KPdZ19++aU7UPO9fGa45ppr6IknnnCf8Rbp5ptv3mxKHn/llVfShx9+6FYB3uo1i3n22WfTFVdcQePHj+89uPMKx3F5ezjgGQRwwOh1FeAnMYPBT3s+ALOZt99+e1q6dKlbQdasWUO77babm2bmzJk0b948t83hN098QOdzCl+ffvqpO4Pw6sLbqB9//NFt0fhpzzGGDBnixv311190991301133UXnnnuu23bttddetGHDhqYxL7jgArcF4y0ZvzRgGIcNG0YvvfSSg6YfIICjrjVwP3vopJNOcuZ9/PHHab/99usVpWcLw1ujI4880v2ezxK8LXr44YfdWYWf6jfccIP7jA/2U6ZMoRUrVrifJ0+e7GLyHPfff787Q/B18cUX0+uvv+7G89mh79UsJoPR0dHhgOCYS5Ysceenrq4ut/JsBgjggLl9KMArwFlnneVMx0/xnoufzAwLg7Hnnns6o7/22mtuy/XUU08RP82nTp3qVhMGiM8yfA5gg8+dO9eN5bMJx+XvV2688Ua3wvDbK95K8evanrMLz8mvjfntVrOYPS8UGK4DDjjAAfjRRx+5+JxvLyBDhw7tXWL6foHiQzDEyEuBm266ie67775+RZ955pn0/PPPO/PxU563S3xNmjSp980Uv3XiJzifQ/g66qij6I033nDfZfB3GmPHjqUFCxa4n4877jj3luree+91QA508ZeGjWKyz/nza6+91n0vwheD9uKLL7ovC3m7xa+BW7q6urp5P7flt4t5tRXVxlSAt1TLli1zK8zOO+/cb2o+sPMKwG+YfF3NYvIZh79pZwj55UHPborfvrV0dHR08z96Djy+EkIcKKBZAT7g88LxHwLPk0Gz4D/UAAAAAElFTkSuQmCC',
          url: 'https://picsum.photos/300/300?random=5',
        }}
      /> */}
      <Button title="Clear Cache" onPress={clearCache} color="red" />
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
              base64Placeholder:
                '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Aj366KMOIDb5OeecQy+88IL77JBDDqG33357QIj6Cv3xxx/T6NGj3f9Qxdc+++xDCxcupAMPPLBfzIMPPpgeeughGjVqlIPknnvuoVtvvdXdxz/zfEcccYT7uRAggAOeL6PATz/9RLvvvjvddtttdN1119Fbb73lTP/000/T+eefT2eccQZ9//339Nxzz9HXX39NDM+cOXPoqquuogcffJBuv/12evPNN2n48OE0btw4Ouyww+iZZ55pmsKhhx5KbW1tDsxvv/3WzXf66afTrFmzBozJkNxyyy20bt06N//8+fPplFNOoeuvv54WLVpEK1eupG222WZwQABHGWtgLCvw6quv0qmnnuq2Mtttt50T5dhjj6W9996bZsyYQXvssYd7uo8ZM8Z9dt555zlgFi9eTAcddJAz97Rp09xns2fPpquvvpp+/vlnuuSSS9yWi2PwNXHiRDcHQ8XbuHfeeYeOP/5499mdd95J06dPp19//bVhTJ6Tgfjmm2/ovffec/d99tlnbtViqE888cTmgAAOGL6KAmy87777rnebwvt+Xg3Y7Gy+Y445hn755RfaaaedXPg77riDHnjgAQcBP7VfeeUV9zTni5/mvB3jswWfWU477TR69tln6c8//6SLLrqI3n//feLV4JNPPqHDDz/cAfnPP/+47RYD+eSTTzaNyfCNGDHCQcfbKz6L7LjjjvTII4/Q5Zdf3hgQwFHFGrhnSwXY4HwW4bPHBx984M4hF154If3777/U0tLihvP25rLLLnNbI14h3n33XTr66KPdZ19++aU7UPO9fGa45ppr6IknnnCf8Rbp5ptv3mxKHn/llVfShx9+6FYB3uo1i3n22WfTFVdcQePHj+89uPMKx3F5ezjgGQRwwOh1FeAnMYPBT3s+ALOZt99+e1q6dKlbQdasWUO77babm2bmzJk0b948t83hN098QOdzCl+ffvqpO4Pw6sLbqB9//NFt0fhpzzGGDBnixv311190991301133UXnnnuu23bttddetGHDhqYxL7jgArcF4y0ZvzRgGIcNG0YvvfSSg6YfIICjrjVwP3vopJNOcuZ9/PHHab/99usVpWcLw1ujI4880v2ezxK8LXr44YfdWYWf6jfccIP7jA/2U6ZMoRUrVrifJ0+e7GLyHPfff787Q/B18cUX0+uvv+7G89mh79UsJoPR0dHhgOCYS5Ysceenrq4ut/JsBgjggLl9KMArwFlnneVMx0/xnoufzAwLg7Hnnns6o7/22mtuy/XUU08RP82nTp3qVhMGiM8yfA5gg8+dO9eN5bMJx+XvV2688Ua3wvDbK95K8evanrMLz8mvjfntVrOYPS8UGK4DDjjAAfjRRx+5+JxvLyBDhw7tXWL6foHiQzDEyEuBm266ie67775+RZ955pn0/PPPO/PxU563S3xNmjSp980Uv3XiJzifQ/g66qij6I033nDfZfB3GmPHjqUFCxa4n4877jj3luree+91QA508ZeGjWKyz/nza6+91n0vwheD9uKLL7ovC3m7xa+BW7q6urp5P7flt4t5tRXVxlSAt1TLli1zK8zOO+/cb2o+sPMKwG+YfF3NYvIZh79pZwj55UHPborfvrV0dHR08z96Djy+EkIcKKBZAT7g88LxHwLPk0Gz4D/UAAAAAElFTkSuQmCC',
              url: item,
              grayscale: 1,
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
  },
  column: {
    justifyContent: 'space-between',
    marginVertical: 8,
    marginHorizontal: 8,
    gap: 8,
  },
});
