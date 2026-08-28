# Architecture and product decisions

## Shape of the code

```
Persona/
├── Application/           App entry point
├── DesignSystem/          Tokens and primitives — see DESIGN_SYSTEM.md
├── Models/                The domain: a request, its risk, its payload, its stage
└── Features/Approval/
    ├── ApprovalScreen     Composition root: white page, scroll, two pinned bars
    ├── ApprovalFlowStore  The state machine and the simulated operations
    ├── Components/        The stage views and the two bars
    ├── Editing/           Change the thing before approving it
    └── Review/            The extra high-stakes look, with the held commit
```

No third-party dependencies, no networking, no persistence. Every value is
hard-coded in `ReservationProposal.sample` and `MessageProposal.sample`.

**One state machine.** Everything the screen can be is an `ApprovalStage`, and
every path between stages is a method on `ApprovalFlowStore` (`@Observable`,
`@MainActor`). Views own no flow state. That is what makes the awkward
transitions — cancel mid-flight, fail, retry, undo — cheap to reason about and
testable without a simulator.

**Operations are real Tasks.** `beginOperation` starts a cancellable
`Task` that sleeps. Cancel genuinely cancels it; the interface is not pretending.
A cancelled sleep returns without deciding an outcome, so the stage stays exactly
where `cancelOperation` put it.

**Strict concurrency.** Swift 6 language mode, `SWIFT_STRICT_CONCURRENCY=complete`,
`MainActor` default isolation. Models are `Sendable` value types.

## The design decisions

### Hierarchy: the title is the only loud thing
The request title sits on the bare page at the largest size on screen. Everything
that supports the decision — details, reasoning, evidence — is inside grouped
surfaces that are quieter by construction. "Move dinner to 8:00 PM" is legible in
about half a second, which is the bar the brief sets.

### Where the friction belongs
This is the question the brief asks directly, and the answer is *not* colour.

**Low stakes** — one tap on a button that names the change: `Move to 8:00 PM`.
Nothing else stands between the user and the outcome, because the cost of being
wrong is a phone call.

**High stakes** — approving does not send. It opens a review of the exact words,
where the commit gesture changes from a tap to a **held press**. A tap is one
accident away; a deliberate hold is not, and it gives the user a full second in
which letting go is free. Sliding a finger off the control aborts it too.

The design flexes without a second visual language. Same page, same surfaces,
same bar. What changes is the number of steps and the gesture that ends them.

### Risk is not colour-coded
A green "safe" badge and an orange "risky" one would let someone approve on
colour alone. Stakes are carried by wording, by the presence of a consequence
row, and by how much work the confirmation takes. See `ApprovalRisk`.

### The bar never leaves
Deciding, cancelling mid-flight and recovering afterwards all happen in the same
pinned bar at the bottom. Only its buttons are replaced. The eye never has to go
looking for the controls when the stage changes, and the bar can carry the
transition instead of the whole layout reflowing around it.

### Motion
Stages swap with `.blurReplace` and a slight scale — nothing moved anywhere, the
same subject resolved into a new state. Times use `.numericText()` so an edit
rolls the digits instead of swapping them. Nothing runs longer than ~0.45s and
everything is interruptible. Reduce Motion swaps every animation for a short
fade via `PersonaMetrics.motion(_:reduceMotion:)`; the perpetual rotation on the
activity ring is skipped entirely.

### The unglamorous states
All of them are built, and the first high-stakes send **fails on purpose**. A
failure that only happens sometimes is a failure that never gets designed.
Deterministic failure means the recovery path is real, tested, and demonstrable
in one take.

- **In progress** — Mira's mark becomes the activity indicator; Cancel is in the
  bar for the full 2.2s. It is a phone call being placed, so it is allowed to
  take a moment.
- **Failed** — names what did not happen ("Daniel heard nothing"), offers Edit
  and Try again, and says plainly that retrying is safe.
- **Undo** — prominent enough to find, secondary to "Done", with the window
  stated underneath. Making the loudest button on a screen that just worked say
  *undo* reads as the app second-guessing itself.
- **Declined** — treated as a preference, not an error. "Ask me again" returns.

### Editing never approves
Both editors return to `.awaiting` on save, and both say so on screen. Changing
the thing is not the same as agreeing to it.

## Accessibility

- Dynamic Type throughout, including the accessibility sizes: the decision bar
  restacks to a full-width primary with the secondaries below it, because
  "Move to 8:00 PM" at AX-Large is wider than an iPhone.
- `HoldToConfirmButton` exposes itself to assistive technology as a plain button
  via `accessibilityRepresentation`. A timed hold is not something VoiceOver or
  Switch Control should have to reproduce.
- Voice Control: `accessibilityInputLabels` accepts the spoken alternatives
  ("Decline", "No", "Yes") alongside the visible labels.
- Reduce Motion honoured everywhere.
- Semantic system colours throughout, so contrast and vibrancy settings work.
  The app is light-locked for the demo; that is one line in `ApprovalScreen`.
- Sensory feedback is semantic: `.success` on completion, `.error` on failure,
  a light impact when a hold begins.

## Tests

8 unit tests over the state machine and the risk rules, 7 UI tests covering
every state in the recording — including cancelling mid-flight, the scripted
failure, the retry, and the fact that saving an edit does not approve anything.

```
xcodebuild test -project Persona.xcodeproj -scheme Persona \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```
