import React from 'react';
import { StatusBar } from './PhoneFrame.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { Button } from '../../components/core/Button.jsx';
import { IconButton } from '../../components/core/IconButton.jsx';
import { ListSection } from '../../components/lists/ListSection.jsx';
import { ListRow } from '../../components/lists/ListRow.jsx';
import { WateringStatus } from '../../components/garden/WateringStatus.jsx';
import { CareEventRow } from '../../components/garden/CareEventRow.jsx';
// Plantedetalj — PlantDetailView.swift: photo header, watering, facts, care history.
export function PlantDetailScreen({ plant, onBack, onWater, onEdit }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <StatusBar />
      <div style={{ display: 'flex', alignItems: 'center', padding: '4px 8px', flexShrink: 0 }}>
        <button onClick={onBack} style={{ border: 'none', background: 'transparent', color: 'var(--accent)', fontSize: 17, fontFamily: 'var(--font-body)', display: 'flex', alignItems: 'center', gap: 2, cursor: 'pointer' }}><Icon name="chevron-left" size={22} />Mine planter</button>
        <button onClick={onEdit} style={{ border: 'none', background: 'transparent', color: 'var(--accent)', fontSize: 17, fontFamily: 'var(--font-body)', marginLeft: 'auto', cursor: 'pointer' }}>Rediger</button>
      </div>
      <div style={{ flex: 1, overflowY: 'auto' }}>
        <div style={{ fontSize: 34, fontWeight: 700, color: 'var(--label-1)', padding: '2px 16px 12px' }}>{plant.name}</div>
        <div style={{ margin: '0 16px 22px', borderRadius: 10, overflow: 'hidden', position: 'relative', height: 200, background: 'var(--fill-leaf)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="leaf" size={56} color="var(--fill-leaf-fg)" strokeWidth={1.5} />
          <div style={{ position: 'absolute', right: 10, bottom: 10 }}><IconButton icon="camera" filled floating label="Legg til bilde" /></div>
        </div>
        <ListSection header="Vanning">
          <WateringStatus status={plant.status} title={plant.statusTitle} caption={plant.lastWateredText} />
        </ListSection>
        <div style={{ margin: '-12px 16px 22px' }}>
          <Button size="large" fullWidth icon="droplet" onClick={onWater}>Vannet nå</Button>
        </div>
        <ListSection header="Om planten">
          {plant.species ? <ListRow title="Art" value={plant.species} /> : null}
          <ListRow title="Plassering" value={plant.location} />
          <ListRow title="Anskaffet" value={plant.acquired} />
          {plant.intervalDays ? <ListRow title="Vanningsintervall" value={`Hver ${plant.intervalDays}. dag`} /> : null}
          {plant.waterNeed ? <ListRow icon="droplet" title="Vannbehov" value={plant.waterNeed} /> : null}
          {plant.lightNeed ? <ListRow icon={plant.lightIcon || 'cloud-sun'} title="Lysbehov" value={plant.lightNeed} /> : null}
          <ListRow title="Jord (pH)" value={plant.ph || 'Ikke satt'} last={!plant.soilFit} />
          {plant.soilFit ? <ListRow leading={<Icon name="badge-check" size={20} filled color="var(--status-ok)" />} title={plant.soilFit} last /> : null}
        </ListSection>
        {plant.notes ? <ListSection header="Notater"><div style={{ padding: '12px 16px', fontSize: 17, color: 'var(--label-1)' }}>{plant.notes}</div></ListSection> : null}
        <ListSection header="Stell-historikk" headerAccessory={<Icon name="circle-plus" size={17} color="var(--accent)" />}>
          {plant.care.length === 0 ? <div style={{ padding: '12px 16px', fontSize: 17, color: 'var(--label-2)' }}>Ingen stell registrert ennå</div>
            : plant.care.map((c, i) => <CareEventRow key={i} type={c.type} date={c.date} note={c.note} last={i === plant.care.length - 1} />)}
        </ListSection>
      </div>
    </div>
  );
}