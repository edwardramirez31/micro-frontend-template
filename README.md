# React Micro Frontend Template

## Getting Started

1. Run the script to initialize the project and install dependencies:

```bash
./setup.sh
```

2. Run `yarn start --port ${YOUR_PORT}` to run locally

3. Add your new micro frontend at the root config module inside root `index.ejs` or use [Import Map Deployer](https://github.com/edwardramirez31/import-map-deployer)

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

7. Set `devtools` local storage key at browser console, whether your root module is running locally or it's using prod or dev environment.

```js
localStorage.setItem('devtools', true);
```

- This will use [import-map-overrides](https://github.com/single-spa/import-map-overrides/blob/main/docs/ui.md) extension. This way, you can point the import map to your micro frontend that is running locally. Extension docs here [here](https://github.com/single-spa/import-map-overrides)

## Secrets

Setup secrets for S3 bucket names and roles to deploy to AWS at GitHub actions files. Secrets needed are:

- `ACTIONS_DEPLOY_ACCESS_TOKEN`: GitHub token used by Semantic Release
- `FRONTEND_DEPLOYMENT_ROLE`: IAM Role ARN
- `BUCKET_NAME`: S3 Bucket name
- `MICRO_FRONTEND_NAME`: Micro frontend name. This will be used to create a folder where you will have your micro frontend deployed JS files
- `IMD_USERNAME`: Username to authenticate in case you are using import map deployer
- `IMD_PASSWORD`: Password to authenticate in case you are using import map deployer
- `IMD_HOST`: Import map deployer domain name (without https)
- `IMD_ENVIRONMENT`: Import map deployer environment that you want to update (prod, dev, staging)
- `CLOUDFRONT_HOST`: Cloud front domain name (without https). This can also be Route 53, or S3 bucket domain in case you are not using CloudFront to host your import map JSON file.

> This secrets should contain production values. Then, you can override secrets using Environment Secrets

## Environments

- Create `Development` and `Production` environments and set each one to deploy from `dev` and `master` branches (Selected Branches rule)

- Each environment should have its own S3 Bucket, IAM Role for deployment and CloudFront distribution

- Setup environment secrets at `Development` so that the development `FRONTEND_DEPLOYMENT_ROLE` points to a role that will interact with the development S3 `BUCKET_NAME`

- Override `IMD_ENVIRONMENT` at Development Env Secret so that it points to dev, test or whatever name you gave to this env in your import map deployer server

- Change `environment-url` input passed down to deployment workflow so that each env will point to the corresponding CloudFront or Route 53 url

- Set `run-import-map-deployer` to true if you already stored the required import map secrets

## Import Map Deployer

- It's highly recommended to use [Import Map Deployer](https://github.com/edwardramirez31/import-map-deployer) so that this root repo will get the micro frontend imports from a dynamic import map JSON file. If you don't want to use it, remove the following lines at `.github/workflows/build_and_deploy.yml`

```yml
- name: Update import map
  run: curl -u ${USERNAME}:${PASSWORD} -d '{ "service":"@{YOUR_ORGANZATION_NAME}/'"${MICRO_FRONTEND_NAME}"'","url":"https://'"${CLOUDFRONT_HOST}"'/'"${MICRO_FRONTEND_NAME}"'/'"${IDENTIFIER}"'/'{YOUR_ORGANZATION_NAME}-"${MICRO_FRONTEND_NAME}"'.js" }' -X PATCH https://${IMD_HOST}/services/\?env=prod -H "Accept:application/json" -H "Content-Type:application/json"
  env:
    USERNAME: ${{ secrets.IMD_USERNAME }}
    PASSWORD: ${{ secrets.IMD_PASSWORD }}
    MICRO_FRONTEND_NAME: ${{ secrets.MICRO_FRONTEND_NAME }}
    CLOUDFRONT_HOST: ${{ secrets.CLOUDFRONT_HOST }}
    IMD_HOST: ${{ secrets.IMD_HOST }}
    IDENTIFIER: ${{ github.sha }}
```

- It will send a patch request to your import map deployer server located at `${IMD_HOST}` domain name, at `/services` endpoint.

  - It sends a JSON body with the service that it want to update and the url key value pair containing the new utility module url.
  - It also sends the import map username and password in order to authenticate with the server

- If you are not using Import Map Deployer, add your compiled JS utility code at the root module import maps

  ```html
  <% if (isLocal) { %>
  <script type="systemjs-importmap">
    {
      "imports": {
        "@${PROJECT_NAME}/root-config": "//localhost:9000/${PROJECT_NAME}-root-config.js",
        "@${PROJECT_NAME}/{UTILITY_MODULE_NAME}": "//localhost:${YOUR_PORT}/${PROJECT_NAME}-{UTILITY_MODULE_NAME}.js"
      }
    }
  </script>
  <% } else { %>
  <script type="systemjs-importmap">
    {
      "imports": {
        "@${PROJECT_NAME}/root-config": "https://{S3_BUCKET_NAME}.s3.amazonaws.com/${PROJECT_NAME}-root-config.js",
        "@${PROJECT_NAME}/{UTILITY_MODULE_NAME}": "https://{S3_BUCKET_NAME}.s3.amazonaws.com/${PROJECT_NAME}-{UTILITY_MODULE_NAME}.js"
      }
    }
  </script>
  <% } %>
  ```

## Semantic Release

- Set `ACTIONS_DEPLOY_ACCESS_TOKEN` secret at your repository with a GitHub Personal Access Token so that Semantic Release can work properly

  - This token should have full control of private repositories

- If you don't want to use Semantic Release:

  - Remove the step at `.github` or the entire folder
  - Remove `.releaserc` file
  - Remove `@semantic-release/changelog`, `@semantic-release/git`, `semantic-release` from `package.json`

## Deployment in AWS

- Build the project with `yarn build` and deploy the files to a CDN (CloudFront + S3) or host to serve those static files.

- According with `.github/workflows/main.yml`, the action will assume a role through GitHub OIDC and AWS STS. This role has permissions to put new objects in your S3 bucket

  - This action step will send the build files generated at `dist` folder to `s3://${BUCKET_NAME}/${MICRO_FRONTEND_NAME}/${IDENTIFIER}`
  - That way, it will store your utility compiled code at the same folder `${MICRO_FRONTEND_NAME}` and store each new version with GitHub Commit SHA `${IDENTIFIER}`

- Import map deployer step then will update `import-map.json` file in your S3 bucket with the new compiled file route

- All the instructions to deploy the whole infrastructure to AWS are at [Micro Frontend Root Documentation](https://github.com/edwardramirez31/micro-frontend-root-layout)

## Important notes

- Maintain consistency for the project name (all micro service and root project should have the same project name)

- Give the micro frontend a name

- It's not recommended to setup the HTML element where you want to inject your micro frontend if you are using the [Single SPA engine layout](https://single-spa.js.org/docs/layout-definition)

- It's recommended to use the root config module template from [this template](https://github.com/edwardramirez31/micro-frontend-root-template) to be consistent with project naming convention
