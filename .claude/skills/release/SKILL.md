---
name: release
description: Build SnipHalo.app and publish a GitHub Release with the zipped binary. Handles version bumping in Info.plist.
disable-model-invocation: true
allowed-tools: Bash(swift *) Bash(./build.sh) Bash(zip *) Bash(gh *) Bash(git *) Read Edit AskUserQuestion
argument-hint: "[version e.g. 1.2.0]"
arguments: [version]
---

## Release SnipHalo to GitHub Releases

### Step 1: Determine version

Read `Resources/Info.plist` and extract the current `CFBundleVersion` and `CFBundleShortVersionString`.

- If `$version` was provided as an argument, use that as the new version.
- If `$version` was NOT provided, ask the user using AskUserQuestion:
  - Show the current version
  - Offer choices: patch bump, minor bump, major bump, or keep current version
  - Example: if current is `1.0.0`, offer `1.0.1`, `1.1.0`, `2.0.0`, or `1.0.0 (no change)`

### Step 2: Update version in Info.plist

If the version is changing:
1. Update `CFBundleVersion` to the new version (e.g. `1.2.0`)
2. Update `CFBundleShortVersionString` to the short version (e.g. `1.2`)
3. Commit the version bump: `git add Resources/Info.plist && git commit -m "Bump version to <version>"`

### Step 3: Build

Run `./build.sh` to build the app. If it fails, stop and report the error.

### Step 4: Package

```bash
zip -r SnipHalo-v<version>.zip SnipHalo.app
```

### Step 5: Create git tag and GitHub Release

```bash
git tag v<version>
git push origin main
git push origin v<version>
gh release create v<version> SnipHalo-v<version>.zip \
  --title "SnipHalo v<version>" \
  --generate-notes
```

### Step 6: Clean up

Remove the zip file after a successful release:

```bash
rm SnipHalo-v<version>.zip
```

Report the release URL to the user.
