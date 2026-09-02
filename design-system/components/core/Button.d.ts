/**
 * iOS-style button (borderedProminent / bordered / plain / destructive).
 * @startingPoint section="Components" subtitle="iGarden-knapper i alle varianter" viewport="700x220"
 */
export interface ButtonProps {
  /** default "prominent" */
  variant?: 'prominent' | 'bordered' | 'plain' | 'destructive';
  /** "large" = 50px full-width CTA style; default "regular" */
  size?: 'regular' | 'large';
  /** Lucide icon name rendered before the label */
  icon?: string;
  disabled?: boolean;
  fullWidth?: boolean;
  onClick?: () => void;
  children?: React.ReactNode;
  style?: React.CSSProperties;
}