import React from 'react';

const safeTop = 44; // notch
const safeBottom = 88; // nav + padding

export function SafeArea({ children, noBottom = false, style = {} }) {
  return (
    <div
      style={{
        paddingTop: safeTop,
        paddingBottom: noBottom ? 24 : safeBottom,
        paddingLeft: 16,
        paddingRight: 16,
        minHeight: '100vh',
        ...style,
      }}
    >
      {children}
    </div>
  );
}
