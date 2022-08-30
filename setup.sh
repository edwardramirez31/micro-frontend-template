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

domContainerElement=""
while ! [[ "${domContainerElement?}" =~ ${re} ]]
do
  read -p "🔷 Enter the HTML element ID where your service will be injected (letters, numbers, dash or underscore): " domContainerElement
done

repository=""
currentRepo="https://github.com/edwardramirez31/micro-frontend-template"
read -p "🔷 Enter your GitHub repository URL name to add semantic release: " repository
echo $repository
sed -i "s/$currentRepo/$repository/g" .releaserc
rm CHANGELOG.md

sed -i "s/project/$project/g" package.json
sed -i "s/micro-frontend-name/$service/g" package.json
sed -i "s/project-micro-frontend-name/$project-$service/g" tsconfig.json
sed -i "s/'project'/'$project'/g" webpack.config.js
sed -i "s/micro-frontend-name/$service/g" webpack.config.js
mv src/project-micro-frontend-name.tsx "src/$project-$service.tsx"
sed -i "s/mf-content/$domContainerElement/g" "src/$project-$service.tsx"


echo "🔥🔨 Installing dependencies"
# yarn install
echo "🔥⚙️ Installing Git Hooks"
# yarn husky install
echo "🚀🚀 Project setup complete!"
echo "💡 Steps to test your React single-spa application:"
echo "✔️ Run 'yarn start --port 8500'"
echo "✔️ Go to http://single-spa-playground.org/playground/instant-test?name=@my-org/my-proj&url=8500 to see it working!"
