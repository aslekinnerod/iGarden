/** Toolbar icon button (nav bar item) or floating .thinMaterial circle over photos. */
export interface IconButtonProps {
  /** Lucide icon name */
  icon: string;
  /** Fill glyph (SF ".fill") */
  filled?: boolean;
  /** Material blur circle style used over the photo header */
  floating?: boolean;
  /** Accessible label, e.g. "Varsler" */
  label?: string;
  color?: string;
  onClick?: () => void;
  style?: React.CSSProperties;
}