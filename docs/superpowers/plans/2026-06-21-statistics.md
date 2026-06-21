# Statistics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Persist tap metrics for new records and add a difficulty-based statistics screen.

**Architecture:** `GameRecord` gains optional tap fields with backward-compatible parsing. A pure `GameStatistics` model computes metrics. A standalone statistics screen receives records, daily records, streak, and achievement totals.

**Tech Stack:** Flutter, Dart, CustomPainter, flutter_test

---

### Task 1: Record Format

- [ ] Write failing backward-compatibility and new-format tests.
- [ ] Add optional wrong-tap and total-tap fields.
- [ ] Save new classic results with tap data.
- [ ] Run record tests.

### Task 2: Statistics Model

- [ ] Write failing tests for difficulty filtering, recent averages, and unknown tap data.
- [ ] Implement pure statistics calculations.
- [ ] Run model tests.

### Task 3: Statistics Screen

- [ ] Write failing navigation and empty-state widget tests.
- [ ] Add analytics toolbar action and statistics screen.
- [ ] Render summary metrics and recent trend without a new dependency.
- [ ] Run widget tests.

### Task 4: Documentation and Verification

- [ ] Update README and AGENTS.
- [ ] Run formatting and analysis.
- [ ] Run all tests.
- [ ] Build the release AAB.
- [ ] Run diff checks.
