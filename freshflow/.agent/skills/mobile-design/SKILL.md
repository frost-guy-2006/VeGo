---
name: Mobile Design System
description: Mobile-first design system skill for preventing desktop-thinking and ensuring touch-friendly, platform-respectful UI/UX. Includes Mobile Feasibility Risk Index (MFRI), performance doctrines for Flutter/React Native, and mandatory checks for touch targets and safe areas.
source: sickn33/antigravity-awesome-skills/mobile-design
---

# Mobile Design System
**(Mobile-First · Touch-First · Platform-Respectful)**

> **Philosophy:** Touch-first. Battery-conscious. Platform-respectful. Offline-capable.
> **Core Law:** Mobile is NOT a small desktop.
> **Operating Rule:** Think constraints first, aesthetics second.

This skill exists to **prevent desktop-thinking, AI-defaults, and unsafe assumptions** when designing or building mobile applications.

## 1. Mobile Feasibility & Risk Index (MFRI)

Before designing or implementing **any mobile feature or screen**, assess feasibility.

### MFRI Dimensions (1–5)
| Dimension                  | Question                                                          |
| -------------------------- | ----------------------------------------------------------------- |
| **Platform Clarity**       | Is the target platform (iOS / Android / both) explicitly defined? |
| **Interaction Complexity** | How complex are gestures, flows, or navigation?                   |
| **Performance Risk**       | Does this involve lists, animations, heavy state, or media?       |
| **Offline Dependence**     | Does the feature break or degrade without network?                |
| **Accessibility Risk**     | Does this impact motor, visual, or cognitive accessibility?       |

### Interpretation
| MFRI     | Meaning   | Required Action                       |
| -------- | --------- | ------------------------------------- |
| **6–10** | Safe      | Proceed normally                      |
| **3–5**  | Moderate  | Add performance + UX validation       |
| **0–2**  | Risky     | Simplify interactions or architecture |
| **< 0**  | Dangerous | Redesign before implementation        |

## 2. Mandatory Thinking Before Any Work

### ⛔ STOP: Ask Before Assuming (Required)
If **any of the following are not explicitly stated**, you MUST ask before proceeding:

| Aspect     | Question                                   | Why                                      |
| ---------- | ------------------------------------------ | ---------------------------------------- |
| Platform   | iOS, Android, or both?                     | Affects navigation, gestures, typography |
| Framework  | React Native, Flutter, or native?          | Determines performance and patterns      |
| Navigation | Tabs, stack, drawer?                       | Core UX architecture                     |
| Offline    | Must it work offline?                      | Data & sync strategy                     |
| Devices    | Phone only or tablet too?                  | Layout & density rules                   |
| Audience   | Consumer, enterprise, accessibility needs? | Touch & readability                      |

## 4. AI Mobile Anti-Patterns (Hard Bans)

### 🚫 Performance Sins (Non-Negotiable)
| ❌ Never                   | ✅ Always                                |
| ------------------------- | --------------------------------------- |
| ScrollView for long lists | FlatList / FlashList / ListView.builder |
| Inline renderItem         | useCallback + memo / const widgets      |
| Index as key              | Stable ID                               |
| JS-thread animations      | Native driver / GPU                     |
| console.log in prod       | Strip logs                              |

### 🚫 Touch & UX Sins
| ❌ Never               | ✅ Always          |
| --------------------- | ----------------- |
| Touch <44–48px        | Min touch target  |
| Gesture-only action   | Button fallback   |
| No loading state      | Explicit feedback |
| No error recovery     | Retry + message   |
| Ignore platform norms | iOS ≠ Android     |

### 🚫 Security Sins
| ❌ Never                | ✅ Always               |
| ---------------------- | ---------------------- |
| Tokens in AsyncStorage | SecureStore / Keychain |
| Hardcoded secrets      | Env + secure storage   |
| No SSL pinning         | Cert pinning           |
| Log sensitive data     | Never log secrets      |
