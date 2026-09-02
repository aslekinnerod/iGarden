import React from 'react';
import { StatusBar } from './PhoneFrame.jsx';
import { IconButton } from '../../components/core/IconButton.jsx';
import { SearchField } from '../../components/forms/SearchField.jsx';
import { ListSection } from '../../components/lists/ListSection.jsx';
import { PlantRow } from '../../components/garden/PlantRow.jsx';
import { Icon } from '../../components/core/Icon.jsx';
// «Mine planter» — ContentView.swift: large title, toolbar, search, sections per location.
export function PlantListScreen({ plants, onOpenPlant, onAddPlant, onSmartGarden }) {
  const [q, setQ] = React.useState('');
  const filtered = plants.filter(p => p.name.toLowerCase().includes(q.toLowerCase()) || (p.species || '').toLowerCase().includes(q.toLowerCase()));
  const groups = [...new Set(filtered.map(p => p.location))].sort((a, b) => a.localeCompare(b, 'no'));
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <StatusBar />
      <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 2, padding: '0 10px' }}>
        <IconButton icon="sparkles" label="Smart hage" onClick={onSmartGarden} />
        <IconButton icon="users" label="Del hagen" />
        <IconButton icon="circle-user" label="Konto" />
        <IconButton icon="bell" label="Varsler" />
        <IconButton icon="arrow-up-down" label="Sortering" />
        <IconButton icon="plus" label="Legg til plante" onClick={onAddPlant} />
      </div>
      <div style={{ padding: '2px 16px 10px' }}>
        <div style={{ fontSize: 34, fontWeight: 700, color: 'var(--label-1)', marginBottom: 10 }}>Mine planter</div>
        <SearchField placeholder="Søk på navn eller art" value={q} onChange={setQ} />
      </div>
      <div style={{ flex: 1, overflowY: 'auto', paddingTop: 6 }}>
        {groups.map(loc => {
          const inLoc = filtered.filter(p => p.location === loc);
          return (
            <ListSection key={loc} header={loc} headerAccessory={<span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>{inLoc.length} <Icon name="ellipsis" size={15} color="var(--accent)" /></span>}>
              {inLoc.map((p, i) => (
                <PlantRow key={p.id} name={p.name} location={p.location} status={p.status} statusText={p.statusText} needsWater={p.status === 'overdue' || p.status === 'due'} hasSchedule={p.status !== 'none'} last={i === inLoc.length - 1} onClick={() => onOpenPlant(p.id)} />
              ))}
            </ListSection>
          );
        })}
        {filtered.length === 0 ? <div style={{ textAlign: 'center', color: 'var(--label-2)', fontSize: 15, padding: 40 }}>Ingen treff for «{q}»</div> : null}
      </div>
    </div>
  );
}