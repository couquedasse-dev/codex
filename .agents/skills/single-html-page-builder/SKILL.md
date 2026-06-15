---
name: single-html-page-builder
description: Build or update a single-file HTML page in index.html by handing off to the html-builder agent. Use when a user asks for a single-file HTML page, an index.html-only implementation, or a natural-language page build/edit that should stay in one HTML file with inline CSS and JS.
---

# Single HTML Page Builder

## Workflow

1. Confirm the user's goal and the page's core requirements.
2. If details are missing, ask at most 3 short questions.
3. If the user does not answer, proceed with sensible defaults and report the assumptions.
4. Use the confirmed `html_builder` agent name and create or update only `index.html`.
5. Keep all HTML, CSS, and JS inside `index.html`.
6. Do not introduce React, Vue, npm dependencies, external CDN imports, or extra files.
7. Use semantic HTML and include a mobile-friendly viewport meta tag.
8. After implementation, run a code review against the checklist below.

## Review Checklist

- `index.html` contains `<html`, `<head`, and `<body`.
- `index.html` contains a `<style>` block.
- `index.html` contains a viewport meta tag.
- `index.html` does not import external CDN assets or scripts.
- No unnecessary files were created.
- No file other than `index.html` was modified.

## Stop Hook Handoff

- Do not run hooks from this skill.
- Do not change hook configuration, git settings, or push to git.
- Leave testing and any automatic commit behavior to the existing Stop hook at turn end.
- The Stop hook should use the `index.html` change as the signal for its own test and auto-commit flow.

