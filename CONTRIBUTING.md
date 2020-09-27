# Contributing Guidelines

## Branches

We work with Feature-Branches, Maintenance-Branches, Pre-Release-Branches and master.

### Release Branches

#### Stable

- `master`

#### Pre-Release

- `beta`: Beta-Grade Releases
- `alpha`: Alpha-Grade Releases

#### Maintenance

- `1.0.x`

### Non-Release Branches

#### Feature/Fix-Releases

- `feature/...`
- `fix/...`

## Versioning

We implement [Semantic Versioning](https://semver.org/) for our repositories with [shipmate](https://gitlab.com/peter.saarland/shipmate). We're adhering to the following principles:

- Versioning happens automatically upon every push to one of the [Release Branches](#release-branches)
- We use [Conventional Commits](https://conventionalcommits.org/) to establish automated releases

## Commit Guidelines

All pull requests SHOULD adhere to the [Conventional Commits](https://conventionalcommits.org/) specification.

The commit contains the following structural elements, to communicate intent to the consumers of your library:

- fix: a commit of the type fix patches a bug in your codebase (this correlates with PATCH in semantic versioning).
- feat: a commit of the type feat introduces a new feature to the codebase (this correlates with MINOR in semantic versioning).
- BREAKING CHANGE: a commit that has a footer BREAKING CHANGE:, or appends a ! after the type/scope, introduces a breaking API change (correlating with MAJOR in semantic versioning). A BREAKING CHANGE can be part of commits of any type.
- types other than `fix:` and `feat:` are allowed, for example `build:`, `chore:`, `ci:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, and others.
- footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.

Additional types are not mandated by the Conventional Commits specification, and have no implicit effect in semantic versioning (unless they include a BREAKING CHANGE).

A scope may be provided to a commit’s type, to provide additional contextual information and is contained within parenthesis, e.g., feat(parser): add ability to parse arrays.

### Examples

#### Commit message with description and breaking change footer

```bash
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

#### Commit message with ! to draw attention to breaking change

```bash
refactor!: drop support for Node 6
```

#### Commit message with both ! and BREAKING CHANGE footer

```bash
refactor!: drop support for Node 6

BREAKING CHANGE: refactor to use JavaScript features not available in Node 6.
```

### Commit message with no body (Default)

```bash
docs: correct spelling of CHANGELOG
```

#### Commit message with scope

```bash
feat(lang): add polish language
```

#### Commit message with multi-paragraph body and multiple footers

```bash
fix: correct minor typos in code

see the issue for details

on typos fixed.

Reviewed-by: Z
Refs #133
```

## Documentation

- `README.md` contains general information and will be managed by [shipmate](https://gitlab.com/peter.saarland/shipmate) in the future
- Documentation happens in Markdown in `docs/`
