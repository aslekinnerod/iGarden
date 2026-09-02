/* @ds-bundle: {"format":4,"namespace":"IGardenDesignSystem_631e89","components":[{"name":"Badge","sourcePath":"components/core/Badge.jsx"},{"name":"Button","sourcePath":"components/core/Button.jsx"},{"name":"Card","sourcePath":"components/core/Card.jsx"},{"name":"EmptyState","sourcePath":"components/core/EmptyState.jsx"},{"name":"Icon","sourcePath":"components/core/Icon.jsx"},{"name":"IconButton","sourcePath":"components/core/IconButton.jsx"},{"name":"Input","sourcePath":"components/forms/Input.jsx"},{"name":"SearchField","sourcePath":"components/forms/SearchField.jsx"},{"name":"Stepper","sourcePath":"components/forms/Stepper.jsx"},{"name":"Switch","sourcePath":"components/forms/Switch.jsx"},{"name":"CareEventRow","sourcePath":"components/garden/CareEventRow.jsx"},{"name":"FeatureRow","sourcePath":"components/garden/FeatureRow.jsx"},{"name":"PlantThumb","sourcePath":"components/garden/PlantRow.jsx"},{"name":"PlantRow","sourcePath":"components/garden/PlantRow.jsx"},{"name":"WateringStatus","sourcePath":"components/garden/WateringStatus.jsx"},{"name":"ListRow","sourcePath":"components/lists/ListRow.jsx"},{"name":"ListSection","sourcePath":"components/lists/ListSection.jsx"},{"name":"App","sourcePath":"ui_kits/ios-app/App.jsx"},{"name":"OnboardingScreen","sourcePath":"ui_kits/ios-app/OnboardingScreen.jsx"},{"name":"StatusBar","sourcePath":"ui_kits/ios-app/PhoneFrame.jsx"},{"name":"PhoneFrame","sourcePath":"ui_kits/ios-app/PhoneFrame.jsx"},{"name":"SheetNav","sourcePath":"ui_kits/ios-app/PhoneFrame.jsx"},{"name":"PlantDetailScreen","sourcePath":"ui_kits/ios-app/PlantDetailScreen.jsx"},{"name":"PlantFormScreen","sourcePath":"ui_kits/ios-app/PlantFormScreen.jsx"},{"name":"PlantListScreen","sourcePath":"ui_kits/ios-app/PlantListScreen.jsx"},{"name":"SmartGardenScreen","sourcePath":"ui_kits/ios-app/SmartGardenScreen.jsx"}],"sourceHashes":{"components/core/Badge.jsx":"b955348188bd","components/core/Button.jsx":"826685c88dac","components/core/Card.jsx":"423915ad1a52","components/core/EmptyState.jsx":"3dcf4bf2f807","components/core/Icon.jsx":"e73ff529c208","components/core/IconButton.jsx":"c94eec4b5556","components/forms/Input.jsx":"41327fecc250","components/forms/SearchField.jsx":"a6e39243819d","components/forms/Stepper.jsx":"b9a1c5311afe","components/forms/Switch.jsx":"839b2136891d","components/garden/CareEventRow.jsx":"6b90209bda90","components/garden/FeatureRow.jsx":"6391096ad680","components/garden/PlantRow.jsx":"cb3cc008ef47","components/garden/WateringStatus.jsx":"2df52c8796ea","components/lists/ListRow.jsx":"42ddce37cc6a","components/lists/ListSection.jsx":"3712374cb4e7","ui_kits/ios-app/App.jsx":"993d539655d5","ui_kits/ios-app/OnboardingScreen.jsx":"c32b749a2db7","ui_kits/ios-app/PhoneFrame.jsx":"d0f8b5bf927a","ui_kits/ios-app/PlantDetailScreen.jsx":"972cbccc59df","ui_kits/ios-app/PlantFormScreen.jsx":"7321615606ea","ui_kits/ios-app/PlantListScreen.jsx":"500355be0bd6","ui_kits/ios-app/SmartGardenScreen.jsx":"c749f335d28b"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.IGardenDesignSystem_631e89 = window.IGardenDesignSystem_631e89 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/core/Card.jsx
try { (() => {
// White grouped-list card container (iOS inset grouped section body).
function Card({
  children,
  inset = false,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      background: 'var(--surface-card)',
      borderRadius: 'var(--radius-card)',
      overflow: 'hidden',
      padding: inset ? 16 : 0,
      ...style
    }
  }, children);
}
Object.assign(__ds_scope, { Card });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Card.jsx", error: String((e && e.message) || e) }); }

// components/core/Icon.jsx
try { (() => {
// Lucide glyph wrapper — SF Symbols substitute. Requires the Lucide UMD script (see Icon.prompt.md).
function Icon({
  name,
  size = 20,
  color,
  filled = false,
  strokeWidth = 2,
  style
}) {
  const ref = React.useRef(null);
  React.useEffect(() => {
    const l = window.lucide;
    if (!ref.current) return;
    ref.current.innerHTML = '';
    if (!l) return;
    const pascal = name.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join('');
    const def = l.icons && l.icons[pascal] || null;
    if (!def) return;
    const el = l.createElement(def);
    el.setAttribute('width', size);
    el.setAttribute('height', size);
    el.setAttribute('stroke-width', strokeWidth);
    if (filled) {
      el.setAttribute('fill', 'currentColor');
      el.setAttribute('stroke-width', 1);
    }
    ref.current.appendChild(el);
  }, [name, size, filled, strokeWidth]);
  return /*#__PURE__*/React.createElement("span", {
    ref: ref,
    style: {
      display: 'inline-flex',
      width: size,
      height: size,
      color: color || 'currentColor',
      flexShrink: 0,
      ...style
    }
  });
}
Object.assign(__ds_scope, { Icon });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Icon.jsx", error: String((e && e.message) || e) }); }

