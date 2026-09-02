import React from 'react';
// White grouped-list card container (iOS inset grouped section body).
export function Card({ children, inset = false, style }) {
  return <div style={{ background: 'var(--surface-card)', borderRadius: 'var(--radius-card)', overflow: 'hidden', padding: inset ? 16 : 0, ...style }}>{children}</div>;
}