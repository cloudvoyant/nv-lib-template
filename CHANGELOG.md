## [1.10.1](https://github.com/cloudvoyant/nv-lib-template/compare/v1.10.0...v1.10.1) (2025-11-01)

### Bug Fixes

* keep .claude directory visible and document search limitation ([815aabd](https://github.com/cloudvoyant/nv-lib-template/commit/815aabd490cecd54c2d00c242fc1abc71e3c89b4))

## [1.10.0](https://github.com/cloudvoyant/nv-lib-template/compare/v1.9.1...v1.10.0) (2025-11-01)

### Features

- add Docker and docker-compose support with multi-stage builds ([46c7aed](https://github.com/cloudvoyant/nv-lib-template/commit/46c7aedd5b1076c50f3c584ac6b8a0464452c62e))
- add VS Code file visibility toggle commands ([0146f50](https://github.com/cloudvoyant/nv-lib-template/commit/0146f504c0d05606e97a4d79653feec46b713d1f))
- enhance changelog generation and publishing ([46c796a](https://github.com/cloudvoyant/nv-lib-template/commit/46c796a30452cb1cb2d8389b10fc3d0489b5440c))

### Bug Fixes

- add missing conventionalcommits changelog dependency ([a0f2841](https://github.com/cloudvoyant/nv-lib-template/commit/a0f28414afa9775b83e1ad9cd723542959433077))

### Documentation

- add section on viewing hidden files in VS Code ([9dfc104](https://github.com/cloudvoyant/nv-lib-template/commit/9dfc104aa247c2727eacab0ca7af7e454707eb9b))
- improve architecture.md consistency and add review command ([7426f30](https://github.com/cloudvoyant/nv-lib-template/commit/7426f3035ca10b961380244fc190bb53fd497597))
- improve commit command workflow instructions ([069bea7](https://github.com/cloudvoyant/nv-lib-template/commit/069bea7ceafddc96259cdd32927d587b147c6649))
- improve markdown formatting and user guide clarity ([ab4d313](https://github.com/cloudvoyant/nv-lib-template/commit/ab4d313f01ddd60e889e9719a8fcd654c8ae9e0d))
- refactor template placeholders and fix ADR references ([f1ab275](https://github.com/cloudvoyant/nv-lib-template/commit/f1ab275cdf7a0e62994ece0761494252f6922be9))

## [1.9.1](https://github.com/cloudvoyant/nv-lib-template/compare/v1.9.0...v1.9.1) (2025-10-15)

### Bug Fixes

- use get_version() in upversion.sh to properly detect new releases ([a145bc2](https://github.com/cloudvoyant/nv-lib-template/commit/a145bc270bbc01c75100d927ff5aa210caf33842))

# [1.9.0](https://github.com/cloudvoyant/nv-lib-template/compare/v1.8.2...v1.9.0) (2025-10-14)

### Bug Fixes

- getting version from tags to keep single source of truth, and avoid need for drenv reloads due to .,envrc changes on commits ([6c0004a](https://github.com/cloudvoyant/nv-lib-template/commit/6c0004a58dc66d95fcfa5b2eb45ba86d8a587a94))

### Features

- use version.txt as single source of truth for versioning ([956fe0d](https://github.com/cloudvoyant/nv-lib-template/commit/956fe0d7bab5e14e377ead1de652d31148ed11ee))

## [1.8.2](https://github.com/cloudvoyant/nv-lib-template/compare/v1.8.1...v1.8.2) (2025-10-14)

### Bug Fixes

- readme badhes ([c2990cb](https://github.com/cloudvoyant/nv-lib-template/commit/c2990cbccd56accccc95ebcf92eec1c102d05947))

## [1.8.1](https://github.com/cloudvoyant/lib/compare/v1.8.0...v1.8.1) (2025-10-13)

### Bug Fixes

- remove RELEASE_NOTES.md reference from release workflow ([07c9912](https://github.com/cloudvoyant/lib/commit/07c9912d7e72114efeaf98fa2653ce333805a166))

# [1.8.0](https://github.com/cloudvoyant/lib/compare/v1.7.0...v1.8.0) (2025-10-13)

### Features

- docs added. ([508a1d5](https://github.com/cloudvoyant/lib/commit/508a1d5ff02a48017330a99221ef2a6632516d1a))

# [1.7.0](https://github.com/cloudvoyant/lib/compare/v1.6.6...v1.7.0) (2025-10-12)

### Features

- semantic setup flags, versioning script, and simplified config ([716a0e7](https://github.com/cloudvoyant/lib/commit/716a0e7bbf374ffa7e8223773e7504bbc96a0582))

## [1.6.6](https://github.com/cloudvoyant/lib/compare/v1.6.5...v1.6.6) (2025-10-12)

### Bug Fixes

- source .envrc in publish recipe for CI compatibility ([dee4d82](https://github.com/cloudvoyant/lib/commit/dee4d821f307c7ff2803848fdd516b73a1eed9a2))

## [1.6.5](https://github.com/cloudvoyant/lib/compare/v1.6.4...v1.6.5) (2025-10-12)

### Bug Fixes

- cleaned up justfile ([281c6fc](https://github.com/cloudvoyant/lib/commit/281c6fce7801b9cc90f53bdb192901750268ad67))

## [1.6.4](https://github.com/cloudvoyant/lib/compare/v1.6.3...v1.6.4) (2025-10-12)

### Bug Fixes

- cleaned up justfile ([64def9c](https://github.com/cloudvoyant/lib/commit/64def9c96034e3c01c70e01ef1e58ecae0b04f99))

## [1.6.3](https://github.com/cloudvoyant/lib/compare/v1.6.2...v1.6.3) (2025-10-12)

### Bug Fixes

- attempting to fix issues with publish ([8732a18](https://github.com/cloudvoyant/lib/commit/8732a189610182c00f6c66c423c30bf402e4b2ec))
- attempting to fix issues with publish ([3642966](https://github.com/cloudvoyant/lib/commit/3642966677a9c607e9cc56dea538bae3416e700f))

## [1.6.2](https://github.com/cloudvoyant/lib/compare/v1.6.1...v1.6.2) (2025-10-12)

### Bug Fixes

- adding logging to publish task ([02c1451](https://github.com/cloudvoyant/lib/commit/02c14514bfab8205b50afc047b55c5a9cd826362))

## [1.6.1](https://github.com/cloudvoyant/lib/compare/v1.6.0...v1.6.1) (2025-10-12)

### Bug Fixes

- adding logging to publish task ([0ec390b](https://github.com/cloudvoyant/lib/commit/0ec390bcde8ab6c6ac349e96efb7dfba19523c8e))

# [1.6.0](https://github.com/cloudvoyant/lib/compare/v1.5.0...v1.6.0) (2025-10-12)

### Features

- doc updates ([49ce340](https://github.com/cloudvoyant/lib/commit/49ce340a022fece8c2f04598305c018d4e1aa061))

# [1.5.0](https://github.com/cloudvoyant/lib/compare/v1.4.1...v1.5.0) (2025-10-12)

### Features

- doc updates ([11e75ad](https://github.com/cloudvoyant/lib/commit/11e75ad451e48a0200b77b42c611a54e8984965f))

## [1.4.1](https://github.com/cloudvoyant/lib/compare/v1.4.0...v1.4.1) (2025-10-12)

### Bug Fixes

- use shebang for registry-login recipe to fix bash syntax error ([774ab53](https://github.com/cloudvoyant/lib/commit/774ab53fc6ff3e02373b54d9c343ca5ca1065d62))

# [1.4.0](https://github.com/cloudvoyant/lib/compare/v1.3.0...v1.4.0) (2025-10-12)

### Features

- doc updates ([c90dfd2](https://github.com/cloudvoyant/lib/commit/c90dfd201e2b6557e50a368f2e198fa8ece9d426))

# [1.3.0](https://github.com/cloudvoyant/lib/compare/v1.2.0...v1.3.0) (2025-10-12)

### Features

- consolidate setup, generalize versioning, and separate registry config ([d17cbfb](https://github.com/cloudvoyant/lib/commit/d17cbfbfda8ede27bb3235a9743a044014f40308))
- replace just release-notes with Claude command ([d34ba73](https://github.com/cloudvoyant/lib/commit/d34ba737a848278f6c753111a4add7e6afc3ed78))

# [1.2.0](https://github.com/cloudvoyant/lib/compare/v1.1.0...v1.2.0) (2025-10-11)

### Features

- consolidate tests and add ADR management commands ([c60041e](https://github.com/cloudvoyant/lib/commit/c60041ed5077d3da573dc7a9b33ededaebc863e7))
- enhance validate-docs and add development guidelines ([0d04656](https://github.com/cloudvoyant/lib/commit/0d046560c7c025339df669326c1fea668e310e87))
- make validate-docs command general-purpose ([e7056fa](https://github.com/cloudvoyant/lib/commit/e7056fa8aa3edcacad99c8a53d56c1f6f8532495))

# [1.1.0](https://github.com/cloudvoyant/lib/compare/v1.0.4...v1.1.0) (2025-10-09)

### Bug Fixes

- added error handling in scaffold.sh ([07cb982](https://github.com/cloudvoyant/lib/commit/07cb982c77b43ca91bee52688977797784f97ce0))
- added error handling in scaffold.sh ([99f4ad2](https://github.com/cloudvoyant/lib/commit/99f4ad2202bdea5291dc22701e05365919454461))
- added scripts to install platform deps ([84389ed](https://github.com/cloudvoyant/lib/commit/84389ed459c8cc7874bf3f301f9741e22933d37a))

### Features

- add GitHub template support and migration workflows ([0325a6f](https://github.com/cloudvoyant/lib/commit/0325a6faf6d76a9f72c84419c365cdb956c3e338))
- enhanced string replacement in scaffold.sh ([bce0569](https://github.com/cloudvoyant/lib/commit/bce056919d9a2eadf663839c1d2e99a8331185c4))

## [1.0.4](https://github.com/cloudvoyant/lib/compare/v1.0.3...v1.0.4) (2025-10-06)

### Bug Fixes

- getting rid of redundant VERSION file ([c5a1e47](https://github.com/cloudvoyant/lib/commit/c5a1e4740fedd6420bf42f3b00b2631d5eb6eaeb))

## [1.0.3](https://github.com/cloudvoyant/lib/compare/v1.0.2...v1.0.3) (2025-10-06)

### Bug Fixes

- fixed issues with release note gen script ([d399312](https://github.com/cloudvoyant/lib/commit/d399312ab5d6f53f90b6ebe6fd906b17824aae65))

## [1.0.2](https://github.com/cloudvoyant/lib/compare/v1.0.1...v1.0.2) (2025-10-06)

### Bug Fixes

- resolving github action not publishing by using available action ([2fa1e94](https://github.com/cloudvoyant/lib/commit/2fa1e94b207284a661a11afc1d620fbe393ad111))

## [1.0.1](https://github.com/cloudvoyant/lib/compare/v1.0.0...v1.0.1) (2025-10-06)

### Bug Fixes

- publishing during release pipeline to work around ci-skip not triggerring tag pipeline ([33d0f89](https://github.com/cloudvoyant/lib/commit/33d0f8925e152ffdca540bcf474846e424bb85d1))
- publishing during release pipeline to work around ci-skip not triggerring tag pipeline ([1a9f2a9](https://github.com/cloudvoyant/lib/commit/1a9f2a9e2b21c7d2f6b7c14a3e3d5080cfe4869d))

# 1.0.0 (2025-10-04)

### Bug Fixes

- resolved semantic release configuration bug ([a65863a](https://github.com/cloudvoyant/lib/commit/a65863aa4ef78054d8c8f8161d0431243613c8a6))

### Features

- scaffolded project structure, added standard scripts and justfile, .envrc and claude config files ([d4d60d1](https://github.com/cloudvoyant/lib/commit/d4d60d1b1b93838c03902a4da2010ee79921b560))
