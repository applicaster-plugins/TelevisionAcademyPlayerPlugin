import {AndroidPlayer} from "./android";
import {connectToStore} from "@applicaster/zapp-react-native-redux";

const storeConnector = connectToStore(state => ({
  pluginConfiguration:
    state.pluginConfigurations["tva-quick-brick-player-plugin"] || {}
}));
export default storeConnector(AndroidPlayer);
