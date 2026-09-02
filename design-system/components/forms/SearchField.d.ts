/** iOS search bar (.searchable modifier). */
export interface SearchFieldProps {
  /** e.g. "Søk på navn eller art" */
  placeholder?: string;
  value?: string;
  onChange?: (value: string) => void;
  style?: React.CSSProperties;
}