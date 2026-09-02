/**
 * Plant list row: thumbnail, status droplet, name, "Plassering · status".
 * @startingPoint section="Components" subtitle="Planteliste-rad med vanningsstatus" viewport="700x260"
 */
export interface PlantRowProps {
  name: string;
  /** Display location, e.g. "Stue" */
  location: string;
  /** e.g. "Vannes i dag", "Forfalt – skulle vannes i går" */
  statusText?: string;
  status?: 'overdue' | 'due' | 'never' | 'ok' | 'none';
  /** Photo URL; leaf placeholder when absent */
  photo?: string;
  /** false hides the status droplet (no watering plan) */
  hasSchedule?: boolean;
  /** Colors the status text */
  needsWater?: boolean;
  last?: boolean;
  onClick?: () => void;
  style?: React.CSSProperties;
}