// components/core/Badge.jsx
try { (() => {
const STATUS = {
  overdue: {
    color: 'var(--status-overdue)',
    icon: 'triangle-alert',
    text: 'Trenger vann – forfalt'
  },
  due: {
    color: 'var(--status-due)',
    icon: 'triangle-alert',
    text: 'Vannes i dag'
  },
  never: {
    color: 'var(--status-due)',
    icon: 'triangle-alert',
    text: 'Ikke vannet ennå'
  },
  ok: {
    color: 'var(--status-ok)',
    icon: 'circle-check',
    text: 'Vannes senere'
  },
  none: {
    color: 'var(--label-2)',
    icon: 'circle-minus',
    text: 'Ingen vanningsplan'
  }
};
// Watering-status pill / dot+label. Statuses mirror WateringStatus in Models.swift.
function Badge({
  status = 'ok',
  children,
  pill = false,
  style
}) {
  const s = STATUS[status] || STATUS.ok;
  if (pill) return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 5,
      fontFamily: 'var(--font-body)',
      fontSize: 12,
      fontWeight: 600,
      color: '#fff',
      background: s.color,
      borderRadius: 999,
      padding: '3px 10px',
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: s.icon,
    size: 12,
    filled: true
  }), children || s.text);
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 5,
      fontFamily: 'var(--font-body)',
      fontSize: 12,
      color: s.color,
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "droplet",
    size: 12,
    filled: true
  }), children || s.text);
}
Object.assign(__ds_scope, { Badge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Badge.jsx", error: String((e && e.message) || e) }); }

// components/core/Button.jsx
try { (() => {
// iOS button styles: prominent (.borderedProminent), bordered, plain (text), destructive.
function Button({
  variant = 'prominent',
  size = 'regular',
  icon,
  children,
  disabled = false,
  fullWidth = false,
  onClick,
  style
}) {
  const [pressed, setPressed] = React.useState(false);
  const large = size === 'large';
  const base = {
    fontFamily: 'var(--font-body)',
    fontWeight: 600,
    border: 'none',
    cursor: disabled ? 'default' : 'pointer',
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
    boxSizing: 'border-box',
    fontSize: large ? 17 : 15,
    height: large ? 50 : 34,
    padding: large ? '0 20px' : '0 14px',
    borderRadius: large ? 12 : 40,
    width: fullWidth ? '100%' : undefined,
    opacity: disabled ? 0.4 : pressed ? 'var(--press-opacity)' : 1,
    transition: 'opacity var(--dur-fast) var(--ease-out)'
  };
  const variants = {
    prominent: {
      background: 'var(--accent)',
      color: '#fff'
    },
    bordered: {
      background: 'var(--fill-leaf)',
      color: 'var(--accent)'
    },
    plain: {
      background: 'transparent',
      color: 'var(--accent)',
      padding: '0 4px',
      height: 'auto',
      fontWeight: 400
    },
    destructive: {
      background: 'transparent',
      color: 'var(--destructive)',
      padding: '0 4px',
      fontWeight: 400
    }
  };
  return /*#__PURE__*/React.createElement("button", {
    style: {
      ...base,
      ...variants[variant],
      ...style
    },
    disabled: disabled,
    onClick: onClick,
    onMouseDown: () => setPressed(true),
    onMouseUp: () => setPressed(false),
    onMouseLeave: () => setPressed(false)
  }, icon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: large ? 18 : 16,
    filled: variant === 'prominent'
  }) : null, children);
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Button.jsx", error: String((e && e.message) || e) }); }

// components/core/EmptyState.jsx
try { (() => {
// ContentUnavailableView recreation: big glyph, title, description, optional action.
function EmptyState({
  icon = 'leaf',
  title,
  description,
  actionLabel,
  onAction,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      textAlign: 'center',
      padding: '40px 32px',
      fontFamily: 'var(--font-body)',
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 48,
    color: "var(--label-3)",
    strokeWidth: 1.5
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 20,
      fontWeight: 700,
      marginTop: 14,
      color: 'var(--label-1)'
    }
  }, title), description ? /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 15,
      color: 'var(--label-2)',
      marginTop: 6,
      maxWidth: 320
    }
  }, description) : null, actionLabel ? /*#__PURE__*/React.createElement(__ds_scope.Button, {
    style: {
      marginTop: 18
    },
    onClick: onAction
  }, actionLabel) : null);
}
Object.assign(__ds_scope, { EmptyState });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/EmptyState.jsx", error: String((e && e.message) || e) }); }

// components/core/IconButton.jsx
try { (() => {
// Toolbar icon button (iOS navigation bar item) or floating material circle over photos.
function IconButton({
  icon,
  filled = false,
  floating = false,
  label,
  color,
  onClick,
  style
}) {
  const [pressed, setPressed] = React.useState(false);
  const base = floating ? {
    width: 40,
    height: 40,
    borderRadius: '50%',
    background: 'rgba(255,255,255,.72)',
    backdropFilter: 'var(--blur-material)',
    WebkitBackdropFilter: 'var(--blur-material)',
    border: 'none'
  } : {
    width: 34,
    height: 34,
    borderRadius: '50%',
    background: 'transparent',
    border: 'none'
  };
  return /*#__PURE__*/React.createElement("button", {
    "aria-label": label,
    title: label,
    onClick: onClick,
    onMouseDown: () => setPressed(true),
    onMouseUp: () => setPressed(false),
    onMouseLeave: () => setPressed(false),
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      cursor: 'pointer',
      color: color || 'var(--accent)',
      opacity: pressed ? 'var(--press-opacity)' : 1,
      transition: 'opacity var(--dur-fast) var(--ease-out)',
      ...base,
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: floating ? 20 : 22,
    filled: filled
  }));
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/forms/Input.jsx
try { (() => {
// iOS form text field row: optional leading label, placeholder-styled input.
function Input({
  label,
  placeholder,
  value,
  onChange,
  multiline = false,
  style
}) {
  const common = {
    fontFamily: 'var(--font-body)',
    fontSize: 17,
    border: 'none',
    outline: 'none',
    background: 'transparent',
    color: 'var(--label-1)',
    flex: 1,
    padding: 0,
    resize: 'none'
  };
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: multiline ? 'flex-start' : 'center',
      gap: 12,
      minHeight: 44,
      padding: '10px 16px',
      boxSizing: 'border-box',
      fontFamily: 'var(--font-body)',
      ...style
    }
  }, label ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 17,
      color: 'var(--label-1)',
      whiteSpace: 'nowrap'
    }
  }, label) : null, multiline ? /*#__PURE__*/React.createElement("textarea", {
    rows: 3,
    placeholder: placeholder,
    value: value,
    onChange: e => onChange && onChange(e.target.value),
    style: common
  }) : /*#__PURE__*/React.createElement("input", {
    placeholder: placeholder,
    value: value,
    onChange: e => onChange && onChange(e.target.value),
    style: {
      ...common,
      textAlign: label ? 'right' : 'left'
    }
  }));
}
Object.assign(__ds_scope, { Input });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Input.jsx", error: String((e && e.message) || e) }); }

// components/forms/SearchField.jsx
try { (() => {
// iOS search bar (.searchable): gray rounded field with magnifier.
function SearchField({
  placeholder = 'Søk',
  value,
  onChange,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6,
      background: 'rgba(118,118,128,.12)',
      borderRadius: 10,
      padding: '7px 8px',
      fontFamily: 'var(--font-body)',
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "search",
    size: 16,
    color: "var(--label-2)"
  }), /*#__PURE__*/React.createElement("input", {
    placeholder: placeholder,
    value: value,
    onChange: e => onChange && onChange(e.target.value),
    style: {
      border: 'none',
      outline: 'none',
      background: 'transparent',
      fontSize: 17,
      fontFamily: 'var(--font-body)',
      flex: 1,
      color: 'var(--label-1)',
      padding: 0
    }
  }));
}
Object.assign(__ds_scope, { SearchField });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/SearchField.jsx", error: String((e && e.message) || e) }); }

// components/forms/Stepper.jsx
try { (() => {
// iOS stepper: gray segmented minus/plus control.
function Stepper({
  value,
  onChange,
  min = 1,
  max = 60,
  step = 1,
  format,
  style
}) {
  const dec = () => onChange && onChange(Math.max(min, +(value - step).toFixed(2)));
  const inc = () => onChange && onChange(Math.min(max, +(value + step).toFixed(2)));
  const btn = {
    width: 42,
    height: 32,
    border: 'none',
    background: 'transparent',
    fontSize: 20,
    color: 'var(--label-1)',
    cursor: 'pointer',
    fontFamily: 'var(--font-body)',
    lineHeight: 1
  };
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      fontFamily: 'var(--font-body)',
      ...style
    }
  }, format ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 17,
      color: 'var(--label-1)'
    }
  }, format(value)) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'inline-flex',
      background: 'rgba(118,118,128,.12)',
      borderRadius: 8,
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement("button", {
    style: btn,
    onClick: dec,
    disabled: value <= min,
    "aria-label": "Mindre"
  }, "\u2212"), /*#__PURE__*/React.createElement("div", {
    style: {
      width: 1,
      background: 'var(--separator)',
      margin: '6px 0'
    }
  }), /*#__PURE__*/React.createElement("button", {
    style: btn,
    onClick: inc,
    disabled: value >= max,
    "aria-label": "Mer"
  }, "+")));
}
Object.assign(__ds_scope, { Stepper });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Stepper.jsx", error: String((e && e.message) || e) }); }

