#import "@preview/polylux:0.3.1": *
#import "./go-theme.typ": *

// compile .pdfpc wth `polylux2pdfpc {fname}.typ`
// then present with, e.g., `pdfpc --windowed both {fname}.pdf`

// uncomment to get a "submittable" PDF
// #enable-handout-mode(true)

#let kthblue = rgb("#000060")
#show: clean-theme.with(
  short-title: [*DD2482 DevOps |* Continuous Information Flow Control],
  color: kthblue,
  logo: image("assets/KTH_logo_RGB_bla.svg"),
)

#pdfpc.config(duration-minutes: 7)

// consistent formatting + make typstfmt play nice
#let notes(
  speaker: "???",
  ..bullets,
) = pdfpc.speaker-note("## " + speaker + "\n\n" + bullets.pos().map(x => "- " + x).join("\n"))

// #show link: it => underline(stroke: 1pt + kthblue, text(fill: kthblue, it))

#let focus = it => text(kthblue, strong(it))

#let cover = title-slide(
  title: [Continuous Information Flow Control],
  subtitle: [
    *DD2482 Automated Software Testing & DevOps*

    #smallcaps[KTH Royal Institute of Technology]

    #text(go-yellow)[*Wednesday, October 2#super[nd], 2024*]

    #notes(
      speaker: "Diogo",
      "Introduce group members",
      "Topic very relevant in DevSecOps",
    )
  ],
  authors: (
    [*Diogo Correia*\
      #link("mailto:diogotc@kth.se")],
    [*Rafael Oliveira*\
      #link("mailto:rmfseo@kth.se")],
  ),
)

#cover

#outline-slide(title: "Outline")[
  #side-by-side(columns: (1.5fr, 1fr))[
    #show link: it => [*#it*]
    #utils.polylux-outline()
  ][
    #set image(height: 60%)
    #scale(x: -100%, image("assets/gopher-toc.svg"))
  ]

  #notes(speaker: "Diogo", "Really fast")
]

#new-section-slide("Information Flow Control")

#slide(title: "The Problem")[
  ```go
  state := { nOptions: 3, timeout: 400, /* ... */ }

  func handleX(param int, state State) Response;
  func handleY(name string, state State) Response;
  ```

  #pause

  #line(length: 50%, stroke: go-fuchsia)

  ```go
  client <- state
  ```

  #pause

  #line(length: 50%, stroke: go-fuchsia)

  ```go
  state := { nOptions: 3, /* ... */, s3Key: "SP@0N_1s_b3$t..." }
  ```

  #notes(speaker: "Raf", "10 years later")
]

#slide(title: "What is IFC?")[
  - Security technique to uphold invariants

  - Ensure data transfers don't violate some security policy

  - Usually, focus on *confidentiality*

  - *Noninterference:* public outputs only depend on public inputs

  - Static analysis >> dynamic monitoring

  #notes(
    speaker: "Raf",
    "Usually, purpose is to detect and prevent secrets from being exfiltrated into untrusted contexts",
    "Public here means anything observable by an attacker",
    "Static incurs no costs on runtime performance",
  )
]

#new-section-slide("Example Implementation: Glowy")

#slide(title: "Glowy")[
  - Static analyzer employing IFC techniques to assess Go programs

  - Written in Rust #box(image("assets/rustacean-flat-happy.svg", height: 1em), baseline: 7pt) from scratch, including (spec-compliant) Go lexer/parser

  - Information categorized with *labels*
    - e.g., ${"high"}$ or ${"nuclear", "pentagon", "navy"}$
    - Accumulate over time

  #place(bottom + right, dy: 60pt, image("./assets/gopher-idea.svg", height: 70%))

  #notes(speaker: "Diogo")
]

