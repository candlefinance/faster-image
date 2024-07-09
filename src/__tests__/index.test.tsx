import { FasterImageView } from "..";
import React from "react";
import { render } from '@testing-library/react-native';

describe('index', () => {
  it('check if the test is working', () => {
    expect(true).toBe(true);
  });

  it('check test Image Rendering', () => {
    const { toJSON } = render(<FasterImageView style={{
      width: 100,
      height: 100,
    }} source={require('../../example/images/candle-logo.png')} />);
    expect(toJSON()).toMatchSnapshot();
  });

});