// components/forms/Switch.jsx
try { (() => {
// iOS toggle, green when on (app accent is used by tint).
function Switch({
  checked = false,
  onChange,
  style
}) {
  return /*#__PURE__*/React.createElement("button", {
    role: "switch",
    "aria-checked": checked,
    onClick: () => onChange && onChange(!checked),
    style: {
      width: 51,
      height: 31,
      borderRadius: 999,
      border: 'none',
      padding: 2,
      cursor: 'pointer',
      boxSizing: 'border-box',
      background: checked ? 'var(--status-ok)' : 'rgba(120,120,128,.32)',
      transition: 'background var(--dur-base) var(--ease-out)',
      display: 'inline-flex',
      justifyContent: checked ? 'flex-end' : 'flex-start',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 27,
      height: 27,
      borderRadius: '50%',
      background: '#fff',
      boxShadow: '0 3px 8px rgba(0,0,0,.15), 0 1px 1px rgba(0,0,0,.16)'
    }
  }));
}
Object.assign(__ds_scope, { Switch });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Switch.jsx", error: String((e && e.message) || e) }); }

// components/garden/CareEventRow.jsx
try { (() => {
const TYPES = {
  watering: {
    icon: 'droplet',
    label: 'Vanning'
  },
  fertilizing: {
    icon: 'leaf',
    label: 'Gjødsling'
  },
  repotting: {
    icon: 'refresh-cw',
    label: 'Ompotting'
  },
  pruning: {
    icon: 'scissors',
    label: 'Beskjæring'
  }
};
// Care-history row from PlantDetailView: type icon, name, "dato · notat".
function CareEventRow({
  type = 'watering',
  date,
  note,
  last = false,
  style
}) {
  const t = TYPES[type] || TYPES.watering;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      minHeight: 44,
      padding: '8px 16px',
      boxSizing: 'border-box',
      fontFamily: 'var(--font-body)',
      borderBottom: last ? 'none' : '1px solid var(--separator)',
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: t.icon,
    size: 18,
    color: "var(--label-2)",
    style: {
      width: 20
    }
  }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 17,
      color: 'var(--label-1)'
    }
  }, t.label), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--label-2)',
      marginTop: 1,
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis'
    }
  }, date, note ? ` · ${note}` : '')));
}
Object.assign(__ds_scope, { CareEventRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/garden/CareEventRow.jsx", error: String((e && e.message) || e) }); }

// components/garden/FeatureRow.jsx
try { (() => {
// Onboarding feature row: green glyph, headline, subheadline.
function FeatureRow({
  icon,
  title,
  text,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      gap: 14,
      fontFamily: 'var(--font-body)',
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 26,
    color: "var(--accent)",
    style: {
      width: 32,
      justifyContent: 'center',
      marginTop: 2
    }
  }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 17,
      fontWeight: 600,
      color: 'var(--label-1)'
    }
  }, title), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 15,
      color: 'var(--label-2)',
      marginTop: 2,
      lineHeight: 1.35
    }
  }, text)));
}
Object.assign(__ds_scope, { FeatureRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/garden/FeatureRow.jsx", error: String((e && e.message) || e) }); }

// components/garden/PlantRow.jsx
try { (() => {
const STATUS_COLOR = {
  overdue: 'var(--status-overdue)',
  due: 'var(--status-due)',
  never: 'var(--status-due)',
  ok: 'var(--status-ok)',
  none: 'var(--label-2)'
};
// Thumbnail: plant photo or the leaf placeholder (green 12% fill, 50% glyph).
function PlantThumb({
  photo,
  size = 44,
  radius = 8
}) {
  return photo ? /*#__PURE__*/React.createElement("img", {
    src: photo,
    alt: "",
    style: {
      width: size,
      height: size,
      borderRadius: radius,
      objectFit: 'cover',
      flexShrink: 0
    }
  }) : /*#__PURE__*/React.createElement("div", {
    style: {
      width: size,
      height: size,
      borderRadius: radius,
      background: 'var(--fill-leaf)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      flexShrink: 0
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "leaf",
    size: size * 0.45,
    color: "var(--fill-leaf-fg)"
  }));
}
// Plant list row from ContentView: thumb, status droplet, name, "Plassering · status".
function PlantRow({
  name,
  location,
  statusText,
  status = 'ok',
  photo,
  hasSchedule = true,
  needsWater = false,
  onClick,
  last = false,
  style
}) {
  const [hover, setHover] = React.useState(false);
  return /*#__PURE__*/React.createElement("div", {
    onClick: onClick,
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => setHover(false),
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      padding: '8px 16px',
      fontFamily: 'var(--font-body)',
      cursor: onClick ? 'pointer' : 'default',
      background: hover && onClick ? 'rgba(0,0,0,.04)' : 'transparent',
      borderBottom: last ? 'none' : '1px solid var(--separator)',
      ...style
    }
  }, /*#__PURE__*/React.createElement(PlantThumb, {
    photo: photo
  }), hasSchedule ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "droplet",
    size: 14,
    filled: true,
    color: STATUS_COLOR[status]
  }) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 17,
      color: 'var(--label-1)'
    }
  }, name), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--label-2)',
      marginTop: 1
    }
  }, location, hasSchedule && statusText ? /*#__PURE__*/React.createElement("span", null, " \xB7 ", /*#__PURE__*/React.createElement("span", {
    style: {
      color: needsWater ? STATUS_COLOR[status] : 'var(--label-2)'
    }
  }, statusText)) : null)), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-right",
    size: 16,
    color: "var(--label-3)"
  }));
}
Object.assign(__ds_scope, { PlantThumb, PlantRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/garden/PlantRow.jsx", error: String((e && e.message) || e) }); }

// components/garden/WateringStatus.jsx
try { (() => {
const S = {
  overdue: {
    icon: 'triangle-alert',
    color: 'var(--status-overdue)',
    title: 'Trenger vann – forfalt'
  },
  due: {
    icon: 'triangle-alert',
    color: 'var(--status-due)',
    title: 'Vannes i dag'
  },
  never: {
    icon: 'triangle-alert',
    color: 'var(--status-due)',
    title: 'Ikke vannet ennå'
  },
  ok: {
    icon: 'circle-check',
    color: 'var(--status-ok)',
    title: 'Vannes senere'
  },
  none: {
    icon: 'circle-minus',
    color: 'var(--label-2)',
    title: 'Ingen vanningsplan'
  }
};
// Watering-status header from PlantDetailView: big glyph + headline + "Sist vannet …".
function WateringStatus({
  status = 'ok',
  title,
  caption,
  style
}) {
  const s = S[status] || S.ok;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '10px 16px',
      fontFamily: 'var(--font-body)',
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: s.icon,
    size: 26,
    filled: true,
    color: s.color
  }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 17,
      fontWeight: 600,
      color: 'var(--label-1)'
    }
  }, title || s.title), caption ? /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--label-2)',
      marginTop: 2
    }
  }, caption) : null));
}
Object.assign(__ds_scope, { WateringStatus });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/garden/WateringStatus.jsx", error: String((e && e.message) || e) }); }

