jesttest_package_json='{ babel: { presets: ["env"] }, scripts: { test: "jest" } }'
jesttest_basic_test="test('adds 1 + 2 to equal 3', () => {\\n  expect(sum(1, 2)).toBe(3);\\n});"
alias jesttest="take \`mktemp -d\` && npm init -y && \
  echo 'node_modules/' > .gitignore && \
  npm install -D babel-preset-env jest jest-babel && \
  jq '. + $jesttest_package_json' package.json | sponge package.json && \
  echo "'"'"$jesttest_basic_test"'"'" > index.test.js && \
  vim . && \
  npm test -- --watch --notify"

alias npmtest="take \`mktemp -d\` && npm init -y && touch index.js && \
  echo 'node_modules/' > .gitignore && \
  vim ."

