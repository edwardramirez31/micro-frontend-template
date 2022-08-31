# React Micro Frontend Template

## Getting Started

1. Run the script to initialize the project and install dependencies:

```bash
./setup.sh
```

2. Run `yarn start --port ${YOUR_PORT}` to run locally

3. Add your new micro frontend at the root config module inside

```html
<script type="systemjs-importmap">
  {
    "imports": {
      "react": "https://cdn.jsdelivr.net/npm/react@16.13.0/umd/react.production.min.js",
      "react-dom": "https://cdn.jsdelivr.net/npm/react-dom@16.13.0/umd/react-dom.production.min.js",
      "single-spa": "https://cdn.jsdelivr.net/npm/single-spa@5.3.0/lib/system/single-spa.min.js",
      "@${PROJECT_NAME}/root-config": "//localhost:9000/${PROJECT_NAME}-root-config.js",
      "@${PROJECT_NAME}/{MICRO_FRONTEND_NAME}": "//localhost:${YOUR_PORT}/${PROJECT_NAME}-{MICRO_FRONTEND_NAME}.js"
    }
  }
</script>
```

4. Register your micro frontend at `${PROJECT_NAME}-root-config.js`

```js
registerApplication(
  "${PROJECT_NAME}/{MICRO_FRONTEND_NAME}",
  () => System.import("${PROJECT_NAME}/{MICRO_FRONTEND_NAME}"),
  (location) => ${CODE_TO_VALIDATE_ROUTE_HERE}
);
// OR
registerApplication({
  name: "${PROJECT_NAME}/{MICRO_FRONTEND_NAME}",
  app: () => System.import("${PROJECT_NAME}/{MICRO_FRONTEND_NAME}"),
  activeWhen: ["/${YOUR_ROUTES}"],
});
```

Alternatively, add the `<application>` tag and its corresponding `<route>` if you are using the [Single SPA engine layout](https://single-spa.js.org/docs/layout-definition)

```html
<single-spa-router>
  <!-- Registering new micro frontend here (EXAMPLE) -->
  <route path="${YOUR_PATH}">
    <application name="@${PROJECT_NAME}/${MICRO_FRONTEND_NAME}"></application>
  </route>
</single-spa-router>
```

5. Make sure you have the HTML element with ID at the `root-project` in case you want to inject your micro frontend in a specific element.

```html
<div id="${YOUR_ELEMENT_ID}"></div>
```

> This is not recommended if you are using the Single SPA layout engine

6. Run `yarn start` to run your root config module

## Important notes

- Maintain consistency for the project name (all micro service and root project should have the same project name)

- Give the micro frontend a name

- It's not recommended to setup the HTML element where you want to inject your micro frontend if you are using the [Single SPA engine layout](https://single-spa.js.org/docs/layout-definition)

- It's recommended to use the root config module template from [this template](https://github.com/edwardramirez31/micro-frontend-root-template) to be consistent with project naming convention

- Set ACTIONS_DEPLOY_ACCESS_TOKEN secret at your repository with a GitHub Personal Access Token so that Semantic Release can work properly

  - This token should have full control of private repositories

- If you don't want to use Semantic Release:

  - Remove the step at `.github` or the entire folder
  - Remove `.releaserc` file
  - Remove `@semantic-release/changelog`, `@semantic-release/git`, `semantic-release` from `package.json`
