/** Watering-status header on the plant detail page. */
export interface WateringStatusProps {
  status?: 'overdue' | 'due' | 'never' | 'ok' | 'none';
  /** Overrides the default Norwegian status title, e.g. "Vannes om 3 dager" */
  title?: string;
  /** e.g. "Sist vannet for 4 dager siden" */
  caption?: string;
  style?: React.CSSProperties;
}