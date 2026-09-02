import React from 'react';
import { Icon } from '../core/Icon.jsx';
// Generic grouped-list row: leading node/icon, title(+subtitle), trailing value/node, chevron.
export function ListRow({ icon, iconColor, leading, title, subtitle, value, trailing, chevron = false, destructive = false, onClick, last = false, style }) {
  const [hover, setHover] = React.useState(false);
  return (
    <div onClick={onClick} onMouseEnter={() => setHover(true)} onMouseLeave={() => setHover(false)}
      style={{ display: 'flex', alignItems: 'center', gap: 12, minHeight: 44, padding: '10px 16px', boxSizing: 'border-box', fontFamily: 'var(--font-body)', cursor: onClick ? 'pointer' : 'default', background: hover && onClick ? 'rgba(0,0,0,.04)' : 'transparent', borderBottom: last ? 'none' : '1px solid var(--separator)', ...style }}>
      {leading || (icon ? <Icon name={icon} size={20} color={iconColor || 'var(--label-2)'} /> : null)}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 17, color: destructive ? 'var(--destructive)' : 'var(--label-1)' }}>{title}</div>
        {subtitle ? <div style={{ fontSize: 12, color: 'var(--label-2)', marginTop: 2 }}>{subtitle}</div> : null}
      </div>
      {value ? <span style={{ fontSize: 17, color: 'var(--label-2)' }}>{value}</span> : null}
      {trailing}
      {chevron ? <Icon name="chevron-right" size={16} color="var(--label-3)" /> : null}
    </div>
  );
}