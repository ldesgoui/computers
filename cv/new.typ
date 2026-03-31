#import "@preview/fontawesome:0.6.0": (
  fa-envelope, fa-github, fa-globe, fa-location-dot,
)

#set document(
  title: "Lucas Desgouilles - CV",
  author: "Lucas Desgouilles",
  description: "Senior software developer specializing in build engineering looking for a full time position starting from now.",
)

#set page(
  margin: (top: 1.6cm, rest: 1.2cm),
  numbering: "1 of 1",
)

#set par(
  justify: true,
  leading: .9em,
)

#set text(font: "Fira Sans")

#let heading-with-location(heading, location) = {
  grid(
    columns: (1fr, auto),
    align: (horizon + left, horizon + right),
    heading, location,
  )
}

#show title: set align(center)
#show title: set text(size: 2em, font: "Hanken Grotesk")

#title[Lucas Desgouilles]

#grid(
  columns: (2fr, 5fr),
  gutter: .8cm,
  [
    #rect(
      width: 100%,
      inset: 1em,
      list(
        marker: none,
        [#fa-location-dot() Based in France],
        [#fa-envelope() #link("mailto:lucas@lde.sg")[lucas\@lde.sg]],
        [#fa-globe() https://lde.sg],
        [#fa-github() #link("https://github.com/ldesgoui")[ldesgoui on GitHub]],
      ),
    )

    #set text(size: 10pt)
    #show emph: it => box(outset: 2pt, fill: luma(230), it)

    = Skills

    == Development
    - *Rust* #h(1fr) (6 years)
    - _Python_ #h(1fr) (6 years)
    - _Shell scripting_ #h(1fr) (9+ years)
    - *PostgreSQL* #h(1fr) (6 years)
    - HTML + CSS #h(1fr) (9+ years)
    - Javascript #h(1fr) (3 years)
    - Haskell #h(1fr) (2 years)
    - Elm #h(1fr) (1 year)
    - C / C++ #h(1fr) (2 years)
    - Java / Kotlin #h(1fr) (1 year)
    - _Git_ #h(1fr) (9+ years)
    - RFC Process

    == DevOps
    - *Nix / NixOS* #h(1fr) (9+ years)
    - Build systems
    - _CI/CD Pipelines_
    - _GitOps_ #h(1fr) (3 years)
    - _Kubernetes_ #h(1fr) (4 years)
    - _Docker_ #h(1fr) (9+ years)
    - _Linux Administration_
    - Cloud (AWS, GCE)
    - Prometheus / Grafana

    == Security
    - Supply chain analysis
    - Kubernetes Hardening
    - Reverse engineering
    - Live binary hooking

    == Languages
    - French #h(1fr) (Native)
    - English #h(1fr) (Fluent)

    #line(length: 100%, stroke: 0.2pt)

    #text(size: 8pt)[
      Legend: *Proficient* | _Versed_ | Competent
    ]
  ],
)[
  #text(size: 14pt, context document.description)
  #set strong(delta: 150)

  = Experience

  #block(fill: luma(240), outset: (x: 8pt), inset: (y: 8pt), radius: 6pt)[
    #heading-with-location(
      [== Software Developer II at Kraken Futures],
      [Fully remote],
    )

    2020 Q2 → 2024 Q4

    Software development of distributed systems in Financial Technology,
    using Rust, Kotlin and Java, deployed on Kubernetes. \
    My keen interest in DevOps and Security led me to adopt a flexible role,
    providing support to my colleagues, as well as spearheading
    improvements in development and deployment workflows.
  ]

  - Implemented features on services to *improve our compliance standing*.
  - Helped maintain various services to stay on top of *security updates*.
  - Overhauled GitLab settings and CI pipelines with a documented and extensible
    system, streamlining the team's projects without disruption.
    *Tightened security* by revamping access to secrets and improved
    performance by *up to 30 minutes* per pipeline on active projects.
  - Introduced Nix in CI and development services to streamline external dependencies.
    Deployed a Nix binary cache with proactive build pipelines and cross-compilation
    to *eliminate cold-cache issues* on all environments, including developer Macbooks.
  - Wrote and implemented an RFC to adopt a GitOps deployment model in Kubernetes,
    *improving the resiliency* of operations on our dozen projects
    and *empowering developers* without cluster permissions.
  - Wrote and implemented an RFC to port all our Kubernetes manifests to a bespoke
    solution using #link("https://nickel-lang.org")[Nickel], *greatly improving
    the legibility and development experience* compared to status quo.
  - Implemented a development environment to locally run a cluster with our software stack,
    often with *no manual intervention required*. "Live update" mode allowed running
    debug builds without rescheduling containers, *shortening development loop by over a minute*.
    Used this to *streamline* various end-to-end testing setups in CI.

  == Freelance Software Developer

  2016 → 2020

  - Developed for the Web using Python, Javascript, Elm, Haskell.
  - Deployed on Linux (Debian, NixOS) and cloud infrastructure (AWS, GCP).
]

