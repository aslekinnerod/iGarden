/** Watering-status badge: colored droplet + label, or solid pill. */
export interface BadgeProps {
  /** Mirrors WateringStatus: overdue | due | never | ok | none */
  status?: 'overdue' | 'due' | 'never' | 'ok' | 'none';
  /** Solid colored pill instead of tinted text */
  pill?: boolean;
  /** Custom label; defaults to the Norwegian status text */
  children?: React.ReactNode;
  style?: React.CSSProperties;
}