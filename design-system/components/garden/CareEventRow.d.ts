/** Care-history row (Stell-historikk). Types mirror CareEventType in Models.swift. */
export interface CareEventRowProps {
  /** watering | fertilizing | repotting | pruning */
  type?: 'watering' | 'fertilizing' | 'repotting' | 'pruning';
  /** Formatted date, e.g. "12. aug. 2026" */
  date: string;
  note?: string;
  last?: boolean;
  style?: React.CSSProperties;
}