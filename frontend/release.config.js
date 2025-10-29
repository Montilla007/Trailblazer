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
        parserOpts: { noteKeywords: ["BREAKING CHANGE", "BREAKING CHANGES"] },
      },
    ],
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    // ✅ This updates frontend/package.json version field only
    [
      "@semantic-release/npm",
      {
        npmPublish: false,
        pkgRoot: ".", // important: run in frontend/
      },
    ],
    [
      "@semantic-release/git",
      {
        assets: ["package.json", "CHANGELOG.md"],
        message: "chore(release-frontend): ${nextRelease.version} [skip ci]",
      },
    ],
  ],
};
