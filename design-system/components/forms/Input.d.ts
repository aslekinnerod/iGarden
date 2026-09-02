/** iOS form text field row (TextField in Form). */
export interface InputProps {
  /** Leading label; value aligns right when present */
  label?: string;
  placeholder?: string;
  value?: string;
  onChange?: (value: string) => void;
  /** Multi-line notes field (axis: .vertical) */
  multiline?: boolean;
  style?: React.CSSProperties;
}