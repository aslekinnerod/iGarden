import React from 'react';
import { Icon } from './Icon.jsx';
// Toolbar icon button (iOS navigation bar item) or floating material circle over photos.
export function IconButton({ icon, filled = false, floating = false, label, color, onClick, style }) {
  const [pressed, setPressed] = React.useState(false);
  const base = floating
    ? { width: 40, height: 40, borderRadius: '50%', background: 'rgba(255,255,255,.72)', backdropFilter: 'var(--blur-material)', WebkitBackdropFilter: 'var(--blur-material)', border: 'none' }
    : { width: 34, height: 34, borderRadius: '50%', background: 'transparent', border: 'none' };
  return (
    <button aria-label={label} title={label} onClick={onClick}
      onMouseDown={() => setPressed(true)} onMouseUp={() => setPressed(false)} onMouseLeave={() => setPressed(false)}
      style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', color: color || 'var(--accent)', opacity: pressed ? 'var(--press-opacity)' : 1, transition: 'opacity var(--dur-fast) var(--ease-out)', ...base, ...style }}>
      <Icon name={icon} size={floating ? 20 : 22} filled={filled} />
    </button>
  );
}