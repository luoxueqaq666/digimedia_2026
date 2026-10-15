# UI redesign / Taste Skill

## Source

Installed from https://github.com/Leonxlnx/taste-skill, path skills/taste-skill.
Personal install: C:/Users/zheye/.codex/skills/taste-skill/SKILL.md.
The frontmatter name is design-taste-frontend.

## Scope interpretation

The installed version explicitly excludes dashboards and multi-step product UI.
Its audit, preservation, typography, contrast, and reduced-motion principles
are used here as general review guidance, not as a claim that its marketing
templates are appropriate for this research application.

Design read: a research workspace for campus media and content editors.
DESIGN_VARIANCE=3, MOTION_INTENSITY=2, VISUAL_DENSITY=7.
Native CSS on the existing React components; not an imitation of a named
official design system. Existing Lucide icons and ECharts retained.

## Before / after

- Before: 9-11px secondary labels, pale text, excessive green-tinted neutrals,
  decorative English section numbering, weak primary action hierarchy.
- After: 12-15px working text, higher-contrast neutral text, compact contextual
  header, unframed summary band, separate event list and evidence panel,
  consistent green action hierarchy, responsive single-column mobile reading.
- Preserve: brand wordmark, all five navigation labels, data/API interfaces,
  selected events, bookmarks, manual grouping, editable briefs, form order.
- Removed decorative section numbers and headline dot. The header now displays
  actual dataset, report count, source count and collection time.
- Kept yellow warnings and blue informational states as semantic colors.
- Motion limited to hover/focus feedback; reduced-motion override included.

No backend or database changes are included in this UI redesign.

## Intelligent Systems adaptation

The supplied landing-page direction is adapted to the campus media product,
not used to replace the operational UI with a marketing page.
Dark charcoal navigation, mint active controls, neutral reading surfaces,
compact editorial typography and consistent 6px control corners.
Existing charts and the Guanlan wave mark remain the visual assets.
No placeholder video, fabricated testimonials, pricing or misleading AI claims.
Search, audience ranking, evidence, pitches and print styling are preserved.
Screen-only overrides live in src/intelligent.css to avoid changing PDF output.
