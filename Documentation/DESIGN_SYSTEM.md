# Design system

Three token files, an elevation model, and a set of primitives. If you are
changing how this app looks, you should be editing a token, not a view.

```
Persona/DesignSystem/
├── PersonaPalette.swift      colour, tints and gradients
├── PersonaMetrics.swift      spacing, radii, layout, motion
├── PersonaTypography.swift   type roles, as view modifiers
├── PersonaElevation.swift    the two-part shadow, and the coloured glow
├── PersonaSurface.swift      cards, tinted blocks, chips, tiles, rows
├── PersonaControls.swift     buttons, the segmented control, hold-to-confirm
├── PersonaMark.swift         Mira's identity
├── PersonaAura.swift         the glow behind the header
└── ProgressiveBlurEdge.swift the blur behind the pinned bars
```

## The six rules everything follows

**1. Indigo is Persona. Nothing else may use it.**
`PersonaPalette.brand` carries the primary action, the active segment, the mark,
and the wash behind Mira's own reasoning. When indigo appears, Persona is the one
talking. Everything else on screen gets a hue that belongs to its subject — the
restaurant tile is amber, the recipient avatar is derived from their name, the
draft bubble is quoted from Messages.

**2. No neutral greys.**
Every surface has a trace of the brand hue in it: the page is `#FBFBFE`, not
white; cards are pure white *on top of* that page so they actually read as
lifted; the default block tint is `#F6F6FC`. A grey card on a white page is the
single fastest way to make an interface look unfinished rather than restrained.

**3. Depth is two shadows, and it is never black.**
`personaElevation()` casts a tight contact shadow plus a wide ambient one, both
in the ink navy. `personaGlow(_:)` makes a coloured object cast light in its own
hue — that is why the primary button glows indigo instead of sitting on a grey
smudge. One blurred black blob is the giveaway of an interface nobody looked at
twice.

