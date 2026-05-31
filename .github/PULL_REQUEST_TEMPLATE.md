## Summary

<!-- One or two sentences: what does this PR do and why? -->

## Type of change

<!-- Check all that apply -->

- [ ] `feat` — New feature
- [ ] `fix` — Bug fix
- [ ] `perf` — Performance improvement
- [ ] `refactor` / `chore` — Code cleanup, dependency update, internal task
- [ ] `docs` — Documentation only
- [ ] `test` — Tests only
- [ ] `ci` — CI / workflow change

## Affected component(s)

<!-- e.g. compositor, render, core, iso-executor, theme — match the commit scope -->

## Motivation & context

<!-- Why is this change needed? Link related issues: Closes #123 -->

## Changes made

<!-- Bullet points covering the key changes -->

-
-

## How to test

<!-- Steps to verify the change works. Be specific. -->

1.
2.

## Checklist

### General
- [ ] PR title follows Conventional Commits — `type(scope): Description`
- [ ] No unrelated changes included
- [ ] Self-review completed

### sabas-os
- [ ] Wayland protocol compatibility unchanged (or intentional, noted above)
- [ ] Vulkan / render path tested (no frame drops, no regression)
- [ ] Native / JNI changes reviewed for memory safety
- [ ] Event bus contract unchanged (or all subscribers updated)
- [ ] ArchUnit / architecture tests pass (`mvn test`)
- [ ] New module added to parent `pom.xml` if applicable

### sabas-live-iso
- [ ] ISO boots successfully in VM after build
- [ ] Tested build mode(s): `JARS` / `FAT_JAR` / `NATIVE` / `Container`
- [ ] dracut / squashfs / boot config unchanged (or intentional, noted above)
- [ ] Anaconda WebUI branding unaffected (or intentional)

### Breaking changes
- [ ] Not a breaking change
- [ ] Breaking change — migration steps documented below

<!-- If breaking, describe what callers / dependents need to update -->
