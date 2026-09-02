import React from 'react';
import { Icon } from './Icon.jsx';
const STATUS = {
  overdue: { color: 'var(--status-overdue)', icon: 'triangle-alert', text: 'Trenger vann – forfalt' },
  due: { color: 'var(--status-due)', icon: 'triangle-alert', text: 'Vannes i dag' },
  never: { color: 'var(--status-due)', icon: 'triangle-alert', text: 'Ikke vannet ennå' },
  ok: { color: 'var(--status-ok)', icon: 'circle-check', text: 'Vannes senere' },
  none: { color: 'var(--label-2)', icon: 'circle-minus', text: 'Ingen vanningsplan' },
};
// Watering-status pill / dot+label. Statuses mirror WateringStatus in Models.swift.
export function Badge({ status = 'ok', children, pill = false, style }) {
  const s = STATUS[status] || STATUS.ok;
  if (pill) return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, fontFamily: 'var(--font-body)', fontSize: 12, fontWeight: 600, color: '#fff', background: s.color, borderRadius: 999, padding: '3px 10px', ...style }}>
      <Icon name={s.icon} size={12} filled />{children || s.text}
    </span>
  );
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, fontFamily: 'var(--font-body)', fontSize: 12, color: s.color, ...style }}>
      <Icon name="droplet" size={12} filled />{children || s.text}
    </span>
  );
}