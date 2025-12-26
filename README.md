# Expo CLI Bug: `expo export --clear` doesn't clear Metro cache

Minimal reproduction for `@expo/cli@54.0.20+` where the `--clear` flag doesn't clear Metro's cache.

## The Bug

Running `expo export --clear` with different environment variables produces **identical bundles** (same hash). The cache is not being cleared, causing builds to reuse cached bundles with old environment variables.

## Reproduction

```bash
npm install
npm run test:repro
```

**Expected:** Bundle hashes should be different
**Actual:** Bundle hashes are identical (cache not cleared)

## Testing the Fix

This repo includes a patch file that fixes the bug. You can apply and unapply it to see the difference:

**Step 1: See the bug**
```bash
npm run test:repro
# 🐛 BUG: Bundle hashes are IDENTICAL
```

**Step 2: Apply the fix**
```bash
npm run apply-fix
# Patches @expo/cli with the resetCache fix
```

**Step 3: Verify the fix works**
```bash
npm run test:repro
# ✅ Bundle hashes are different - cache was cleared
```

**Step 4: Remove the fix (optional)**
```bash
npm run unapply-fix
# Reverts @expo/cli to original buggy state
```

You can toggle between fixed and buggy states using `apply-fix` and `unapply-fix`.

## Root Cause

In `@expo/cli@54.0.20` ([commit 34dd4b38a4](https://github.com/expo/expo/commit/34dd4b38a4)), the `resetCache` option was accidentally removed from Metro's config:

**File:** `build/src/start/server/metro/instantiateMetro.js:146-160`

```diff
 config = {
   ...config,
   watchFolders: ...,
+  resetCache: options.resetCache,  // This line is missing
   reporter: ...
 };
```

## Affected Versions

- `@expo/cli@54.0.20+` (published Dec 18, 2024)
- `expo@54.0.29+`
