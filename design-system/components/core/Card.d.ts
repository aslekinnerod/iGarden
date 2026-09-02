/** White rounded container — iOS inset-grouped section body. */
export interface CardProps {
  /** 16px inner padding for free content (default: none, rows manage their own) */
  inset?: boolean;
  children?: React.ReactNode;
  style?: React.CSSProperties;
}