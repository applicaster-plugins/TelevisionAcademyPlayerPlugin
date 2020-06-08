import * as R from "ramda";
import { connectToStore } from "@applicaster/zapp-react-native-redux";
import Player from "./player";

const ConnectedComponent = connectToStore(R.pick(["plugins","item"]));

export default ConnectedComponent(Player)