**4. Colour means outcome. Never risk.**
Green is "it worked", red is "it did not", amber marks the single caution row.
Stakes are **not** colour-coded: a green "safe" badge next to an orange "risky"
one teaches people to approve on colour alone, which is the reflex this screen
exists to prevent. The stakes chip changes its *glyph* and its meaning ("this
touches a person"), and high stakes change how much work the confirmation takes.

**5. One level of nesting.**
`PersonaCard` holds rows separated by `PersonaDivider`. A card never contains
another card. A rule inside a tinted block is tinted too — a neutral grey line on
a lavender wash reads as a mistake.

**6. Gradients are for objects, not for pages.**
Buttons, the mark, the active segment and the emblem discs are gradient-filled,
because a gradient makes an object look lit. The *page* is not: `PersonaAura` is
one soft glow bleeding off the top edge, and if you can point at it and call it a
gradient it is too strong. A full-bleed mesh puts colour under every element,
muddies text, and leaves the progressive blur nothing legible to work with.

## Tokens

### Spacing — `PersonaMetrics`
A strict 4pt scale, named by what the gap is *for*, not by its size:
`spaceHairline` (symbol to word) · `spaceTight` (two lines of one thought) ·
`spaceSnug` (siblings in a row) · `spaceRegular` (inside a surface) ·
`spaceMargin` (screen edge) · `spaceSection` (between blocks) ·
`spaceHeadline` · `spaceGenerous` (around a lone element).

Use the name that describes the relationship. If none fits, the layout is
probably wrong before the token is.

### Radii
`radiusSmall` (14) · `radiusSurface` (22) · `radiusHero` (28), always with
`style: .continuous` so corners match iOS squircle curvature. A plain
`cornerRadius` is visibly wrong next to system chrome, and tight corners read as
utilitarian.

### Colour
Brand: `brand` · `brandDeep` · `brandLight` · `brandTint`, plus `brandGradient`
and `markGradient`.
Surfaces: `canvas` (the page) · `surfaceRaised` (cards) · `surface` (inset
blocks) · `border` / `borderStrong`.
Text: `ink` (deep navy — pure black on white is harsh and reads cheap) ·
`inkSecondary` · `inkTertiary`.
Semantic: `positive` · `negative` · `caution`, each with a matching `…Tint` for
the wash it sits on.

### Type — `PersonaTypography`
Roles, not sizes: `personaHeroTitle()` (one per screen, the half-second read),
`personaOutcomeTitle()`, `personaSubtitle()`, `personaRowLabel()`,
`personaRowValue()`, `personaFigure(isEmphasised:)`.

Every role is built on a system text style, so Dynamic Type and Bold Text keep
working. The one thing added on top is **negative tracking at display sizes**
(-1.0 on the hero, -0.7 on outcomes). Large type at default tracking looks loose;
tightening it is most of what separates a designed headline from a default one.

### Motion — `PersonaMetrics.Motion`
Three roles: `.stage` (one state replacing another), `.control` (a button
answering a touch), `.value` (a number changing in place). Read them through
`PersonaMetrics.motion(_:reduceMotion:)`, which substitutes a short fade when
Reduce Motion is on. Nothing runs longer than ~0.45s and every spring is
interruptible.

## Primitives

| Type | Use it for |
| --- | --- |
| `PersonaCard` | A group of rows, lifted off the page. The default container. |
| `PersonaTintedBlock` | Content that belongs to something. Tint carries the meaning, so no border and no shadow. |
| `PersonaDivider` | The hairline between two rows. Pass a tint when inside a tinted block. |
| `PersonaChip` | A small tinted pill: the eyebrow, a delta, a status. |
| `SymbolTile` | A symbol on a tinted tile. The subject of a card, never decoration. |
| `ContactAvatar` | A monogram circle, coloured from the name so one person is always one colour. |
| `PersonaStatementRow` | A coloured label with a paragraph under it. |
| `PersonaValueRow` | Settings-style label left, value right. |
| `PersonaCautionRow` | The one warning. High stakes only. |
| `PersonaSegmentedControl` | Options where the active pill slides via `matchedGeometryEffect`. |
| `PersonaCommitButton` | A sheet's full-width confirm. |
| `HoldToConfirmButton` | A commit that should not be reachable by a tap. |

### Buttons
`personaPrimaryAction()` — gradient capsule with an indigo glow and a bright
inner top edge. Exactly one per screen.
`personaSecondaryAction()` — solid white, `borderStrong`, card elevation.
`personaIconAction()` — the circular icon-only sibling.

Note that the secondary controls are **solid white, not Liquid Glass**. Glass is
the right material over busy content; over a near-white page it has nothing to
refract and just reads as a washed-out smudge. The page has to earn glass, and
this one does not.

## Two things worth reading the source for

### `ProgressiveBlurEdge`
There is no public variable-radius blur in SwiftUI. This builds one by stacking
backdrop-sampling materials, each masked to a band that reaches further than the
one beneath it, so blur compounds toward the bar and vanishes by the end of the
ramp. A wash of page colour over the same ramp cancels the grey cast that
stacked materials leave on white — and is also what the effect *should* look
like: content absorbed into the page rather than hidden behind a panel.

The popular open-source variable blurs use the private `CAFilter` API. This one
does not, which matters for something being submitted for review.

iOS 26's own `scrollEdgeEffectStyle(.soft, …)` stays switched on underneath. It
is tuned for a standard navigation bar; this app pins a taller two-storey
header, so the ramp needs more distance than the system default gives it.

Tune it with two numbers: `scrollEdgeRamp` (how long the transition is) and
`scrollEdgeOverhang` (how far it continues past the bar). The scroll view adds
the overhang back as content padding, so nothing rests inside the fade.

### `PersonaMark`
Mira is drawn as a monogram on a lit indigo sphere, not as an AI badge. No
rainbow ring, no `sparkles` glyph — those read as "a robot made this", which is
the opposite of what the product claims.

Four layers, in this order, are what make it an object rather than a coloured
circle: a diagonal brand gradient, a specular highlight offset toward the light,
a bright rim along the lit edge, and — the one most often left out — a shadow
cast in its own indigo instead of in black. When Persona is working, a progress
ring wraps it, so the identity carries the activity and no foreign spinner has to
appear beside it.

Everything scales from `size`. It reads correctly at 38pt in the header and at
84pt on the progress screen.
