import React from 'react';
import { PhoneFrame } from './PhoneFrame.jsx';
import { PlantListScreen } from './PlantListScreen.jsx';
import { PlantDetailScreen } from './PlantDetailScreen.jsx';
import { PlantFormScreen } from './PlantFormScreen.jsx';
import { SmartGardenScreen } from './SmartGardenScreen.jsx';
import { OnboardingScreen } from './OnboardingScreen.jsx';

const seedPlants = [
  { id: 1, name: 'Monstera', species: 'Monstera deliciosa', location: 'Stue', status: 'due', statusText: 'Vannes i dag', statusTitle: 'Vannes i dag', lastWateredText: 'Sist vannet for 7 dager siden', acquired: '14. mars 2025', intervalDays: 7, waterNeed: 'Middels', lightNeed: 'Halvskygge', lightIcon: 'cloud-sun', ph: '5,5–7,0', notes: 'Støttepinne byttet i vår.', care: [{ type: 'watering', date: '26. aug. 2026' }, { type: 'fertilizing', date: '12. aug. 2026', note: 'Flytende gjødsel' }] },
  { id: 2, name: 'Fikentre', species: 'Ficus lyrata', location: 'Stue', status: 'overdue', statusText: 'Forfalt – skulle vannes i går', statusTitle: 'Trenger vann – forfalt', lastWateredText: 'Sist vannet for 9 dager siden', acquired: '2. juni 2025', intervalDays: 8, waterNeed: 'Middels', lightNeed: 'Full sol', lightIcon: 'sun', ph: '6,0–7,0', notes: '', care: [{ type: 'watering', date: '24. aug. 2026' }] },
  { id: 3, name: 'Hortensia', species: 'Hydrangea macrophylla', location: 'Bed ved terrassen', status: 'ok', statusText: 'Vannes om 2 dager', statusTitle: 'Vannes om 2 dager', lastWateredText: 'Sist vannet for 2 dager siden', acquired: '5. mai 2026', intervalDays: 4, waterNeed: 'Mye', lightNeed: 'Halvskygge', lightIcon: 'cloud-sun', ph: '4,5–5,5', soilFit: 'Trives i jorden her (pH 5,2)', notes: '', care: [{ type: 'watering', date: '31. aug. 2026' }, { type: 'pruning', date: '2. juli 2026', note: 'Visne blomster' }] },
  { id: 4, name: 'Lavendel', species: 'Lavandula angustifolia', location: 'Kjøkkenhagen', status: 'none', statusText: '', statusTitle: 'Ingen vanningsplan', lastWateredText: null, acquired: '20. apr. 2026', intervalDays: null, waterNeed: 'Lite', lightNeed: 'Full sol', lightIcon: 'sun', ph: '6,5–7,5', notes: 'Klarer seg selv ute.', care: [] },
  { id: 5, name: 'Basilikum', species: 'Ocimum basilicum', location: 'Kjøkken', status: 'ok', statusText: 'Vannes i morgen', statusTitle: 'Vannes i morgen', lastWateredText: 'Sist vannet i går', acquired: '10. aug. 2026', intervalDays: 2, waterNeed: 'Mye', lightNeed: 'Full sol', lightIcon: 'sun', ph: '6,0–7,5', notes: '', care: [{ type: 'watering', date: '1. sep. 2026' }] },
];

export function App() {
  const [plants, setPlants] = React.useState(seedPlants);
  const [screen, setScreen] = React.useState('onboarding'); // onboarding | list | detail
  const [activeId, setActiveId] = React.useState(null);
  const [sheet, setSheet] = React.useState(null); // 'form' | 'smart' | null
  const active = plants.find(p => p.id === activeId);
  const water = () => setPlants(ps => ps.map(p => p.id === activeId ? { ...p, status: 'ok', statusText: `Vannes om ${p.intervalDays || 7} dager`, statusTitle: `Vannes om ${p.intervalDays || 7} dager`, lastWateredText: 'Sist vannet nå nettopp', care: [{ type: 'watering', date: '2. sep. 2026' }, ...p.care] } : p));
  const addPlant = (name, species, intervalDays, notes) => {
    setPlants(ps => [...ps, { id: Date.now(), name, species: species || null, location: 'Stue', status: intervalDays ? 'never' : 'none', statusText: intervalDays ? 'Ikke vannet ennå' : '', statusTitle: intervalDays ? 'Ikke vannet ennå' : 'Ingen vanningsplan', lastWateredText: null, acquired: '2. sep. 2026', intervalDays, waterNeed: null, lightNeed: null, ph: null, notes, care: [] }]);
    setSheet(null);
  };
  let content;
  if (screen === 'onboarding') content = <OnboardingScreen onDone={() => setScreen('list')} />;
  else if (screen === 'detail' && active) content = <PlantDetailScreen plant={active} onBack={() => setScreen('list')} onWater={water} onEdit={() => setSheet('form')} />;
  else content = <PlantListScreen plants={plants} onOpenPlant={id => { setActiveId(id); setScreen('detail'); }} onAddPlant={() => setSheet('form')} onSmartGarden={() => setSheet('smart')} />;
  return (
    <PhoneFrame sheet={sheet === 'form' ? <PlantFormScreen onCancel={() => setSheet(null)} onSave={addPlant} /> : sheet === 'smart' ? <SmartGardenScreen onDone={() => setSheet(null)} /> : null} onDismissSheet={() => setSheet(null)}>
      {content}
    </PhoneFrame>
  );
}