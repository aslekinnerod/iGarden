import React from 'react';
// iOS inset-grouped section: uppercase header, white card body, footer prose.
export function ListSection({ header, headerAccessory, footer, children, style }) {
  return (
    <div style={{ fontFamily: 'var(--font-body)', margin: '0 16px 22px', ...style }}>
      {header ? (
        <div style={{ display: 'flex', alignItems: 'center', fontSize: 13, color: 'var(--label-2)', textTransform: 'uppercase', letterSpacing: '.4px', padding: '0 16px 7px' }}>
          <span>{header}</span>
          {headerAccessory ? <span style={{ marginLeft: 'auto', textTransform: 'none' }}>{headerAccessory}</span> : null}
        </div>
      ) : null}
      <div style={{ background: 'var(--surface-card)', borderRadius: 10, overflow: 'hidden' }}>{children}</div>
      {footer ? <div style={{ fontSize: 13, color: 'var(--label-2)', padding: '7px 16px 0', lineHeight: 1.35 }}>{footer}</div> : null}
    </div>
  );
}