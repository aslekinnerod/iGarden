import React from 'react';
import { Icon } from '../core/Icon.jsx';
const TYPES = { watering: { icon: 'droplet', label: 'Vanning' }, fertilizing: { icon: 'leaf', label: 'Gjødsling' }, repotting: { icon: 'refresh-cw', label: 'Ompotting' }, pruning: { icon: 'scissors', label: 'Beskjæring' } };
// Care-history row from PlantDetailView: type icon, name, "dato · notat".
export function CareEventRow({ type = 'watering', date, note, last = false, style }) {
  const t = TYPES[type] || TYPES.watering;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, minHeight: 44, padding: '8px 16px', boxSizing: 'border-box', fontFamily: 'var(--font-body)', borderBottom: last ? 'none' : '1px solid var(--separator)', ...style }}>
      <Icon name={t.icon} size={18} color="var(--label-2)" style={{ width: 20 }} />
      <div>
        <div style={{ fontSize: 17, color: 'var(--label-1)' }}>{t.label}</div>
        <div style={{ fontSize: 12, color: 'var(--label-2)', marginTop: 1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{date}{note ? ` · ${note}` : ''}</div>
      </div>
    </div>
  );
}