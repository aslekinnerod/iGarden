import React from 'react';
import { Icon } from '../core/Icon.jsx';
// Onboarding feature row: green glyph, headline, subheadline.
export function FeatureRow({ icon, title, text, style }) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-start', gap: 14, fontFamily: 'var(--font-body)', ...style }}>
      <Icon name={icon} size={26} color="var(--accent)" style={{ width: 32, justifyContent: 'center', marginTop: 2 }} />
      <div>
        <div style={{ fontSize: 17, fontWeight: 600, color: 'var(--label-1)' }}>{title}</div>
        <div style={{ fontSize: 15, color: 'var(--label-2)', marginTop: 2, lineHeight: 1.35 }}>{text}</div>
      </div>
    </div>
  );
}