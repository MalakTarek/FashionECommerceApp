module.exports = [
  {
    files: ["**/*.js"], // Adjust this pattern to match the files you want to lint
    languageOptions: {
      ecmaVersion: 2018,
      sourceType: "module",
      globals: {
        // Define your environment globals here
        es6: true,
        node: true,
      },
    },
    rules: {
      "no-restricted-globals": ["error", "name", "length"],
      "prefer-arrow-callback": "error",
      "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    },
  },
  {
    files: ["**/*.spec.*"],
    languageOptions: {
      globals: {
        mocha: true,
      },
    },
    rules: {
      // Override or add specific rules for test files if needed
    },
  },
];
