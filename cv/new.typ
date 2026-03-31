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

#set text(font: "Fira Sans", size: 10pt)

#let heading-with-location(heading, location) = {
  block(
    width: 100%,
    inset: (top: 7pt),
    grid(
      columns: (auto, 1fr),
      align: (horizon + left, horizon + right),
      heading, location,
    ),
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

    #show emph: it => box(fill: luma(230), it)

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

    #text(size: 0.75em)[
      Legend: *Proficient* | _Versed_ | Competent
    ]

  ],
)[
  #text(size: 1.2em, context document.description)

  = Experience

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

  - Developed and deployed an active monitoring service to ensure the integrity
    of a cached view of financial transactions, consumed by downstream services.
    Implemented four-eyes principle on existing administrative APIs.
    Helped maintain various small services with regards to dependency security updates.
  - Overhauled GitLab settings and CI pipelines with a documented and extensible
    system, streamlining the team's projects all at once without disruption. \
    Tightened security by revamping access to secrets and improved
    performance by up to 30 minutes per pipeline on active projects.
  - Developed a Nix package set for use in various workflows: CI, dev services,
    and local development environment. Deployed a Nix binary cache with proactive
    build pipelines eliminating cold-cache issues.
    Set up cross-compilation to support developers using Macbooks with aarch64 CPUs.
  - Wrote and implemented an RFC to migrate the Kubernetes resources of our dozen
    projects to a GitOps deployment system with ArgoCD.
    Streamlined the deployment of secrets using SealedSecrets.
    This improved the resiliency of our deployments
    and empowered developers without cluster permissions.
  - Wrote and implemented an RFC to port all our Kubernetes manifests to a bespoke
    solution using #link("https://nickel-lang.org")[Nickel], greatly improving
    the legibility and development experience compared to status quo.
  - Developed a fully automated development environment using Nix, Tilt and k3d,
    allowing all developers to run a copy of our software stack with as little as
    Docker and Nix installed, and often no manual intervention.
    Implemented "live update" to push and run debug builds into the cluster without
    rescheduling, shortening the development loop by over a minute. \
    Used it to streamline the various inconsistent End-To-End test setups.

  == Freelance Software Developer

  2016 → 2020

  - Developed for the Web using Python, Javascript, Elm, Haskell.
  - Deployed on Linux and cloud infrastructure (AWS, GCP).

]

#set page(margin: 1.2cm, columns: 2, header: context {
  if counter(page).get().first() > 1 {
    align(right)[
      Lucas Desgouilles - CV
    ]
  }
})

= Education

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

== Contributor to Grassroots Esports Scene

2016 → Now

#link("https://teamfortress.com")[Team Fortress 2] is a goofy multiplayer game
developed by #link("https://www.valvesoftware.com")[VALV#super(baseline: -.26em)[E] Software].
It has been played in a serious competitive 6v6 setting since its release.
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
