/** Lucide glyph wrapper (SF Symbols web substitute). */
export interface IconProps {
  /** Lucide icon name, kebab-case, e.g. "droplet", "leaf", "cloud-sun" */
  name: string;
  /** px, default 20 */
  size?: number;
  /** CSS color, defaults to currentColor */
  color?: string;
  /** Fill with currentColor (SF ".fill" variants) */
  filled?: boolean;
  strokeWidth?: number;
  style?: React.CSSProperties;
}