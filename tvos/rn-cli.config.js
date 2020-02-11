const { resolve } = require("path");

const config = {
  resolver: {
    extraNodeModules: {
      "react-native": resolve(__dirname, "./node_modules/react-native")
    }
  },
  projectRoot: resolve(__dirname, "./development-app"),
  watchFolders: [resolve(__dirname, "./plugin"), resolve(__dirname)]
};

module.exports = config;