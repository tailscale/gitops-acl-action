# Contributing to gitops-acl-action

Thank you for your interest in contributing to this project!

## GitHub Actions Best Practices

This repository follows GitHub Actions security best practices to ensure the integrity and security of our CI/CD pipeline.

### Action Pinning Standard

All GitHub Actions used in this repository **must** be pinned to a specific commit SHA rather than using mutable tags like `@main`, `@latest`, or even version tags like `@v1`.

**Why pin to commit SHAs?**
- Prevents supply chain attacks where an action maintainer's account could be compromised
- Ensures reproducible builds - the action won't change unexpectedly
- Provides an immutable reference that can't be altered
- Allows security audits of the exact code being executed

**Format:**
```yaml
- uses: actions/setup-go@d35c59abb061a4a6fb18e82ac0862c26744d6ab5 # v5.5.0
```

Note: We include the version tag in a comment for human readability, but the commit SHA is what's actually used.

### Dependabot for Action Updates

This repository uses Dependabot to automatically check for updates to pinned GitHub Actions. Dependabot is configured in `.github/dependabot.yml` to:
- Check for updates weekly
- Monitor both workflow files (`.github/workflows/`) and composite action files (`action.yml`)
- Create pull requests when new versions are available

When Dependabot creates a PR to update an action:
1. Review the changelog and release notes for the new version
2. Verify the action source code if there are significant changes
3. Test the changes in the PR
4. Merge only if all checks pass and changes are reviewed

### Security Best Practices

When working with GitHub Actions in this repository:

1. **Minimal Permissions**: Use the `permissions` key to grant only the minimal permissions required
2. **Verified Actions**: Prefer official GitHub Actions and verified creators
3. **Secret Handling**: Never pass secrets to untrusted third-party actions
4. **Code Review**: Review action source code before introducing new dependencies
5. **Avoid Remote Code Execution**: Never run untrusted remote code (e.g., `curl | bash`)
6. **Regular Updates**: Keep actions up-to-date through Dependabot and periodic manual reviews

### Adding New Actions

When adding a new GitHub Action to a workflow or composite action:

1. Find the latest release/tag of the action
2. Get the commit SHA for that tag
3. Pin to the commit SHA with a version comment
4. Document why the action is needed in your PR

Example:
```yaml
# Get the commit SHA for a tag
git ls-remote https://github.com/actions/checkout v4.1.1
# Use the resulting SHA in your workflow
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```

### Updating Actions

Dependabot will automatically create PRs to update pinned actions. Manual updates can be done by:

1. Finding the new version's commit SHA
2. Updating the SHA and version comment
3. Testing the changes
4. Creating a PR with a clear description of what's being updated

### Maintaining Documentation Examples

**Important:** Dependabot automatically updates action references in `action.yml` and `.github/workflows/` files, but it **does not** update code examples in markdown documentation files like README.md.

When Dependabot updates action versions in `action.yml`:
1. Review the README.md file to check if examples need updating
2. Update the pinned commit SHAs in the README examples to match
3. Include these documentation updates in the same PR or a follow-up commit

This ensures users always have current examples showing the correct pinning format.

## Questions?

If you have questions about these practices or need help implementing them, please open an issue for discussion.
