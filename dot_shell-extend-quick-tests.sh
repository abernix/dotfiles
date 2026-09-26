alias npmtest="take \`mktemp -d\` && npm init -y && touch index.js && \
  echo 'node_modules/' > .gitignore && \
  vim ."

