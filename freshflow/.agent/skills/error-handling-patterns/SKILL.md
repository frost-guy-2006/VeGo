---
name: Error Handling Patterns
description: Critical patterns for mobile app stability. Covers global error handling, user-friendly error messages, retry policies, and error reporting.
source: wshobson/agents/error-handling-patterns
status: placeholder
---

# Error Handling Patterns

> **Status**: Value placeholder. Original source could not be fetched.
> **Goal**: Ensure app stability and graceful failure recovery.

## Core Principles
1. **Never Crash**: Catch exceptions at the boundary.
2. **Inform User**: Show meaningful messages, not stack traces.
3. **Retry**: Transient network errors should auto-retry.
4. **Report**: Log fatal errors to a service (e.g., Sentry, Firebase Crashlytics).

## Common Patterns
- **Try/Catch Blocks**: Around dangerous code (IO, network).
- **Global Error Handler**: Catch uncaught Flutter errors.
- **AsyncValue Handling**: (Riverpod) Handle loading/error/data states.
- **Result Type**: Use functional error handling (Result<T, E>) to force handling.
