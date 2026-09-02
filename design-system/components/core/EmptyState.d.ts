/** ContentUnavailableView recreation: glyph, title, description, optional CTA. */
export interface EmptyStateProps {
  /** Lucide icon name, default "leaf" */
  icon?: string;
  title: string;
  description?: string;
  actionLabel?: string;
  onAction?: () => void;
  style?: React.CSSProperties;
}