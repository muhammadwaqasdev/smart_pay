# Contributing to smart_pay

Thanks for your interest in contributing! This guide explains how to set up your environment, propose changes, and get your pull request merged.

## Getting started
- Search existing issues and pull requests before filing something new.
- For larger changes, open an issue to discuss the proposal first.

## Development setup
1. Prerequisites:
    - Flutter 3.22+ and Dart 3.4+
    - Xcode (for iOS) and Android SDK (for Android)
2. Clone and bootstrap:
    - `flutter pub get`
    - `cd example && flutter pub get && cd ..`
3. Run tests:
    - `flutter test`
4. Run static checks (optional but recommended):
    - `dart pub global activate pana`
    - `~/.pub-cache/bin/pana .`

## Making changes
- Keep edits focused and small; separate unrelated changes.
- Follow existing code style and naming conventions.
- Add or update tests where it makes sense.
- Update documentation (README, CHANGELOG) when user-facing behavior changes.

## Pull request workflow (required)
This project follows a Fork-and-PR model. Do not push directly to the main repo.

1) Fork
- Click “Fork” on GitHub to create your copy under your account.

2) Clone your fork
```bash
git clone https://github.com/muhammadwaqasdev/smart_pay.git
cd smart_pay
git remote add upstream https://github.com/muhammadwaqasdev/smart_pay.git
```

3) Create a feature branch
```bash
git checkout -b feat/<short-topic>
```

4) Develop
- Run `flutter pub get`, make changes, add tests/docs.
- `flutter test` and (optionally) `pana` before committing.

5) Commit and push to your fork
```bash
git add -A
git commit -m "feat: <concise change summary>"
git push origin HEAD
```

6) Open PR from your fork to upstream
- From `<your-username>/smart_pay:feat/<short-topic>` → `muhammadwaqasdev/smart_pay:main`.
- A maintainer will review and request changes if needed.

7) Sync with upstream (when needed)
```bash
git checkout main
git fetch upstream
git rebase upstream/main
git push origin main --force-with-lease
```

## Release policy (contributors cannot release)
- Contributors MUST NOT publish releases or push tags.
- Do NOT bump the `version` in `pubspec.yaml` in your PR.
- Add your notes under an "Unreleased" section in `CHANGELOG.md` when applicable.
- After PR merge, a maintainer will:
    - finalize the CHANGELOG,
    - bump the version,
    - tag and publish the release to pub.dev.

## Commit and PR guidelines
- Use clear commit messages with imperative tone, e.g., "Add Stripe PaymentSheet flow".
- Include a short PR description with context, screenshots/gifs if UI changes.

## Running the example app
- `cd example`
- First time only: `flutter create .`
- `flutter run`

## Code of Conduct
Please be respectful and inclusive. By participating, you agree to uphold the principles described in the [Contributor Covenant](https://www.contributor-covenant.org/).
