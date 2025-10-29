export default {
  branches: ["main"],
  tagFormat: "backend-v${version}",
  plugins: [
    [
      "@semantic-release/commit-analyzer",
      {
        preset: "conventionalcommits",
        releaseRules: [
          { type: "feat", release: "minor", scope: "backend" },
          { type: "fix", release: "patch", scope: "backend" },
          { type: "perf", release: "patch", scope: "backend" },
          { type: "refactor", release: "patch", scope: "backend" },
          { type: "revert", release: "patch", scope: "backend" },
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
    [
      "@semantic-release/git",
      {
        assets: ["backend/package.json", "backend/CHANGELOG.md"],
        message: "chore(release-backend): ${nextRelease.version} [skip ci]",
      },
    ],
  ],
};
