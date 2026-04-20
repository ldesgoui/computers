#import "@preview/fontawesome:0.6.0": (
  fa-envelope, fa-github, fa-globe, fa-location-dot,
)

#set document(
  title: "Lucas Desgouilles - CV",
  author: "Lucas Desgouilles",
  description: "Développeur senior spécialisé en build engineering, à la recherche d'un poste à temps plein dès maintenant.",
)

#set page(
  margin: (top: 1.6cm, rest: 1.2cm),
  numbering: "1 sur 1",
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
        [#fa-location-dot() Habite en France],
        [#fa-envelope() #link("mailto:lucas@lde.sg")[lucas\@lde.sg]],
        [#fa-globe() https://lde.sg],
        [#fa-github() #link(
            "https://github.com/ldesgoui",
          )[ldesgoui sur GitHub]],
      ),
    )

    #set text(size: 10pt)
    #show emph: it => box(outset: 2pt, fill: luma(230), it)

    = Compétences

    == Développement
    - *Rust* #h(1fr) (6 ans)
    - _Python_ #h(1fr) (6 ans)
    - _Scripts Shell_ #h(1fr) (9+ ans)
    - *PostgreSQL* #h(1fr) (6 ans)
    - HTML + CSS #h(1fr) (9+ ans)
    - Javascript #h(1fr) (3 ans)
    - Haskell #h(1fr) (2 ans)
    - Elm #h(1fr) (1 an)
    - C / C++ #h(1fr) (2 ans)
    - Java / Kotlin #h(1fr) (1 an)
    - _Git_ #h(1fr) (9+ ans)
    - Processus RFC

    == DevOps
    - *Nix / NixOS* #h(1fr) (9+ ans)
    - Systèmes de build
    - _Pipelines CI/CD_
    - _GitOps_ #h(1fr) (3 ans)
    - _Kubernetes_ #h(1fr) (4 ans)
    - _Docker_ #h(1fr) (9+ ans)
    - _Administration Linux_
    - Cloud (AWS, GCE)
    - Prometheus / Grafana

    == Sécurité
    - Analyse de la chaîne d'approvisionnement logiciel
    - Renforcement sécurité Kubernetes
    - Rétro-ingénierie

    == Langues
    - Français #h(1fr) (Natif)
    - Anglais #h(1fr) (Courant)

    #line(length: 100%, stroke: 0.2pt)

    #text(size: 7.5pt)[
      Légende : *Maîtrisé* | _Pratiqué_ | Compétent
    ]
  ],
)[
  #text(size: 14pt, context document.description)
  #set strong(delta: 150)

  = Expérience

  #block(fill: luma(240), outset: (x: 8pt), inset: (y: 8pt), radius: 6pt)[
    #heading-with-location(
      [== Software Engineer II chez Kraken Futures],
      [À distance],
    )

    2nd Trimestre 2020 → 4ème Trimestre 2024

    Développement logiciel de systèmes distribués dans la fin-tech,
    utilisant Rust, Kotlin et Java, déployé sur Kubernetes.
    Mon grand intérêt pour le DevOps et la sécurité m'a conduit à adopter un rôle
    polyvalent, apportant mon soutien à mes collègues et prenant l'initiative
    d'améliorations dans les workflows de développement et de déploiement.
  ]

  - Implémenté des fonctionnalités pour *améliorer notre conformité*.
  - Maintenu plusieurs projets pour suivre de près les *correctifs de sécurité*.
  - Refondu les pipelines GitLab CI avec un système documenté et extensible,
    simplifiant les projets de l'équipe sans interruption.
    *Renforcement de la sécurité* en rénovant l'accès aux secrets et amélioration
    des performances de *jusqu'à 30 minutes* par pipeline sur des projets actifs.
  - Introduit Nix dans notre CI et services de développement pour organiser les dépendances externes.
    Déployé un cache de paquets Nix avec des pipelines proactives et de la compilation croisée
    pour *éliminer les problèmes de cache froid* sur tous les environnements,
    y compris les MacBooks des développeurs.
  - Rédigé et implémenté un RFC pour adopter le modèle GitOps dans Kubernetes,
    *améliorant la résilience* des opérations sur notre douzaine de projets
    et *autonomisant les développeurs* sans permissions.
  - Rédigé et implémenté un RFC pour migrer nos manifestes Kubernetes vers une
    solution sur mesure utilisant #link("https://nickel-lang.org")[Nickel], *améliorant considérablement
    la lisibilité et l'expérience de développement*.
  - Implémenté un environnement de développement pour faire tourner un cluster avec notre stack logicielle,
    souvent *sans intervention manuelle requise*. Le mode « live update » permettait d'exécuter des builds de débogage
    sans reprogrammer les conteneurs, *réduisant la boucle de développement de plus d'une minute*.
    Utilisé pour *simplifier* divers setups de tests end-to-end en CI.

  == Développeur Logiciel Freelance

  2016 → 2020

  - Développement web en Python, Javascript, Elm, Haskell.
  - Déploiement sur Linux (Debian, NixOS) et cloud (AWS, GCP).
]

#set page(
  margin: 1.2cm,
  columns: 2,
  header: align(right)[Lucas Desgouilles - CV],
)

= Formation

#v(4pt) // hack

#heading-with-location(
  [== #link("https://42.fr")[École 42]],
  [Paris, France],
)

2013 → 2016

- Sujets pertinents : Algorithmes et structures de données, Développement UNIX,
  Infographie, Développement web, Programmation orientée objet, Programmation fonctionnelle

= Projets personnels

== Contributeur au Logiciel Libre

2015 → Aujourd'hui

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

- Apporté des contributions à divers projets, tels que #nixpkgs, #postgrest, #specs, #dodrio.
- Auteur de la crate Rust #discord_game_sdk, fournissant une interface sûre et idiomatique
  à un SDK externe sans support officiel.

#block(fill: luma(240), outset: (x: 8pt), inset: (y: 8pt), radius: 6pt)[
  == Contributeur à un Esport Communautaire

  2016 → Aujourd'hui

  #link("https://teamfortress.com")[Team Fortress 2] est un jeu multijoueur déjanté
  développé par #link("https://www.valvesoftware.com")[VALV#super(baseline: -.26em)[E] Software]. \
  Il est joué en tournois 6 contre 6 depuis sa sortie.
]
- Développé un
  #link("https://github.com/ldesgoui/tf2-comp-fixes")[plugin du serveur] qui
  corrige des bugs et implémente des équilibrages de gameplay adaptés à la compétition.
- Déployé des serveurs de jeu lors de plusieurs tournois en réseau local, notamment à
  #link("https://liquipedia.net/teamfortress/Insomnia")[l'Insomnia Gaming Festival].
- Développé un #link("https://fantasy.tf2.spot")[site web de « fantasy manager »]
  fonctionnant en parallèle des tournois.

== Auto-hébergement, Homelab

- Gère une infrastructure à petite échelle pour mon usage personnel : DNS faisant autorité, e-mail,
  sites web, gestionnaire de mots de passe.
- Gère certains services pour mes amis : serveur vocal, serveur multimédia, chatbots Twitch/Discord.
- Déploie sur des machines reconditionnées dans un rack 19" à domicile.

#colbreak()

= Loisirs

- J'apprécie le cyclisme gravel et sur route, mais j'aime encore plus bricoler et assembler des vélos.
- Je découvre l'électronique en construisant des claviers ergonomiques.
