import React from 'react';
// 390px iOS chrome: status bar + content + optional sheet overlay.
export function StatusBar({ light = false }) {
  return (
    <div style={{ height: 44, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 24px', fontFamily: 'var(--font-body)', fontSize: 15, fontWeight: 600, color: light ? '#fff' : 'var(--label-1)', flexShrink: 0 }}>
      <span>09:41</span>
      <span style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <svg width="17" height="11" viewBox="0 0 17 11" fill="currentColor"><rect x="0" y="7" width="3" height="4" rx="1"/><rect x="4.5" y="5" width="3" height="6" rx="1"/><rect x="9" y="2.5" width="3" height="8.5" rx="1"/><rect x="13.5" y="0" width="3" height="11" rx="1"/></svg>
        <svg width="24" height="11" viewBox="0 0 24 11"><rect x="0.5" y="0.5" width="20" height="10" rx="3" fill="none" stroke="currentColor" opacity=".4"/><rect x="2" y="2" width="17" height="7" rx="1.5" fill="currentColor"/><path d="M22 3.5v4c1-.4 1.5-1.2 1.5-2s-.5-1.6-1.5-2z" fill="currentColor" opacity=".4"/></svg>
      </span>
    </div>
  );
}
export function PhoneFrame({ children, sheet, onDismissSheet }) {
  return (
    <div style={{ width: 390, height: 800, background: 'var(--bg-grouped)', borderRadius: 40, overflow: 'hidden', position: 'relative', boxShadow: '0 24px 60px rgba(34,48,31,.25), 0 0 0 10px #1a1a1a', display: 'flex', flexDirection: 'column', fontFamily: 'var(--font-body)' }}>
      {children}
      {sheet ? (
        <div onClick={onDismissSheet} style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,.3)', display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', zIndex: 20 }}>
          <div onClick={e => e.stopPropagation()} style={{ background: 'var(--bg-grouped)', borderRadius: '14px 14px 0 0', height: '94%', overflow: 'hidden', display: 'flex', flexDirection: 'column', boxShadow: 'var(--shadow-sheet)', animation: 'sheetUp .25s var(--ease-out)' }}>{sheet}</div>
        </div>
      ) : null}
      <div style={{ position: 'absolute', bottom: 8, left: '50%', transform: 'translateX(-50%)', width: 134, height: 5, borderRadius: 3, background: 'rgba(0,0,0,.85)', zIndex: 30 }}></div>
    </div>
  );
}
// Sheet nav bar: cancel / title / confirm.
export function SheetNav({ title, leftLabel, onLeft, rightLabel, onRight, rightDisabled = false }) {
  const b = { border: 'none', background: 'transparent', fontFamily: 'var(--font-body)', fontSize: 17, color: 'var(--accent)', cursor: 'pointer', padding: 0 };
  return (
    <div style={{ display: 'flex', alignItems: 'center', padding: '14px 16px', flexShrink: 0 }}>
      <div style={{ flex: 1 }}>{leftLabel ? <button style={b} onClick={onLeft}>{leftLabel}</button> : null}</div>
      <div style={{ fontSize: 17, fontWeight: 600, color: 'var(--label-1)' }}>{title}</div>
      <div style={{ flex: 1, textAlign: 'right' }}>{rightLabel ? <button style={{ ...b, fontWeight: 600, opacity: rightDisabled ? .35 : 1 }} onClick={rightDisabled ? undefined : onRight}>{rightLabel}</button> : null}</div>
    </div>
  );
}