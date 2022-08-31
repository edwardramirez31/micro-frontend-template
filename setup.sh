#!/bin/bash

re=^[A-Za-z0-9_-]+$

project=""
while ! [[ "${project?}" =~ ${re} ]]
do
  read -p "🔷 Enter the project name (can use letters, numbers, dash or underscore): " project
done

service=""
while ! [[ "${service?}" =~ ${re} ]]
do
  read -p "🔷 Enter the micro frontend name (can use letters, numbers, dash or underscore): " service
done

while true; do
    echo "🔷 Do you want to inject this micro frontend in a specific HTML element at root?"
    read -p "⚠️  It's not recommended if you are using the Single SPA Layout Engine. Enter yes or no [y/N]: " yn
    case $yn in
        [Yy]* )
          domContainerElement=""
          while ! [[ "${domContainerElement?}" =~ ${re} ]]
          do
            read -p "🔷 Enter the HTML element ID where your service will be injected (letters, numbers, dash or underscore): " domContainerElement
          done
          sed -i "s/mf-content/$domContainerElement/g" src/project-micro-frontend-name.tsx
          break
        ;;
        [Nn]* ) sed -i '/domElementGetter,/d' src/project-micro-frontend-name.tsx; break;;
        * ) echo "Please answer yes or no like: [y/N]";;
    esac
done



repository=""
currentRepo="https://github.com/edwardramirez31/micro-frontend-template"
read -p "🔷 Enter your GitHub repository URL name to add semantic release: " repository
sed -i "s,$currentRepo,$repository,g" .releaserc

sed -i "s/project/$project/g" package.json
sed -i "s/micro-frontend-name/$service/g" package.json
sed -i "s/project-micro-frontend-name/$project-$service/g" tsconfig.json
sed -i "s/'project'/'$project'/g" webpack.config.js
sed -i "s/micro-frontend-name/$service/g" webpack.config.js
mv src/project-micro-frontend-name.tsx "src/$project-$service.tsx"


echo "🔥🔨 Installing dependencies"
yarn install
echo "🔥⚙️ Installing Git Hooks"
yarn husky install
echo "🚀🚀 Project setup complete!"
echo "💡 Steps to test your React single-spa application:"
echo "✔️ Run 'yarn start --port 8500'"
echo "✔️ Go to http://single-spa-playground.org/playground/instant-test?name=@$project/$service&url=8500 to see it working!"
