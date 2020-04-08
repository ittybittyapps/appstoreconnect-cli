# Contributing to _AppStoreConnect CLI_

## Bug Reports, Feature Requests and Questions

Before submitting a new GitHub issue, please make sure to:

- Read the `README` for [this repo][readme].
- Read other documentation in this repo.
- Search the [existing issues][issues] for similar issues.

If the above doesn't help, please [submit an issue][new-issue] via GitHub.

**Note**: If you want to report a regression (something that has worked before, but broke with a new release), please label your issue with the `regression` label. This enables us to quickly detect and fix regressions.

## Contributing Code

### Finding things to do

The [Core Contributors][core-contributor] usually tag issues that are ready to be worked on and easily accessible for new contributors with the [“good first issue”][good-first-issue] label. If you’ve never contributed to _AppStoreConnect CLI_ before, these are a great place to start!

If you want to work on something else, such as a new feature or fixing a bug, it would be helpful if you submit a new issue, so that we can have a chance to discuss it first. We might have some pointers for you on how to get started, or how to best integrate it with existing solutions.

### Checking out the Code

- Click the “Fork” button in the upper right corner of the [repo][repo].
- Clone your fork:
  - `git clone git@github.com:<YOUR_GITHUB_USER>/appstoreconnect-cli.git`
  - See the [GitHub documentation][fork-docs] about managing your fork.

#### Recommended

- Create a new branch to work on with `git checkout -b <YOUR_BRANCH_NAME>`.
  - Branch names should be descriptive of what you're working on, eg: `docs/updating-contributing-guide`, `fix/create-user-crash`.
- Use [good descriptive commit messages][commit-messages] when committing code.

## Testing

- Please write unit tests for your code changes. 
- Run the unit tests with `swift test` or Xcode `⌘U` before submitting your Pull Request.

## Submitting a Pull Request

When you are ready to submit the PR, everything you need to know about submitting the PR itself is inside our [Pull Request Template][pr-template]. Some best practices are:

- Use a descriptive title.
- Link the issues that are related to your PR in the body.

## After the review

Once a [Core Contributor][core-contributor] has reviewed your PR, you might need to make changes before it gets merged. To make it easier on us, please make sure to avoid amending commits or force pushing to your branch to make corrections. By avoiding rewriting the commit history, you will allow each round of edits to become its own visible commit. This helps the people who need to review your code easily understand exactly what has changed since the last time they looked. When you are done addressing your review, make sure you alert the reviewer in a comment or via GitHub's rerequest review command. See [GitHub's documentation for dealing with Pull Requests][pr-docs].

After your contribution is merged, it’s not immediately available to all users. Your change will be shipped as part of the next release.

## Code of Conduct

Help us keep this project diverse, open and inclusive. Please read and follow our [Code of Conduct][code-of-conduct].

## Thanks for Contributing!

Thank you for taking the time to contribute to the project!

## License

This project is licensed under the terms of the MIT license. See the [LICENSE][license] file. 

All contributions to this project are also under this license as per [GitHub's Terms of Service][github-terms-contribution].

> This project is in no way affiliated with [Apple Inc][apple]. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. _AppStoreConnect CLI_ runs on your own computer or server and does not communicate with any service other than the [Apple AppStore Connect API](appstore-connect-api). You are responsible for how you use _AppStoreConnect CLI_.

<!-- Links: -->
[readme]: https://github.com/ittybittyapps/appstoreconnect-cli#readme
[issues]: https://github.com/ittybittyapps/appstoreconnect-cli/issues
[new-issue]: https://github.com/ittybittyapps/appstoreconnect-cli/issues/new/choose
[github-terms-contribution]: https://help.github.com/en/github/site-policy/github-terms-of-service#6-contributions-under-repository-license
[code-of-conduct]: CODE_OF_CONDUCT.md
[core-contributor]: CORE_CONTRIBUTOR.md
[license]: LICENSE
[vision]: VISION.md
[apple]: https://apple.com
[appstore-connect-api]: https://developer.apple.com/app-store-connect/api/
[good-first-issue]: https://github.com/ittybittyapps/appstoreconnect-cli/labels/good%20first%20issue
[repo]: https://github.com/ittybittyapps/appstoreconnect-cli
[commit-messages]: https://chris.beams.io/posts/git-commit/
[fork-docs]: https://help.github.com/articles/working-with-forks/
[pr-template]: .github/PULL_REQUEST_TEMPLATE.md
[pr-docs]: https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/requesting-a-pull-request-review
