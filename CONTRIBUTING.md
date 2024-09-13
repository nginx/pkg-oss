# Contributing Guidelines

The following is a set of guidelines for contributing to NGINX Open Source
packaging. We really appreciate that you are considering contributing!

#### Table Of Contents

[Getting Started](#getting-started)

[Contributing](#contributing)

[Code Guidelines](#code-guidelines)

[Code of Conduct](https://github.com/nginx/pkg-oss/blob/master/CODE_OF_CONDUCT.md)

## Getting Started

The `master` branch holds packaging sources for the current mainline version,
while `stable-*` branches contain latest sources for stable releases.

To build binary packages, run `make` in `debian/` directory on Debian/Ubuntu, or in
`rpm/SPECS/` on RHEL and derivatives, SLES, and Amazon Linux, or in `alpine/` on Alpine.

## Contributing

### Report a Bug

To report a bug, open an issue on GitHub with the label `bug`. Please ensure the bug has not already been
reported. **If the bug is a potential security vulnerability, please report it
using our [security policy](https://github.com/nginx/pkg-oss/blob/master/SECURITY.md).**

### Suggest a Feature or Enhancement

To suggest a feature or enhancement, please create an issue on GitHub with the
label `enhancement`.  Please ensure the feature or enhancement has not already
been suggested.

### Open a Pull Request

- Fork the repo, create a branch, implement your changes, add any relevant
  tests, submit a PR when your changes are **tested** and ready for review.

Note: if you'd like to implement a new feature, please consider creating a
feature request issue first to start a discussion about the feature.

## Code Guidelines

### Git Guidelines

- Keep a clean, concise and meaningful git commit history on your branch
  (within reason), rebasing locally and squashing before submitting a PR.
- If possible and/or relevant, use the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
  format when writing a commit message, so that changelogs can be automatically generated.

- Follow the guidelines of writing a good commit message as described here
  <https://chris.beams.io/posts/git-commit/> and summarised in the next few points:
  - In the subject line, use the present tense ("Add feature" not "Added feature").
  - In the subject line, use the imperative mood ("Move cursor to..." not "Moves cursor to...").
  - Limit the subject line to 72 characters or less.
  - Reference issues and pull requests liberally after the subject line.
  - Add more detailed description in the body of the git message (`git commit -a`
    to give you more space and time in your text editor to write a good message instead of `git commit -am`).

