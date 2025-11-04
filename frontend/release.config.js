export default {
  branches: ["main"],
  repositoryUrl: "https://github.com/Montilla007/Trailblazer.git",
  tagFormat: "frontend-v${version}",
  plugins: [
    [
      "@semantic-release/commit-analyzer",
      {
        preset: "conventionalcommits",
        releaseRules: [
          { type: "feat", release: "minor", scope: "frontend" },
          { type: "fix", release: "patch", scope: "frontend" },
          { type: "perf", release: "patch", scope: "frontend" },
          { type: "refactor", release: "patch", scope: "frontend" },
          { type: "revert", release: "patch", scope: "frontend" },
          { type: "chore", release: false },
          { type: "docs", release: false },
          { type: "style", release: false },
          { type: "test", release: false },
        ],
      },
    ],
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",

    // ✅ Update package.json (for Expo JS project)
    [
      "@semantic-release/npm",
      {
        npmPublish: false,
        pkgRoot: "frontend", // path to your Expo app
      },
    ],

    // ✅ Custom step: update app.json version to match package.json
    {
      async verifyConditions() {},
      async prepare(pluginConfig, context) {
        const fs = (await import("fs")).default;
        const appJsonPath = "frontend/app.json";
        const appJson = JSON.parse(fs.readFileSync(appJsonPath, "utf8"));

        // Update Expo version
        appJson.expo.version = context.nextRelease.version;

        // Increment versionCode / buildNumber automatically
        const versionCode = appJson.expo.android?.versionCode ?? 1;
        appJson.expo.android.versionCode = versionCode + 1;

        const buildNumber = parseInt(appJson.expo.ios?.buildNumber ?? "1", 10);
        appJson.expo.ios.buildNumber = (buildNumber + 1).toString();

        fs.writeFileSync(appJsonPath, JSON.stringify(appJson, null, 2));
        context.logger.log(`Updated app.json to version ${context.nextRelease.version}`);
      },
    },

    [
      "@semantic-release/git",
      {
        assets: ["frontend/package.json", "frontend/app.json", "frontend/CHANGELOG.md"],
        message: "chore(release-frontend): ${nextRelease.version} [skip ci]",
      },
    ],
  ],
};
