import React from 'react';
// iOS toggle, green when on (app accent is used by tint).
export function Switch({ checked = false, onChange, style }) {
  return (
    <button role="switch" aria-checked={checked} onClick={() => onChange && onChange(!checked)}
      style={{ width: 51, height: 31, borderRadius: 999, border: 'none', padding: 2, cursor: 'pointer', boxSizing: 'border-box', background: checked ? 'var(--status-ok)' : 'rgba(120,120,128,.32)', transition: 'background var(--dur-base) var(--ease-out)', display: 'inline-flex', justifyContent: checked ? 'flex-end' : 'flex-start', ...style }}>
      <span style={{ width: 27, height: 27, borderRadius: '50%', background: '#fff', boxShadow: '0 3px 8px rgba(0,0,0,.15), 0 1px 1px rgba(0,0,0,.16)' }}></span>
    </button>
  );
}