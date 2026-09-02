import React from 'react';
import { Icon } from '../core/Icon.jsx';
// iOS search bar (.searchable): gray rounded field with magnifier.
export function SearchField({ placeholder = 'Søk', value, onChange, style }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 6, background: 'rgba(118,118,128,.12)', borderRadius: 10, padding: '7px 8px', fontFamily: 'var(--font-body)', ...style }}>
      <Icon name="search" size={16} color="var(--label-2)" />
      <input placeholder={placeholder} value={value} onChange={e => onChange && onChange(e.target.value)}
        style={{ border: 'none', outline: 'none', background: 'transparent', fontSize: 17, fontFamily: 'var(--font-body)', flex: 1, color: 'var(--label-1)', padding: 0 }} />
    </div>
  );
}