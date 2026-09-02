# iGarden Design System

iGarden er en norskspråklig iOS-app (SwiftUI) for alt du trenger å vite og loggføre rundt plantene i hagen og hjemmet: registrer planter med navn, art, plassering og bilde; hold vanningen i rute med vanningsplaner og varsler; loggfør stell (vanning, gjødsling, ompotting, beskjæring); følg veksten med en fototidslinje; del hagen med andre via invitasjonskoder; og bruk «Smart hage» til å måle jord-pH per bed og få anbefalinger om hvor plantene trives best.

**Source:** https://github.com/aslekinnerod/iGarden (SwiftUI + Firebase). Explore the repo for ground truth — all UI is plain SwiftUI (`List`, `Form`, `.borderedProminent`, SF Symbols), Norwegian copy throughout. Key files: `ContentView.swift` (plant list), `PlantDetailView.swift`, `PlantFormView.swift`, `SmartGardenView.swift`, `OnboardingView.swift`, `Models.swift`.

## Products
One product: the **iGarden iOS app**. No website, no marketing surfaces exist in the source. This design system recreates the app faithfully and extends the brand with a "natural" layer (naturals palette, display serif) for slides/marketing use — clearly marked as extension.

## CONTENT FUNDAMENTALS
- **Language:** Norwegian bokmål, always. Friendly, practical, quietly encouraging.
- **Person:** direct «du»-form. The app is a helper: "Legg til plantene dine, så hjelper iGarden deg å holde dem i live."
- **Casing:** sentence case everywhere — titles, buttons, sections ("Registrer stell", "Trenger vann", "Kom i gang"). Never Title Case, never ALL CAPS.
- **Quotes:** norske «guillemets» («Trenger vann», «Smart hage»).
- **Dates:** relative and human ("Vannes i dag", "Sist vannet for 3 dager siden", "Forfalt – skulle vannes i går").
- **Punctuation:** en-dash with spaces for asides ("Trenger vann – forfalt"); middots (·) as inline separators ("Stue · Vannes i dag").
- **Numbers in copy:** "Hver 7. dag", "pH 5,5–6,5" (decimal comma, en-dash range).
- **Emoji:** never in UI copy. The app icon's 3D potted plant is the only illustrative element.
- **Footers explain consequences** in calm prose: "Uten vanningsplan får planten ingen påminnelser … Passer for uteplanter som klarer seg selv."
- **Errors:** generic + apologetic-free: "Noe gikk galt", single OK button.
- **Confirmations** ask a question: "Vanne alle 4 plantene i Stue?" / "Dette kan ikke angres."

## VISUAL FOUNDATIONS
- **Color:** accent green `#2E7D32` (`--accent`, from AccentColor.colorset). Watering status traffic light: red `#FF3B30` overdue, orange `#FF9500` due today/never watered, green `#34C759` ok, secondary for no schedule. Water actions are iOS blue `#007AFF`. Leaf-tint placeholder fill: green at 12 % opacity, glyph at 50 %. Extension naturals (from app icon): terracotta `#C97B4A`, soil `#5C4433`, sage `#A9C4A0`, mist `#D7EAD1`, paper `#FAF8F2`.
- **Type:** iOS system font (SF Pro) at Dynamic Type sizes (body 17, headline 17/semibold, caption 12…). Web substitution: **Figtree** for UI/body, **Young Serif** for brand display (marketing/slides only — the app itself never uses a serif). No font binaries exist in the repo; loaded from Google Fonts.
- **Backgrounds:** flat iOS grouped background `#F2F2F7` with white cards. No gradients in-app; the app icon's soft green vertical gradient (`#D7EAD1→#B7D9AE`) is the only brand gradient — usable full-bleed on slides.
- **Spacing:** iOS defaults — 16px list insets, 10px row gaps, 44px hit targets, generous 24px sheet padding.
- **Radii:** 8px thumbnails/auth buttons, 10px photos/cards, 12px prominent buttons, circles for floating photo actions.
- **Shadows/borders:** essentially none — flat grouped lists with hairline separators `rgba(60,60,67,.29)`. Floating controls sit on `.thinMaterial` blur circles.
- **Animation:** iOS defaults only — sheet slides, `withAnimation` on toggle reveals. Ease-out, ~250ms. No bounces, no custom springs.
- **Press states:** iOS content dim (~55 % opacity). Hover (web): 4 % black wash on rows, slight darken on buttons.
- **Imagery:** users' own plant photos — warm, natural light, cropped to rounded rects (8/10px). Placeholder = leaf glyph on 12 % green tint.
- **Transparency/blur:** only `.thinMaterial` on floating photo buttons over imagery.

## ICONOGRAPHY
The app uses **SF Symbols exclusively** — outline style, filled variants for status (`drop.fill`, `leaf.fill`, `checkmark.seal.fill`, `exclamationmark.triangle.fill`). SF Symbols can't ship on web, so this system substitutes **Lucide** (CDN `https://unpkg.com/lucide@0.462.0`) — closest match in stroke weight and style. Mapping in `components/core/Icon.prompt.md`. **Flagged substitution** — see caveats. No icon font, no PNG icons, no emoji, no custom SVGs in the source. The only bitmap asset is `assets/app-icon.png` (3D potted plant on green gradient).
**No logo/wordmark exists** in the repo. Render "iGarden" in plain type (Young Serif for brand contexts, semibold Figtree in-app) wherever a mark would go.

## Intentional additions
- `Icon` wrapper (Lucide) — glyph substitute for SF Symbols.
- Naturals palette + Young Serif display — brand extension for non-app surfaces, per the brief ("naturlige utforminger").

## Index
- `styles.css` → `tokens/` (colors, typography, spacing, effects)
- `assets/app-icon.png` — the only source visual asset
- `guidelines/` — foundation specimen cards (Design System tab)
- `components/core/` — Button, IconButton, Badge, Card, EmptyState, Icon
- `components/forms/` — Input, SearchField, Switch, Stepper
- `components/lists/` — ListSection, ListRow
- `components/garden/` — PlantRow, CareEventRow, WateringStatus, FeatureRow
- `ui_kits/ios-app/` — interactive recreation: plant list, detail, form, Smart hage, onboarding
- `SKILL.md` — agent skill entry point

## Caveats
- Fonts: SF Pro → Figtree/Young Serif substitution (no binaries in repo).
- Icons: SF Symbols → Lucide substitution.
- Component inventory derived from the SwiftUI app's actual patterns (no web component library exists in the source).