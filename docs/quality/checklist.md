# Pre-Merge Checklist

Before committing, verify:

- [ ] `bash scripts/ci/validate.sh` passes
- [ ] No file exceeds 200 lines
- [ ] No backwards dependency (check layer-rules.md)
- [ ] All new functions have `##` doc comments
- [ ] All variables are typed
- [ ] Colors use `data/colors.gd` constants
- [ ] Touch targets ≥ 44×44px
- [ ] No magic numbers
- [ ] Commit message follows convention (feat/fix/refactor/docs/chore)
- [ ] For visual changes: screenshot captured and verified
