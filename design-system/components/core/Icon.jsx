import React from 'react';
// Lucide glyph wrapper — SF Symbols substitute. Requires the Lucide UMD script (see Icon.prompt.md).
export function Icon({ name, size = 20, color, filled = false, strokeWidth = 2, style }) {
  const ref = React.useRef(null);
  React.useEffect(() => {
    const l = window.lucide;
    if (!ref.current) return;
    ref.current.innerHTML = '';
    if (!l) return;
    const pascal = name.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join('');
    const def = (l.icons && l.icons[pascal]) || null;
    if (!def) return;
    const el = l.createElement(def);
    el.setAttribute('width', size);
    el.setAttribute('height', size);
    el.setAttribute('stroke-width', strokeWidth);
    if (filled) { el.setAttribute('fill', 'currentColor'); el.setAttribute('stroke-width', 1); }
    ref.current.appendChild(el);
  }, [name, size, filled, strokeWidth]);
  return <span ref={ref} style={{ display: 'inline-flex', width: size, height: size, color: color || 'currentColor', flexShrink: 0, ...style }} />;
}