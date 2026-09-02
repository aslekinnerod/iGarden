import React from 'react';
import { SheetNav } from './PhoneFrame.jsx';
import { ListSection } from '../../components/lists/ListSection.jsx';
import { Stepper } from '../../components/forms/Stepper.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { Button } from '../../components/core/Button.jsx';
const fmt = v => v.toFixed(1).replace('.', ',');
const soilCharacter = ph => ph < 5.5 ? 'sur jord' : ph < 6.5 ? 'svakt sur jord' : ph < 7.5 ? 'nøytral jord' : 'kalkrik jord';
// «Smart hage» — SmartGardenView.swift: soil pH per bed + move recommendations.
export function SmartGardenScreen({ onDone }) {
  const [beds, setBeds] = React.useState([
    { name: 'Bed ved terrassen', ph: 5.2 },
    { name: 'Kjøkkenhagen', ph: 6.8 },
    { name: 'Bed langs gjerdet', ph: null },
  ]);
  const setPh = (i, v) => setBeds(b => b.map((bed, j) => j === i ? { ...bed, ph: v } : bed));
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <SheetNav title="Smart hage" rightLabel="Ferdig" onRight={onDone} />
      <div style={{ flex: 1, overflowY: 'auto', paddingTop: 8 }}>
        <ListSection header="Bed og jord" footer="Mål pH med en jordtester og juster verdien her. Uten pH kan ikke bedet vurderes.">
          {beds.map((bed, i) => (
            <div key={bed.name} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '10px 16px', borderBottom: i === beds.length - 1 ? 'none' : '1px solid var(--separator)' }}>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 17, color: 'var(--label-1)' }}>{bed.name}</div>
                <div style={{ fontSize: 12, color: 'var(--label-2)', marginTop: 1 }}>{bed.ph ? `pH ${fmt(bed.ph)} · ${soilCharacter(bed.ph)}` : 'pH ikke målt'}</div>
              </div>
              <Stepper value={bed.ph ?? 6.5} min={3.5} max={9} step={0.1} onChange={v => setPh(i, +v.toFixed(1))} />
            </div>
          ))}
        </ListSection>
        <ListSection header="Anbefalinger" footer="2 planter trives der de står.">
          <div style={{ padding: '12px 16px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <Icon name="triangle-alert" size={18} filled color="var(--status-due)" />
              <span style={{ fontSize: 17, fontWeight: 600, color: 'var(--label-1)' }}>Hortensia</span>
            </div>
            <div style={{ fontSize: 15, color: 'var(--label-2)', marginTop: 4 }}>Kjøkkenhagen (pH 6,8) er for kalkrikt – planten vil ha pH 4,5–5,5.</div>
            <Button variant="plain" icon="arrow-right" style={{ marginTop: 8 }}>Flytt til Bed ved terrassen (pH 5,2)</Button>
          </div>
        </ListSection>
      </div>
    </div>
  );
}