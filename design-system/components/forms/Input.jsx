import React from 'react';
// iOS form text field row: optional leading label, placeholder-styled input.
export function Input({ label, placeholder, value, onChange, multiline = false, style }) {
  const common = { fontFamily: 'var(--font-body)', fontSize: 17, border: 'none', outline: 'none', background: 'transparent', color: 'var(--label-1)', flex: 1, padding: 0, resize: 'none' };
  return (
    <div style={{ display: 'flex', alignItems: multiline ? 'flex-start' : 'center', gap: 12, minHeight: 44, padding: '10px 16px', boxSizing: 'border-box', fontFamily: 'var(--font-body)', ...style }}>
      {label ? <span style={{ fontSize: 17, color: 'var(--label-1)', whiteSpace: 'nowrap' }}>{label}</span> : null}
      {multiline
        ? <textarea rows={3} placeholder={placeholder} value={value} onChange={e => onChange && onChange(e.target.value)} style={common} />
        : <input placeholder={placeholder} value={value} onChange={e => onChange && onChange(e.target.value)} style={{ ...common, textAlign: label ? 'right' : 'left' }} />}
    </div>
  );
}