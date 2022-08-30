# React Micro Frontend Template

## Getting Started

Run the script to initialize the project and install dependencies:

```bash
./setup.sh
```

## Important notes

- Maintain consistency for the project name (all micro service and root project should have the same project name)

- Give the micro frontend a name

- Setup the HTML element where you want to inject your micro frontend

- This repository uses Semantic Release. If you don't want to use it:
  - Remove the step at `.github` or the entire folder
  - Remove `.releaserc` file
  - Remove `@semantic-release/changelog`, `@semantic-release/git`, `semantic-release` from `package.json`
