iOS stepper for watering interval («Hver 7. dag», 1–60) or soil pH (3,5–9,0, step 0,1).

```jsx
<Stepper value={7} onChange={setDays} format={v => `Hver ${v}. dag`} />
<Stepper value={6.5} min={3.5} max={9} step={0.1} format={v => `pH ${v.toFixed(1).replace('.', ',')}`} />
```