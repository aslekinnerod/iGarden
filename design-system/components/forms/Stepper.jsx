import React from 'react';
// iOS stepper: gray segmented minus/plus control.
export function Stepper({ value, onChange, min = 1, max = 60, step = 1, format, style }) {
  const dec = () => onChange && onChange(Math.max(min, +(value - step).toFixed(2)));
  const inc = () => onChange && onChange(Math.min(max, +(value + step).toFixed(2)));
  const btn = { width: 42, height: 32, border: 'none', background: 'transparent', fontSize: 20, color: 'var(--label-1)', cursor: 'pointer', fontFamily: 'var(--font-body)', lineHeight: 1 };
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, fontFamily: 'var(--font-body)', ...style }}>
      {format ? <span style={{ fontSize: 17, color: 'var(--label-1)' }}>{format(value)}</span> : null}
      <div style={{ display: 'inline-flex', background: 'rgba(118,118,128,.12)', borderRadius: 8, overflow: 'hidden' }}>
        <button style={btn} onClick={dec} disabled={value <= min} aria-label="Mindre">−</button>
        <div style={{ width: 1, background: 'var(--separator)', margin: '6px 0' }}></div>
        <button style={btn} onClick={inc} disabled={value >= max} aria-label="Mer">+</button>
      </div>
    </div>
  );
}