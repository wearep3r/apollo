# Contriubuting Guidelines

# Versioning
This repository follows [Semantic Versioning](https://semver.org/) which is implemented via CI. Versioning happens automatically upon every commit in `master`.

# Style Guide

All pull requests SHOULD adhere to the [Conventional Commits](https://conventionalcommits.org/) specification.

The commit contains the following structural elements, to communicate intent to the consumers of your library:

* fix: a commit of the type fix patches a bug in your codebase (this correlates with PATCH in semantic versioning).
* feat: a commit of the type feat introduces a new feature to the codebase (this correlates with MINOR in semantic versioning).
* BREAKING CHANGE: a commit that has a footer BREAKING CHANGE:, or appends a ! after the type/scope, introduces a breaking API change (correlating with MAJOR in semantic versioning). A BREAKING CHANGE can be part of commits of any type.
* types other than `fix:` and `feat:` are allowed, for example `build:`, `chore:`, `ci:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, and others.
* footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.

Additional types are not mandated by the Conventional Commits specification, and have no implicit effect in semantic versioning (unless they include a BREAKING CHANGE). 

A scope may be provided to a commit’s type, to provide additional contextual information and is contained within parenthesis, e.g., feat(parser): add ability to parse arrays.

## Examples

### Commit message with description and breaking change footer

```
eat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### Commit message with ! to draw attention to breaking change
```
refactor!: drop support for Node 6
```

### Commit message with both ! and BREAKING CHANGE footer

```
refactor!: drop support for Node 6

BREAKING CHANGE: refactor to use JavaScript features not available in Node 6.
```

### Commit message with no body (Default)

```
docs: correct spelling of CHANGELOG
```

### Commit message with scope

```
feat(lang): add polish language
```

### Commit message with multi-paragraph body and multiple footers

```
fix: correct minor typos in code

see the issue for details

on typos fixed.

Reviewed-by: Z
Refs #133
```

## Conform
We use tooling to validate conformity of commits. Our tool of choice for this repository is [Conform](https://github.com/talos-systems/conform). Please refer to the [repository](https://github.com/talos-systems/conform) for installation instructions.

To let Conform validate your commits upon sending, hook it to `commit-msg`:

```
cat <<EOF | tee .git/hooks/commit-msg
#!/bin/sh

conform enforce --commit-msg-file \$1
EOF
chmod +x .git/hooks/commit-msg

```