// components/lists/ListRow.jsx
try { (() => {
// Generic grouped-list row: leading node/icon, title(+subtitle), trailing value/node, chevron.
function ListRow({
  icon,
  iconColor,
  leading,
  title,
  subtitle,
  value,
  trailing,
  chevron = false,
  destructive = false,
  onClick,
  last = false,
  style
}) {
  const [hover, setHover] = React.useState(false);
  return /*#__PURE__*/React.createElement("div", {
    onClick: onClick,
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => setHover(false),
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      minHeight: 44,
      padding: '10px 16px',
      boxSizing: 'border-box',
      fontFamily: 'var(--font-body)',
      cursor: onClick ? 'pointer' : 'default',
      background: hover && onClick ? 'rgba(0,0,0,.04)' : 'transparent',
      borderBottom: last ? 'none' : '1px solid var(--separator)',
      ...style
    }
  }, leading || (icon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 20,
    color: iconColor || 'var(--label-2)'
  }) : null), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 17,
      color: destructive ? 'var(--destructive)' : 'var(--label-1)'
    }
  }, title), subtitle ? /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--label-2)',
      marginTop: 2
    }
  }, subtitle) : null), value ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 17,
      color: 'var(--label-2)'
    }
  }, value) : null, trailing, chevron ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-right",
    size: 16,
    color: "var(--label-3)"
  }) : null);
}
Object.assign(__ds_scope, { ListRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/lists/ListRow.jsx", error: String((e && e.message) || e) }); }

// components/lists/ListSection.jsx
try { (() => {
// iOS inset-grouped section: uppercase header, white card body, footer prose.
function ListSection({
  header,
  headerAccessory,
  footer,
  children,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-body)',
      margin: '0 16px 22px',
      ...style
    }
  }, header ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      fontSize: 13,
      color: 'var(--label-2)',
      textTransform: 'uppercase',
      letterSpacing: '.4px',
      padding: '0 16px 7px'
    }
  }, /*#__PURE__*/React.createElement("span", null, header), headerAccessory ? /*#__PURE__*/React.createElement("span", {
    style: {
      marginLeft: 'auto',
      textTransform: 'none'
    }
  }, headerAccessory) : null) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      background: 'var(--surface-card)',
      borderRadius: 10,
      overflow: 'hidden'
    }
  }, children), footer ? /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--label-2)',
      padding: '7px 16px 0',
      lineHeight: 1.35
    }
  }, footer) : null);
}
Object.assign(__ds_scope, { ListSection });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/lists/ListSection.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios-app/OnboardingScreen.jsx
try { (() => {
// Velkomstskjerm — OnboardingView.swift.
function OnboardingScreen({
  onDone
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      height: '100%',
      padding: 24,
      boxSizing: 'border-box',
      background: '#fff'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "leaf",
    size: 72,
    filled: true,
    color: "var(--accent)",
    strokeWidth: 1
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 28,
      fontWeight: 700,
      color: 'var(--label-1)',
      marginTop: 16
    }
  }, "Velkommen til iGarden")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 20,
      padding: '32px 8px'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.FeatureRow, {
    icon: "circle-plus",
    title: "Registrer plantene dine",
    text: "Navn, plassering, bilde og hvor ofte de skal vannes."
  }), /*#__PURE__*/React.createElement(__ds_scope.FeatureRow, {
    icon: "droplet",
    title: "Hold vanningen i rute",
    text: "Appen holder styr p\xE5 hvem som trenger vann, og varsler deg n\xE5r det er p\xE5 tide."
  }), /*#__PURE__*/React.createElement(__ds_scope.FeatureRow, {
    icon: "images",
    title: "F\xF8lg veksten",
    text: "Ta bilder underveis og se utviklingen p\xE5 tidslinjen."
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }), /*#__PURE__*/React.createElement(__ds_scope.Button, {
    size: "large",
    fullWidth: true,
    onClick: onDone
  }, "Kom i gang"));
}
Object.assign(__ds_scope, { OnboardingScreen });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios-app/OnboardingScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios-app/PhoneFrame.jsx
try { (() => {
// 390px iOS chrome: status bar + content + optional sheet overlay.
function StatusBar({
  light = false
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: 44,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 24px',
      fontFamily: 'var(--font-body)',
      fontSize: 15,
      fontWeight: 600,
      color: light ? '#fff' : 'var(--label-1)',
      flexShrink: 0
    }
  }, /*#__PURE__*/React.createElement("span", null, "09:41"), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      gap: 6,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement("svg", {
    width: "17",
    height: "11",
    viewBox: "0 0 17 11",
    fill: "currentColor"
  }, /*#__PURE__*/React.createElement("rect", {
    x: "0",
    y: "7",
    width: "3",
    height: "4",
    rx: "1"
  }), /*#__PURE__*/React.createElement("rect", {
    x: "4.5",
    y: "5",
    width: "3",
    height: "6",
    rx: "1"
  }), /*#__PURE__*/React.createElement("rect", {
    x: "9",
    y: "2.5",
    width: "3",
    height: "8.5",
    rx: "1"
  }), /*#__PURE__*/React.createElement("rect", {
    x: "13.5",
    y: "0",
    width: "3",
    height: "11",
    rx: "1"
  })), /*#__PURE__*/React.createElement("svg", {
    width: "24",
    height: "11",
    viewBox: "0 0 24 11"
  }, /*#__PURE__*/React.createElement("rect", {
    x: "0.5",
    y: "0.5",
    width: "20",
    height: "10",
    rx: "3",
    fill: "none",
    stroke: "currentColor",
    opacity: ".4"
  }), /*#__PURE__*/React.createElement("rect", {
    x: "2",
    y: "2",
    width: "17",
    height: "7",
    rx: "1.5",
    fill: "currentColor"
  }), /*#__PURE__*/React.createElement("path", {
    d: "M22 3.5v4c1-.4 1.5-1.2 1.5-2s-.5-1.6-1.5-2z",
    fill: "currentColor",
    opacity: ".4"
  }))));
}
function PhoneFrame({
  children,
  sheet,
  onDismissSheet
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width: 390,
      height: 800,
      background: 'var(--bg-grouped)',
      borderRadius: 40,
      overflow: 'hidden',
      position: 'relative',
      boxShadow: '0 24px 60px rgba(34,48,31,.25), 0 0 0 10px #1a1a1a',
      display: 'flex',
      flexDirection: 'column',
      fontFamily: 'var(--font-body)'
    }
  }, children, sheet ? /*#__PURE__*/React.createElement("div", {
    onClick: onDismissSheet,
    style: {
      position: 'absolute',
      inset: 0,
      background: 'rgba(0,0,0,.3)',
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'flex-end',
      zIndex: 20
    }
  }, /*#__PURE__*/React.createElement("div", {
    onClick: e => e.stopPropagation(),
    style: {
      background: 'var(--bg-grouped)',
      borderRadius: '14px 14px 0 0',
      height: '94%',
      overflow: 'hidden',
      display: 'flex',
      flexDirection: 'column',
      boxShadow: 'var(--shadow-sheet)',
      animation: 'sheetUp .25s var(--ease-out)'
    }
  }, sheet)) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      bottom: 8,
      left: '50%',
      transform: 'translateX(-50%)',
      width: 134,
      height: 5,
      borderRadius: 3,
      background: 'rgba(0,0,0,.85)',
      zIndex: 30
    }
  }));
}
// Sheet nav bar: cancel / title / confirm.
function SheetNav({
  title,
  leftLabel,
  onLeft,
  rightLabel,
  onRight,
  rightDisabled = false
}) {
  const b = {
    border: 'none',
    background: 'transparent',
    fontFamily: 'var(--font-body)',
    fontSize: 17,
    color: 'var(--accent)',
    cursor: 'pointer',
    padding: 0
  };
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      padding: '14px 16px',
      flexShrink: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, leftLabel ? /*#__PURE__*/React.createElement("button", {
    style: b,
    onClick: onLeft
  }, leftLabel) : null), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 17,
      fontWeight: 600,
      color: 'var(--label-1)'
    }
  }, title), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      textAlign: 'right'
    }
  }, rightLabel ? /*#__PURE__*/React.createElement("button", {
    style: {
      ...b,
      fontWeight: 600,
      opacity: rightDisabled ? .35 : 1
    },
    onClick: rightDisabled ? undefined : onRight
  }, rightLabel) : null));
}
Object.assign(__ds_scope, { StatusBar, PhoneFrame, SheetNav });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios-app/PhoneFrame.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios-app/PlantDetailScreen.jsx
try { (() => {
// Plantedetalj — PlantDetailView.swift: photo header, watering, facts, care history.
function PlantDetailScreen({
  plant,
  onBack,
  onWater,
  onEdit
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      height: '100%'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.StatusBar, null), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      padding: '4px 8px',
      flexShrink: 0
    }
  }, /*#__PURE__*/React.createElement("button", {
    onClick: onBack,
    style: {
      border: 'none',
      background: 'transparent',
      color: 'var(--accent)',
      fontSize: 17,
      fontFamily: 'var(--font-body)',
      display: 'flex',
      alignItems: 'center',
      gap: 2,
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-left",
    size: 22
  }), "Mine planter"), /*#__PURE__*/React.createElement("button", {
    onClick: onEdit,
    style: {
      border: 'none',
      background: 'transparent',
      color: 'var(--accent)',
      fontSize: 17,
      fontFamily: 'var(--font-body)',
      marginLeft: 'auto',
      cursor: 'pointer'
    }
  }, "Rediger")), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 34,
      fontWeight: 700,
      color: 'var(--label-1)',
      padding: '2px 16px 12px'
    }
  }, plant.name), /*#__PURE__*/React.createElement("div", {
    style: {
      margin: '0 16px 22px',
      borderRadius: 10,
      overflow: 'hidden',
      position: 'relative',
      height: 200,
      background: 'var(--fill-leaf)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "leaf",
    size: 56,
    color: "var(--fill-leaf-fg)",
    strokeWidth: 1.5
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      right: 10,
      bottom: 10
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.IconButton, {
    icon: "camera",
    filled: true,
    floating: true,
    label: "Legg til bilde"
  }))), /*#__PURE__*/React.createElement(__ds_scope.ListSection, {
    header: "Vanning"
  }, /*#__PURE__*/React.createElement(__ds_scope.WateringStatus, {
    status: plant.status,
    title: plant.statusTitle,
    caption: plant.lastWateredText
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      margin: '-12px 16px 22px'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Button, {
    size: "large",
    fullWidth: true,
    icon: "droplet",
    onClick: onWater
  }, "Vannet n\xE5")), /*#__PURE__*/React.createElement(__ds_scope.ListSection, {
    header: "Om planten"
  }, plant.species ? /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    title: "Art",
    value: plant.species
  }) : null, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    title: "Plassering",
    value: plant.location
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    title: "Anskaffet",
    value: plant.acquired
  }), plant.intervalDays ? /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    title: "Vanningsintervall",
    value: `Hver ${plant.intervalDays}. dag`
  }) : null, plant.waterNeed ? /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    icon: "droplet",
    title: "Vannbehov",
    value: plant.waterNeed
  }) : null, plant.lightNeed ? /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    icon: plant.lightIcon || 'cloud-sun',
    title: "Lysbehov",
    value: plant.lightNeed
  }) : null, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    title: "Jord (pH)",
    value: plant.ph || 'Ikke satt',
    last: !plant.soilFit
  }), plant.soilFit ? /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "badge-check",
      size: 20,
      filled: true,
      color: "var(--status-ok)"
    }),
    title: plant.soilFit,
    last: true
  }) : null), plant.notes ? /*#__PURE__*/React.createElement(__ds_scope.ListSection, {
    header: "Notater"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '12px 16px',
      fontSize: 17,
      color: 'var(--label-1)'
    }
  }, plant.notes)) : null, /*#__PURE__*/React.createElement(__ds_scope.ListSection, {
    header: "Stell-historikk",
    headerAccessory: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "circle-plus",
      size: 17,
      color: "var(--accent)"
    })
  }, plant.care.length === 0 ? /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '12px 16px',
      fontSize: 17,
      color: 'var(--label-2)'
    }
  }, "Ingen stell registrert enn\xE5") : plant.care.map((c, i) => /*#__PURE__*/React.createElement(__ds_scope.CareEventRow, {
    key: i,
    type: c.type,
    date: c.date,
    note: c.note,
    last: i === plant.care.length - 1
  })))));
}
Object.assign(__ds_scope, { PlantDetailScreen });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios-app/PlantDetailScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios-app/PlantFormScreen.jsx
try { (() => {
// «Ny plante» — PlantFormView.swift.
function PlantFormScreen({
  onCancel,
  onSave
}) {
  const [name, setName] = React.useState('');
  const [species, setSpecies] = React.useState('');
  const [schedule, setSchedule] = React.useState(true);
  const [days, setDays] = React.useState(7);
  const [notes, setNotes] = React.useState('');
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      height: '100%'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.SheetNav, {
    title: "Ny plante",
    leftLabel: "Avbryt",
    onLeft: onCancel,
    rightLabel: "Lagre",
    rightDisabled: !name.trim(),
    onRight: () => onSave(name.trim(), species.trim(), schedule ? days : null, notes.trim())
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      paddingTop: 8
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.ListSection, {
    header: "Om planten"
  }, /*#__PURE__*/React.createElement(__ds_scope.Input, {
    placeholder: "Navn",
    value: name,
    onChange: setName,
    style: {
      borderBottom: '1px solid var(--separator)'
    }
  }), /*#__PURE__*/React.createElement(__ds_scope.Input, {
    placeholder: "Art / latinsk navn",
    value: species,
    onChange: setSpecies,
    style: {
      borderBottom: '1px solid var(--separator)'
    }
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    title: "Plassering",
    value: "Stue",
    chevron: true,
    onClick: () => {}
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    title: "Anskaffet",
    value: "2. sep. 2026",
    last: true
  })), /*#__PURE__*/React.createElement(__ds_scope.ListSection, {
    header: "Vanning",
    footer: !schedule ? 'Uten vanningsplan får planten ingen påminnelser og vises ikke under «Trenger vann». Passer for uteplanter som klarer seg selv.' : null
  }, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    title: "Vanningsplan",
    trailing: /*#__PURE__*/React.createElement(__ds_scope.Switch, {
      checked: schedule,
      onChange: setSchedule
    }),
    last: !schedule
  }), schedule ? /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    title: `Hver ${days}. dag`,
    trailing: /*#__PURE__*/React.createElement(__ds_scope.Stepper, {
      value: days,
      onChange: setDays
    }),
    last: true
  }) : null), /*#__PURE__*/React.createElement(__ds_scope.ListSection, {
    header: "Vann og lys",
    footer: "Fylles inn automatisk for kjente planter n\xE5r du lagrer."
  }, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    title: "Vannbehov",
    value: "Ikke satt",
    chevron: true,
    onClick: () => {}
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    title: "Lysbehov",
    value: "Ikke satt",
    chevron: true,
    last: true,
    onClick: () => {}
  })), /*#__PURE__*/React.createElement(__ds_scope.ListSection, {
    header: "Jord (pH)",
    footer: "Brukes av Smart hage til \xE5 foresl\xE5 riktig bed. Fylles inn automatisk for kjente planter n\xE5r du lagrer."
  }, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    title: "Angi pH-preferanse manuelt",
    style: {
      color: 'var(--accent)'
    },
    last: true,
    onClick: () => {}
  })), /*#__PURE__*/React.createElement(__ds_scope.ListSection, {
    header: "Notater"
  }, /*#__PURE__*/React.createElement(__ds_scope.Input, {
    placeholder: "Notater",
    multiline: true,
    value: notes,
    onChange: setNotes,
    style: {
      minHeight: 80
    }
  }))));
}
Object.assign(__ds_scope, { PlantFormScreen });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios-app/PlantFormScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios-app/PlantListScreen.jsx
try { (() => {
// «Mine planter» — ContentView.swift: large title, toolbar, search, sections per location.
function PlantListScreen({
  plants,
  onOpenPlant,
  onAddPlant,
  onSmartGarden
}) {
  const [q, setQ] = React.useState('');
  const filtered = plants.filter(p => p.name.toLowerCase().includes(q.toLowerCase()) || (p.species || '').toLowerCase().includes(q.toLowerCase()));
  const groups = [...new Set(filtered.map(p => p.location))].sort((a, b) => a.localeCompare(b, 'no'));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      height: '100%'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.StatusBar, null), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'flex-end',
      gap: 2,
      padding: '0 10px'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.IconButton, {
    icon: "sparkles",
    label: "Smart hage",
    onClick: onSmartGarden
  }), /*#__PURE__*/React.createElement(__ds_scope.IconButton, {
    icon: "users",
    label: "Del hagen"
  }), /*#__PURE__*/React.createElement(__ds_scope.IconButton, {
    icon: "circle-user",
    label: "Konto"
  }), /*#__PURE__*/React.createElement(__ds_scope.IconButton, {
    icon: "bell",
    label: "Varsler"
  }), /*#__PURE__*/React.createElement(__ds_scope.IconButton, {
    icon: "arrow-up-down",
    label: "Sortering"
  }), /*#__PURE__*/React.createElement(__ds_scope.IconButton, {
    icon: "plus",
    label: "Legg til plante",
    onClick: onAddPlant
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '2px 16px 10px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 34,
      fontWeight: 700,
      color: 'var(--label-1)',
      marginBottom: 10
    }
  }, "Mine planter"), /*#__PURE__*/React.createElement(__ds_scope.SearchField, {
    placeholder: "S\xF8k p\xE5 navn eller art",
    value: q,
    onChange: setQ
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      paddingTop: 6
    }
  }, groups.map(loc => {
    const inLoc = filtered.filter(p => p.location === loc);
    return /*#__PURE__*/React.createElement(__ds_scope.ListSection, {
      key: loc,
      header: loc,
      headerAccessory: /*#__PURE__*/React.createElement("span", {
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: 8
        }
      }, inLoc.length, " ", /*#__PURE__*/React.createElement(__ds_scope.Icon, {
        name: "ellipsis",
        size: 15,
        color: "var(--accent)"
      }))
    }, inLoc.map((p, i) => /*#__PURE__*/React.createElement(__ds_scope.PlantRow, {
      key: p.id,
      name: p.name,
      location: p.location,
      status: p.status,
      statusText: p.statusText,
      needsWater: p.status === 'overdue' || p.status === 'due',
      hasSchedule: p.status !== 'none',
      last: i === inLoc.length - 1,
      onClick: () => onOpenPlant(p.id)
    })));
  }), filtered.length === 0 ? /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center',
      color: 'var(--label-2)',
      fontSize: 15,
      padding: 40
    }
  }, "Ingen treff for \xAB", q, "\xBB") : null));
}
Object.assign(__ds_scope, { PlantListScreen });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios-app/PlantListScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios-app/SmartGardenScreen.jsx
try { (() => {
const fmt = v => v.toFixed(1).replace('.', ',');
const soilCharacter = ph => ph < 5.5 ? 'sur jord' : ph < 6.5 ? 'svakt sur jord' : ph < 7.5 ? 'nøytral jord' : 'kalkrik jord';
// «Smart hage» — SmartGardenView.swift: soil pH per bed + move recommendations.
function SmartGardenScreen({
  onDone
}) {
  const [beds, setBeds] = React.useState([{
    name: 'Bed ved terrassen',
    ph: 5.2
  }, {
    name: 'Kjøkkenhagen',
    ph: 6.8
  }, {
    name: 'Bed langs gjerdet',
    ph: null
  }]);
  const setPh = (i, v) => setBeds(b => b.map((bed, j) => j === i ? {
    ...bed,
    ph: v
  } : bed));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      height: '100%'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.SheetNav, {
    title: "Smart hage",
    rightLabel: "Ferdig",
    onRight: onDone
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      paddingTop: 8
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.ListSection, {
    header: "Bed og jord",
    footer: "M\xE5l pH med en jordtester og juster verdien her. Uten pH kan ikke bedet vurderes."
  }, beds.map((bed, i) => /*#__PURE__*/React.createElement("div", {
    key: bed.name,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '10px 16px',
      borderBottom: i === beds.length - 1 ? 'none' : '1px solid var(--separator)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 17,
      color: 'var(--label-1)'
    }
  }, bed.name), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--label-2)',
      marginTop: 1
    }
  }, bed.ph ? `pH ${fmt(bed.ph)} · ${soilCharacter(bed.ph)}` : 'pH ikke målt')), /*#__PURE__*/React.createElement(__ds_scope.Stepper, {
    value: bed.ph ?? 6.5,
    min: 3.5,
    max: 9,
    step: 0.1,
    onChange: v => setPh(i, +v.toFixed(1))
  })))), /*#__PURE__*/React.createElement(__ds_scope.ListSection, {
    header: "Anbefalinger",
    footer: "2 planter trives der de st\xE5r."
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '12px 16px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "triangle-alert",
    size: 18,
    filled: true,
    color: "var(--status-due)"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 17,
      fontWeight: 600,
      color: 'var(--label-1)'
    }
  }, "Hortensia")), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 15,
      color: 'var(--label-2)',
      marginTop: 4
    }
  }, "Kj\xF8kkenhagen (pH 6,8) er for kalkrikt \u2013 planten vil ha pH 4,5\u20135,5."), /*#__PURE__*/React.createElement(__ds_scope.Button, {
    variant: "plain",
    icon: "arrow-right",
    style: {
      marginTop: 8
    }
  }, "Flytt til Bed ved terrassen (pH 5,2)")))));
}
Object.assign(__ds_scope, { SmartGardenScreen });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios-app/SmartGardenScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios-app/App.jsx
try { (() => {
const seedPlants = [{
  id: 1,
  name: 'Monstera',
  species: 'Monstera deliciosa',
  location: 'Stue',
  status: 'due',
  statusText: 'Vannes i dag',
  statusTitle: 'Vannes i dag',
  lastWateredText: 'Sist vannet for 7 dager siden',
  acquired: '14. mars 2025',
  intervalDays: 7,
  waterNeed: 'Middels',
  lightNeed: 'Halvskygge',
  lightIcon: 'cloud-sun',
  ph: '5,5–7,0',
  notes: 'Støttepinne byttet i vår.',
  care: [{
    type: 'watering',
    date: '26. aug. 2026'
  }, {
    type: 'fertilizing',
    date: '12. aug. 2026',
    note: 'Flytende gjødsel'
  }]
}, {
  id: 2,
  name: 'Fikentre',
  species: 'Ficus lyrata',
  location: 'Stue',
  status: 'overdue',
  statusText: 'Forfalt – skulle vannes i går',
  statusTitle: 'Trenger vann – forfalt',
  lastWateredText: 'Sist vannet for 9 dager siden',
  acquired: '2. juni 2025',
  intervalDays: 8,
  waterNeed: 'Middels',
  lightNeed: 'Full sol',
  lightIcon: 'sun',
  ph: '6,0–7,0',
  notes: '',
  care: [{
    type: 'watering',
    date: '24. aug. 2026'
  }]
}, {
  id: 3,
  name: 'Hortensia',
  species: 'Hydrangea macrophylla',
  location: 'Bed ved terrassen',
  status: 'ok',
  statusText: 'Vannes om 2 dager',
  statusTitle: 'Vannes om 2 dager',
  lastWateredText: 'Sist vannet for 2 dager siden',
  acquired: '5. mai 2026',
  intervalDays: 4,
  waterNeed: 'Mye',
  lightNeed: 'Halvskygge',
  lightIcon: 'cloud-sun',
  ph: '4,5–5,5',
  soilFit: 'Trives i jorden her (pH 5,2)',
  notes: '',
  care: [{
    type: 'watering',
    date: '31. aug. 2026'
  }, {
    type: 'pruning',
    date: '2. juli 2026',
    note: 'Visne blomster'
  }]
}, {
  id: 4,
  name: 'Lavendel',
  species: 'Lavandula angustifolia',
  location: 'Kjøkkenhagen',
  status: 'none',
  statusText: '',
  statusTitle: 'Ingen vanningsplan',
  lastWateredText: null,
  acquired: '20. apr. 2026',
  intervalDays: null,
  waterNeed: 'Lite',
  lightNeed: 'Full sol',
  lightIcon: 'sun',
  ph: '6,5–7,5',
  notes: 'Klarer seg selv ute.',
  care: []
}, {
  id: 5,
  name: 'Basilikum',
  species: 'Ocimum basilicum',
  location: 'Kjøkken',
  status: 'ok',
  statusText: 'Vannes i morgen',
  statusTitle: 'Vannes i morgen',
  lastWateredText: 'Sist vannet i går',
  acquired: '10. aug. 2026',
  intervalDays: 2,
  waterNeed: 'Mye',
  lightNeed: 'Full sol',
  lightIcon: 'sun',
  ph: '6,0–7,5',
  notes: '',
  care: [{
    type: 'watering',
    date: '1. sep. 2026'
  }]
}];
function App() {
  const [plants, setPlants] = React.useState(seedPlants);
  const [screen, setScreen] = React.useState('onboarding'); // onboarding | list | detail
  const [activeId, setActiveId] = React.useState(null);
  const [sheet, setSheet] = React.useState(null); // 'form' | 'smart' | null
  const active = plants.find(p => p.id === activeId);
  const water = () => setPlants(ps => ps.map(p => p.id === activeId ? {
    ...p,
    status: 'ok',
    statusText: `Vannes om ${p.intervalDays || 7} dager`,
    statusTitle: `Vannes om ${p.intervalDays || 7} dager`,
    lastWateredText: 'Sist vannet nå nettopp',
    care: [{
      type: 'watering',
      date: '2. sep. 2026'
    }, ...p.care]
  } : p));
  const addPlant = (name, species, intervalDays, notes) => {
    setPlants(ps => [...ps, {
      id: Date.now(),
      name,
      species: species || null,
      location: 'Stue',
      status: intervalDays ? 'never' : 'none',
      statusText: intervalDays ? 'Ikke vannet ennå' : '',
      statusTitle: intervalDays ? 'Ikke vannet ennå' : 'Ingen vanningsplan',
      lastWateredText: null,
      acquired: '2. sep. 2026',
      intervalDays,
      waterNeed: null,
      lightNeed: null,
      ph: null,
      notes,
      care: []
    }]);
    setSheet(null);
  };
  let content;
  if (screen === 'onboarding') content = /*#__PURE__*/React.createElement(__ds_scope.OnboardingScreen, {
    onDone: () => setScreen('list')
  });else if (screen === 'detail' && active) content = /*#__PURE__*/React.createElement(__ds_scope.PlantDetailScreen, {
    plant: active,
    onBack: () => setScreen('list'),
    onWater: water,
    onEdit: () => setSheet('form')
  });else content = /*#__PURE__*/React.createElement(__ds_scope.PlantListScreen, {
    plants: plants,
    onOpenPlant: id => {
      setActiveId(id);
      setScreen('detail');
    },
    onAddPlant: () => setSheet('form'),
    onSmartGarden: () => setSheet('smart')
  });
  return /*#__PURE__*/React.createElement(__ds_scope.PhoneFrame, {
    sheet: sheet === 'form' ? /*#__PURE__*/React.createElement(__ds_scope.PlantFormScreen, {
      onCancel: () => setSheet(null),
      onSave: addPlant
    }) : sheet === 'smart' ? /*#__PURE__*/React.createElement(__ds_scope.SmartGardenScreen, {
      onDone: () => setSheet(null)
    }) : null,
    onDismissSheet: () => setSheet(null)
  }, content);
}
Object.assign(__ds_scope, { App });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios-app/App.jsx", error: String((e && e.message) || e) }); }

__ds_ns.Badge = __ds_scope.Badge;

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Card = __ds_scope.Card;

__ds_ns.EmptyState = __ds_scope.EmptyState;

__ds_ns.Icon = __ds_scope.Icon;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.Input = __ds_scope.Input;

__ds_ns.SearchField = __ds_scope.SearchField;

__ds_ns.Stepper = __ds_scope.Stepper;

__ds_ns.Switch = __ds_scope.Switch;

__ds_ns.CareEventRow = __ds_scope.CareEventRow;

__ds_ns.FeatureRow = __ds_scope.FeatureRow;

__ds_ns.PlantThumb = __ds_scope.PlantThumb;

__ds_ns.PlantRow = __ds_scope.PlantRow;

__ds_ns.WateringStatus = __ds_scope.WateringStatus;

__ds_ns.ListRow = __ds_scope.ListRow;

__ds_ns.ListSection = __ds_scope.ListSection;

__ds_ns.App = __ds_scope.App;

__ds_ns.OnboardingScreen = __ds_scope.OnboardingScreen;

__ds_ns.StatusBar = __ds_scope.StatusBar;

__ds_ns.PhoneFrame = __ds_scope.PhoneFrame;

__ds_ns.SheetNav = __ds_scope.SheetNav;

__ds_ns.PlantDetailScreen = __ds_scope.PlantDetailScreen;

__ds_ns.PlantFormScreen = __ds_scope.PlantFormScreen;

__ds_ns.PlantListScreen = __ds_scope.PlantListScreen;

__ds_ns.SmartGardenScreen = __ds_scope.SmartGardenScreen;

})();
