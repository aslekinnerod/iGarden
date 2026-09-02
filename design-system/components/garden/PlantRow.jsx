import React from 'react';
import { Icon } from '../core/Icon.jsx';
const STATUS_COLOR = { overdue: 'var(--status-overdue)', due: 'var(--status-due)', never: 'var(--status-due)', ok: 'var(--status-ok)', none: 'var(--label-2)' };
// Thumbnail: plant photo or the leaf placeholder (green 12% fill, 50% glyph).
export function PlantThumb({ photo, size = 44, radius = 8 }) {
  return photo
    ? <img src={photo} alt="" style={{ width: size, height: size, borderRadius: radius, objectFit: 'cover', flexShrink: 0 }} />
    : <div style={{ width: size, height: size, borderRadius: radius, background: 'var(--fill-leaf)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="leaf" size={size * 0.45} color="var(--fill-leaf-fg)" /></div>;
}
// Plant list row from ContentView: thumb, status droplet, name, "Plassering · status".
export function PlantRow({ name, location, statusText, status = 'ok', photo, hasSchedule = true, needsWater = false, onClick, last = false, style }) {
  const [hover, setHover] = React.useState(false);
  return (
    <div onClick={onClick} onMouseEnter={() => setHover(true)} onMouseLeave={() => setHover(false)}
      style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '8px 16px', fontFamily: 'var(--font-body)', cursor: onClick ? 'pointer' : 'default', background: hover && onClick ? 'rgba(0,0,0,.04)' : 'transparent', borderBottom: last ? 'none' : '1px solid var(--separator)', ...style }}>
      <PlantThumb photo={photo} />
      {hasSchedule ? <Icon name="droplet" size={14} filled color={STATUS_COLOR[status]} /> : null}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 17, color: 'var(--label-1)' }}>{name}</div>
        <div style={{ fontSize: 12, color: 'var(--label-2)', marginTop: 1 }}>
          {location}{hasSchedule && statusText ? <span> · <span style={{ color: needsWater ? STATUS_COLOR[status] : 'var(--label-2)' }}>{statusText}</span></span> : null}
        </div>
      </div>
      <Icon name="chevron-right" size={16} color="var(--label-3)" />
    </div>
  );
}