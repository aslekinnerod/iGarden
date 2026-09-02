/** iOS toggle switch. */
export interface SwitchProps {
  checked?: boolean;
  onChange?: (checked: boolean) => void;
  style?: React.CSSProperties;
}