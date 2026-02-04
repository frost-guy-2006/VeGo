---
name: i18n Localization
description: Managing .arb translation files and handling localization in Flutter.
source: sickn33/antigravity-awesome-skills/i18n-localization
status: placeholder
---

# i18n Localization

> **Status**: Value placeholder. Original source could not be fetched.
> **Goal**: Make app accessible to global audience.

## Workflow
1. **ARB Files**: Maintain `app_en.arb` as source of truth.
2. **Keys**: Use descriptive keys (e.g., `homePageTitle`).
3. **Generation**: Run `flutter gen-l10n` to generate Dart classes.
4. **Usage**: Use `AppLocalizations.of(context).key` in widgets.

## Best Practices
- **No Hardcoded Strings**: All UI text must be in ARB.
- **Plurals**: Handle pluralization rules.
- **Dates/Numbers**: Use `intl` package for formatting.
