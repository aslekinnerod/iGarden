/** iOS stepper (minus/plus). Used for watering interval and soil pH. */
export interface StepperProps {
  value: number;
  onChange?: (value: number) => void;
  /** default 1 */
  min?: number;
  /** default 60 */
  max?: number;
  /** default 1; use 0.1 for pH */
  step?: number;
  /** Label renderer, e.g. v => `Hver ${v}. dag` */
  format?: (value: number) => string;
  style?: React.CSSProperties;
}