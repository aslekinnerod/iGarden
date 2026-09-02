import React from 'react';
import { Icon } from '../../components/core/Icon.jsx';
import { Button } from '../../components/core/Button.jsx';
import { FeatureRow } from '../../components/garden/FeatureRow.jsx';
// Velkomstskjerm — OnboardingView.swift.
export function OnboardingScreen({ onDone }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%', padding: 24, boxSizing: 'border-box', background: '#fff' }}>
      <div style={{ flex: 1 }}></div>
      <div style={{ textAlign: 'center' }}>
        <Icon name="leaf" size={72} filled color="var(--accent)" strokeWidth={1} />
        <div style={{ fontSize: 28, fontWeight: 700, color: 'var(--label-1)', marginTop: 16 }}>Velkommen til iGarden</div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 20, padding: '32px 8px' }}>
        <FeatureRow icon="circle-plus" title="Registrer plantene dine" text="Navn, plassering, bilde og hvor ofte de skal vannes." />
        <FeatureRow icon="droplet" title="Hold vanningen i rute" text="Appen holder styr på hvem som trenger vann, og varsler deg når det er på tide." />
        <FeatureRow icon="images" title="Følg veksten" text="Ta bilder underveis og se utviklingen på tidslinjen." />
      </div>
      <div style={{ flex: 1 }}></div>
      <Button size="large" fullWidth onClick={onDone}>Kom i gang</Button>
    </div>
  );
}