#slide(title: "Tracking Lifetime & Code Annotations")[
  #set text(0.9em)

  #side-by-side[

    - *Sources:* artificial points of origin

      #raw(
        lang: "go",
        "// glowy::label::{secret}\nconst hmacSecret = 0x4D757342",
      )

      #pause
    - *Sinks:* end-state for information

      #raw(lang: "go", "// glowy::sink::{}\nfmt.Println(output)")

      *Insecure flow if $ell_E lt.eq.not ell_S$*

      #pause
  ][
    - *Declassification:* always explicit

      #{
        set block(stroke: ("left": 4pt + red), inset: ("left": 1em, "y": 5pt))
        raw(
          lang: "go",
          "// glowy::label::{alice}\nvar a int = 3\n// glowy::label::{bob}\nb := 4 * a // {alice, bob}",
          block: true,
        )
      }

      #{
        set block(stroke: ("left": 4pt + blue), inset: ("left": 1em, "y": 5pt))
        raw(
          lang: "go",
          "// glowy::declassify::{}\nhash := sha256(secret)",
          block: true,
        )
      }
  ]

  #notes(
    speaker: "Diogo",
    "Explicit declassification creates very identifiable points in the code that need to be looked at very carefully",
  )
]

#slide(title: "Taint Analysis")[
  #set text(0.9em)

  #side-by-side[
    - *Explicit Flows*

      #raw(
        lang: "go",
        "// glowy::label::{alice}\na := 3\n// glowy::label::{bob}\nb := 7\n\na += 9 + 2 * b\n// ^ final label {alice, bob}",
      )

    #pause
  ][
    - *Implicit Flows*

      #raw(
        lang: "go",
        "// glowy::label::{charlie}\nc := 98\n\nout := true // label {}\nif c % 10 == 0 {\n\tout = false\n\t// ^ new label {charlie}\n}",
      )
  ]

  #notes(speaker: "Raf")
]

#slide(title: "Example Output")[
  #grid(
    columns: (auto, auto),
    column-gutter: 1em,
    [
      #set text(size: 15pt)
      #raw(lang: "go", read("assets/opaque.go"))
    ],
    image("assets/opaque.png", height: 85%),
  )

  #notes(speaker: "Diogo", "Read output bottom-up")
]

#focus-slide(background: go-fuchsia)[
  = Biggest drawback?

  #pause

  _Maintaining all those damn labels!_

  #pause

  #set align(end)
  #set text(fill: yellow)
  #smallcaps[_*Solution?*_]

  #notes(speaker: "Raf")
]

#new-section-slide("Continuous IFC")

#slide(title: "Continuous IFC")[
  - Each commit, worry only about _that_ commit's span

  - Each commit, *enforce* that invariant is held

  - Each commit, fix security vulnerabilities before they're ever a problem

  #v(1fr)

  #set text(fill: kthblue)
  *Integrate IFC into CI pipeline!*

  #v(1fr)

  #place(bottom + right, dx: -100pt, dy: 40pt, image("./assets/gopher-rocket.svg", height: 65%))

  #notes(speaker: "Raf")
]

#slide(title: "Continuous Enforcement")[
  - GitHub workflow: require check in PR before merging

  #only(1, image("assets/pr.png"))

  #pause

  - Git pre-commit hook: local enforcement at commit level

  #only(2, image("assets/hook.png"))

  #pause

  - IDE integration: real-time linting with immediate feedback

  #only(3, image("assets/ide.png"))

  #notes(
    speaker: "Diogo",
    "Glowy is written in Rust and has very good performance (fraction of a second), so it won't affect your productivity",
  )
]

#new-section-slide("Conclusion")

#slide(title: "Take-Home Message")[
  #set align(center)

  "Continuous IFC: low-effort security assurances"

  #image("assets/infinity.png", height: 65%)

  #place(
    bottom,
    dx: 280pt,
    polygon.regular(
      fill: go-fuchsia,
      size: 30pt,
      vertices: 3,
    ),
  )

  #v(1fr)

  #set text(size: .7em, fill: gray)
  #set align(end)
  Image source: Octopus Deploy

  #notes(speaker: "Diogo", "Our topic is at the heart of DevSecOps")
]

#cover
