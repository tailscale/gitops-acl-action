# GitHub Action to Sync Tailscale ACLs

This GitHub action lets you manage your [tailnet policy file](https://tailscale.com/kb/1018/acls/) using a
[GitOps](https://about.gitlab.com/topics/gitops/) workflow. With this GitHub
action you can automatically manage your tailnet policy file using a git repository
as your source of truth. 

## Inputs

### `tailnet`

**Required** The name of your tailnet. You can find it by opening [the admin
panel](https://login.tailscale.com/admin) and copying down the name next to the
Tailscale logo in the upper left hand corner of the page.

### `api-key`

**Optional** An API key authorized for your tailnet. You can get one [in the
admin panel](https://login.tailscale.com/admin/settings/keys).
Either `api-key` or `oauth-client-id` and `oauth-secret` are required.

Please note that API keys will expire in 90 days. Set up a monthly event to
rotate your Tailscale API key, or use an OAuth client.

### `oauth-client-id` and `oauth-secret`

**Optional** The ID and secret for an [OAuth client](https://tailscale.com/kb/1215/oauth-clients)
for your tailnet. The client must have the `acl` scope.

Either `api-key` or `oauth-client-id` and `oauth-secret` are required.

### `policy-file`

**Optional** The path to your policy file in the repository. If not set this
defaults to `policy.hujson` in the root of your repository.

### `action`

**Required** One of `test` or `apply`. If you set `test`, the action will run
ACL tests and not update the ACLs in Tailscale. If you set `apply`, the action
will run ACL tests and then update the ACLs in Tailscale. This enables you to
use pull requests to make changes with CI stopping you from pushing a bad change
out to production.

## Getting Started

Set up a new GitHub repository that will contain your tailnet policy file. Open the [Access Controls page of the admin console](https://login.tailscale.com/admin/acls) and copy your policy file to
a file in that repo called `policy.hujson`.

If you want to change this name to something else, you will need to add the
`policy-file` argument to the `with` blocks in your GitHub Actions config.

Copy this file to `.github/workflows/tailscale.yml`.

**Security Note:** For best security practices, pin all GitHub Actions to specific commit SHAs rather than tags. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

> **Note:** The example below shows pinned versions as of the last documentation update. While Dependabot automatically updates action references in `action.yml` and workflow files, it does not update examples in README files. For the latest pinned version of `tailscale/gitops-acl-action`, check the [releases page](https://github.com/tailscale/gitops-acl-action/releases) or see the actual `action.yml` file. For third-party actions such as `actions/checkout` and `actions/cache`, please check their respective repositories or releases pages for the most up-to-date pinned versions.

```yaml
name: Sync Tailscale ACLs

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  acls:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4.3.1

      - name: Fetch version-cache.json
        uses: actions/cache@0057852bfaa89a56745cba8c7296529d2fc39830 # v4.3.0
        with:
          path: ./version-cache.json
          key: version-cache.json-${{ github.run_id }}
          restore-keys: |
            version-cache.json-

      - name: Deploy ACL
        if: github.event_name == 'push'
        id: deploy-acl
        uses: tailscale/gitops-acl-action@90d41601ba36b946cf4946ef5a72bf6e16bae14b # v1.3.1
        with:
          api-key: ${{ secrets.TS_API_KEY }}
          tailnet: ${{ secrets.TS_TAILNET }}
          action: apply

      - name: Test ACL
        if: github.event_name == 'pull_request'
        id: test-acl
        uses: tailscale/gitops-acl-action@90d41601ba36b946cf4946ef5a72bf6e16bae14b # v1.3.1
        with:
          api-key: ${{ secrets.TS_API_KEY }}
          tailnet: ${{ secrets.TS_TAILNET }}
          action: test
```

Generate a new API key [here](https://login.tailscale.com/admin/settings/keys).

Set a monthly calendar reminder to renew this key because Tailscale does not
currently support API key renewal (this will be updated to support that when
that feature is implemented).

Then open the secrets settings for your repo and add two secrets:

* `TS_API_KEY`: Your Tailscale API key from the earlier step
* `TS_TAILNET`: Your tailnet's name (it's next to the logo on the upper
  left-hand corner of the [admin
  panel](https://login.tailscale.com/admin/machines))

Once you do that, commit the changes and push them to GitHub. You will have CI
automatically test and push changes to your tailnet policy file to Tailscale.

## Developer guide

### Release process

To create a new minor or patch release:

- push the new tag to the main branch

- create a new GitHub release with a description of the changes in this release

- repush the latest major release tag to point at the new latest release.
For example, if you are creating a `v1.3.1` release, you want to additionally tag it with `v1` tag.
This approach follows the [official GitHub actions versioning guidelines](https://docs.github.com/en/actions/creating-actions/about-custom-actions#using-tags-for-release-management).
