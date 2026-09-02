/** iOS inset-grouped list section: header, white body, explanatory footer. */
export interface ListSectionProps {
  /** e.g. "Vanning" — rendered uppercase 13px */
  header?: string;
  /** Right side of the header row (count, menu button) */
  headerAccessory?: React.ReactNode;
  /** Calm consequence prose, e.g. "Du får ett varsel per plante …" */
  footer?: React.ReactNode;
  children?: React.ReactNode;
  style?: React.CSSProperties;
}