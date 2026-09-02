/** Generic grouped-list row (LabeledContent / NavigationLink row). */
export interface ListRowProps {
  /** Lucide icon name for the leading glyph */
  icon?: string;
  iconColor?: string;
  /** Custom leading node (thumbnail etc.) — overrides icon */
  leading?: React.ReactNode;
  title: React.ReactNode;
  subtitle?: React.ReactNode;
  /** Right-aligned secondary value (LabeledContent) */
  value?: string;
  /** Custom trailing node (Switch, Stepper, button) */
  trailing?: React.ReactNode;
  /** Navigation chevron */
  chevron?: boolean;
  /** Red title (Slett plante) */
  destructive?: boolean;
  /** Suppress bottom separator (last row in section) */
  last?: boolean;
  onClick?: () => void;
  style?: React.CSSProperties;
}