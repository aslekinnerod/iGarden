import React from 'react';
import { SheetNav } from './PhoneFrame.jsx';
import { ListSection } from '../../components/lists/ListSection.jsx';
import { ListRow } from '../../components/lists/ListRow.jsx';
import { Input } from '../../components/forms/Input.jsx';
import { Switch } from '../../components/forms/Switch.jsx';
import { Stepper } from '../../components/forms/Stepper.jsx';
// «Ny plante» — PlantFormView.swift.
export function PlantFormScreen({ onCancel, onSave }) {
  const [name, setName] = React.useState('');
  const [species, setSpecies] = React.useState('');
  const [schedule, setSchedule] = React.useState(true);
  const [days, setDays] = React.useState(7);
  const [notes, setNotes] = React.useState('');
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <SheetNav title="Ny plante" leftLabel="Avbryt" onLeft={onCancel} rightLabel="Lagre" rightDisabled={!name.trim()} onRight={() => onSave(name.trim(), species.trim(), schedule ? days : null, notes.trim())} />
      <div style={{ flex: 1, overflowY: 'auto', paddingTop: 8 }}>
        <ListSection header="Om planten">
          <Input placeholder="Navn" value={name} onChange={setName} style={{ borderBottom: '1px solid var(--separator)' }} />
          <Input placeholder="Art / latinsk navn" value={species} onChange={setSpecies} style={{ borderBottom: '1px solid var(--separator)' }} />
          <ListRow title="Plassering" value="Stue" chevron onClick={() => {}} />
          <ListRow title="Anskaffet" value="2. sep. 2026" last />
        </ListSection>
        <ListSection header="Vanning" footer={!schedule ? 'Uten vanningsplan får planten ingen påminnelser og vises ikke under «Trenger vann». Passer for uteplanter som klarer seg selv.' : null}>
          <ListRow title="Vanningsplan" trailing={<Switch checked={schedule} onChange={setSchedule} />} last={!schedule} />
          {schedule ? <ListRow title={`Hver ${days}. dag`} trailing={<Stepper value={days} onChange={setDays} />} last /> : null}
        </ListSection>
        <ListSection header="Vann og lys" footer="Fylles inn automatisk for kjente planter når du lagrer.">
          <ListRow title="Vannbehov" value="Ikke satt" chevron onClick={() => {}} />
          <ListRow title="Lysbehov" value="Ikke satt" chevron last onClick={() => {}} />
        </ListSection>
        <ListSection header="Jord (pH)" footer="Brukes av Smart hage til å foreslå riktig bed. Fylles inn automatisk for kjente planter når du lagrer.">
          <ListRow title="Angi pH-preferanse manuelt" style={{ color: 'var(--accent)' }} last onClick={() => {}} />
        </ListSection>
        <ListSection header="Notater">
          <Input placeholder="Notater" multiline value={notes} onChange={setNotes} style={{ minHeight: 80 }} />
        </ListSection>
      </div>
    </div>
  );
}