import {AndroidPlayer} from "./android";
import {connectToStore} from "@applicaster/zapp-react-native-redux";

const storeConnector = connectToStore(state => ({
  pluginConfiguration:
    state.pluginConfigurations["TelevisionAcademyPlayerPluginTV"] || {}
}));
export default storeConnector(AndroidPlayer);
