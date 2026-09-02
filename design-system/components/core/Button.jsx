import React from 'react';
import { Icon } from './Icon.jsx';
// iOS button styles: prominent (.borderedProminent), bordered, plain (text), destructive.
export function Button({ variant = 'prominent', size = 'regular', icon, children, disabled = false, fullWidth = false, onClick, style }) {
  const [pressed, setPressed] = React.useState(false);
  const large = size === 'large';
  const base = {
    fontFamily: 'var(--font-body)', fontWeight: 600, border: 'none', cursor: disabled ? 'default' : 'pointer',
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6, boxSizing: 'border-box',
    fontSize: large ? 17 : 15, height: large ? 50 : 34, padding: large ? '0 20px' : '0 14px',
    borderRadius: large ? 12 : 40, width: fullWidth ? '100%' : undefined,
    opacity: disabled ? 0.4 : pressed ? 'var(--press-opacity)' : 1,
    transition: 'opacity var(--dur-fast) var(--ease-out)',
  };
  const variants = {
    prominent: { background: 'var(--accent)', color: '#fff' },
    bordered: { background: 'var(--fill-leaf)', color: 'var(--accent)' },
    plain: { background: 'transparent', color: 'var(--accent)', padding: '0 4px', height: 'auto', fontWeight: 400 },
    destructive: { background: 'transparent', color: 'var(--destructive)', padding: '0 4px', fontWeight: 400 },
  };
  return (
    <button style={{ ...base, ...variants[variant], ...style }} disabled={disabled} onClick={onClick}
      onMouseDown={() => setPressed(true)} onMouseUp={() => setPressed(false)} onMouseLeave={() => setPressed(false)}>
      {icon ? <Icon name={icon} size={large ? 18 : 16} filled={variant === 'prominent'} /> : null}
      {children}
    </button>
  );
}