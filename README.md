# Github.com Automation Tool

Can be used to apply default configuration to Github repositories.

## Use-Case

To ensure that github.com repositories are set up consistently the script in this project can be used to automatically apply default settings. The tool allows to create issue labels and can import an issue template.

## Current State

 - Issue labels must be manually configured in code
 - The ISSUE_TEMPLATE.md can be adapted and will be imported to `.github`. If `.github/ISSUE_TEMPLATE.md` already exists the existing version will be kept.

## Usage

Just run the file `github.sh` with two parameters `owner` and `repo`.

```bash
./github.sh steima github-automation
```

Credentials will be queried on the commandline.
