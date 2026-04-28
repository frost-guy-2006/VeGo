1. **Fix Exception Handling Information Leakage**
   - Several files use `e.toString()` inside catch blocks and present raw exception details to the UI (e.g., in UI SnackBars or via provider state assignments) which leaks potentially sensitive system or database details to the user and violates memory guidance.
   - Use `AuthException` from `supabase_flutter` for auth-related files or provide generic safe fallback strings (e.g., 'Sign in failed') for others.
   - Fix the following files:
     - `freshflow/lib/core/providers/riverpod/auth_notifier.dart`
     - `freshflow/lib/features/auth/screens/login_screen.dart`
     - `freshflow/lib/features/auth/screens/otp_screen.dart`

2. **Fix ReDoS Vulnerability in Regex**
   - `freshflow/lib/core/utils/input_validators.dart` line 36: The `validateEmail` uses a somewhat strict regex. Let's make sure it's RFC 5322 compliant as memory advises to avoid ReDoS from `\w`.
   - The user also has search capabilities where `RegExp(r'...')` could be used with user inputs, but looking at `SearchScreen` and `ProductRepository` it seems they use `.ilike` and `.contains()` instead of RegExp. However, I should escape the search if `.contains()` isn't used correctly. Wait, `SearchScreen` uses `.contains(lowerQuery)` on `p.name.toLowerCase()`. That is fine. No regex ReDoS there, but memory explicitly says: "For case-insensitive string containment checks within loops (e.g., search filtering), pre-compiling a `RegExp` with `caseSensitive: false` and using `hasMatch()` is significantly more efficient than calling `.toLowerCase().contains()` on every iteration (approx. 3x-8x speedup)."

3. **Performance Optimization in SearchScreen**
   - In `freshflow/lib/features/search/screens/search_screen.dart`, update the `_performSearch` method to pre-compile a `RegExp` wrapped with `RegExp.escape(lowerQuery)` instead of using `.toLowerCase().contains(lowerQuery)` inside the loop, and also use the memory instruction to escape `lowerQuery` inside the regex to avoid ReDoS if user puts `.` or `*` or `+`.

4. **Add Verification and Pre-commit**
   - Run tests using `xvfb-run -a flutter test` inside `freshflow`.
   - Call `pre_commit_instructions`.
