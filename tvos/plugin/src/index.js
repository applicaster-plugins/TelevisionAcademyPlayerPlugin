import * as R from "ramda";
import { connectToStore } from "@applicaster/zapp-react-native-redux";
import Player from "./player";

export default PlayerComponent = R.compose(
  connectToStore(R.pick(["plugins","item"])),
)(Player);