#set page(
  margin: 1.2cm,
  columns: 2,
  header: align(right)[ Lucas Desgouilles - CV ],
)

= Education

#v(4pt) // hack

#heading-with-location(
  [== #link("https://42.fr")[École 42]],
  [Paris, France],
)

2013 → 2016

- Relevant coursework: Algorithms and Data Structures, UNIX Development,
  Computer Graphics, Web Development, Object-Oriented Programming,
  Functional Programming

= Side projects

== Contributor to Free Software

2015 → Now

#let nixpkgs = link(
  "https://github.com/NixOS/nixpkgs/pulls?q=author%3Aldesgoui",
)[`nixpkgs`]
#let postgrest = link(
  "https://github.com/PostgREST/postgrest/pulls?q=author%3Aldesgoui",
)[`postgrest`]
#let specs = link(
  "https://github.com/amethyst/specs/pulls?q=author%3Aldesgoui",
)[`specs`]
#let dodrio = link(
  "https://github.com/fitzgen/dodrio/pulls?q=author%3Aldesgoui",
)[`dodrio`]
#let discord_game_sdk = link(
  "https://docs.rs/discord_game_sdk",
)[`discord_game_sdk`]

- Offered contributions to various projects, such as #nixpkgs, #postgrest, #specs, #dodrio.
- Authored Rust library #discord_game_sdk, providing a safe and idiomatic
  interface to an external library with no first-party support.

#block(fill: luma(240), outset: (x: 8pt), inset: (y: 8pt), radius: 6pt)[
  == Contributor to Grassroots Esports Scene

  2016 → Now

  #link("https://teamfortress.com")[Team Fortress 2] is a goofy multiplayer game
  developed by #link("https://www.valvesoftware.com")[VALV#super(baseline: -.26em)[E] Software].
  It has been played in a serious competitive 6v6 setting since its release.
]
- Developed a widely used
  #link("https://github.com/ldesgoui/tf2-comp-fixes")[server-side plugin] that
  implements fixes and gameplay balances catered towards competitive play.
- Deployed gameservers at multiple on-site (LAN) events, most notably at
  #link("https://liquipedia.net/teamfortress/Insomnia")[Insomnia Gaming Festival].
- Developed a #link("https://fantasy.tf2.spot")["fantasy manager" game website]
  that runs in parallel with tournaments.

== Self-hosting, Homelab

- Run small scale infrastructure for myself: Authoritative DNS, Email,
  Websites, Password manager.
- Run some services for my friends: Voice chat server, Media server,
  Twitch/Discord bots.
- Deploy on recycled machines in a 19" rack at home.

= Hobbies

- I enjoy casual gravel and road cycling, but I enjoy tinkering and assembling bicycles even more.
- I'm discovering electronics engineering by building ergonomic keyboards.
