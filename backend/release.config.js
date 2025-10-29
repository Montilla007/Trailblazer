export default {
  branches: ["main"],
  repositoryUrl: "https://github.com/Montilla007/Trailblazer.git",
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
          { release: false }
        ],
        parserOpts: { noteKeywords: ["BREAKING CHANGE", "BREAKING CHANGES"] },
      },
    ],
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    // ✅ This updates backend/package.json version field only
    [
      "@semantic-release/npm",
      {
        npmPublish: false,
        pkgRoot: ".", // important: run in backend/
      },
    ],
    [
      "@semantic-release/git",
      {
        assets: ["package.json", "CHANGELOG.md"],
        message: "chore(release-backend): ${nextRelease.version} [skip ci]",
      },
    ],
  ],
};
