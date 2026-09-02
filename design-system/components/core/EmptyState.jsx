import React from 'react';
import { Icon } from './Icon.jsx';
import { Button } from './Button.jsx';
// ContentUnavailableView recreation: big glyph, title, description, optional action.
export function EmptyState({ icon = 'leaf', title, description, actionLabel, onAction, style }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: '40px 32px', fontFamily: 'var(--font-body)', ...style }}>
      <Icon name={icon} size={48} color="var(--label-3)" strokeWidth={1.5} />
      <div style={{ fontSize: 20, fontWeight: 700, marginTop: 14, color: 'var(--label-1)' }}>{title}</div>
      {description ? <div style={{ fontSize: 15, color: 'var(--label-2)', marginTop: 6, maxWidth: 320 }}>{description}</div> : null}
      {actionLabel ? <Button style={{ marginTop: 18 }} onClick={onAction}>{actionLabel}</Button> : null}
    </div>
  );
}