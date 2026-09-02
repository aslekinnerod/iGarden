import React from 'react';
import { Icon } from '../core/Icon.jsx';
const S = {
  overdue: { icon: 'triangle-alert', color: 'var(--status-overdue)', title: 'Trenger vann – forfalt' },
  due: { icon: 'triangle-alert', color: 'var(--status-due)', title: 'Vannes i dag' },
  never: { icon: 'triangle-alert', color: 'var(--status-due)', title: 'Ikke vannet ennå' },
  ok: { icon: 'circle-check', color: 'var(--status-ok)', title: 'Vannes senere' },
  none: { icon: 'circle-minus', color: 'var(--label-2)', title: 'Ingen vanningsplan' },
};
// Watering-status header from PlantDetailView: big glyph + headline + "Sist vannet …".
export function WateringStatus({ status = 'ok', title, caption, style }) {
  const s = S[status] || S.ok;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '10px 16px', fontFamily: 'var(--font-body)', ...style }}>
      <Icon name={s.icon} size={26} filled color={s.color} />
      <div>
        <div style={{ fontSize: 17, fontWeight: 600, color: 'var(--label-1)' }}>{title || s.title}</div>
        {caption ? <div style={{ fontSize: 12, color: 'var(--label-2)', marginTop: 2 }}>{caption}</div> : null}
      </div>
    </div>
  );
}