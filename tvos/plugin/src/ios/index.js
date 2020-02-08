// @flow
import * as React from "react";
import {DeviceEventEmitter, Dimensions, requireNativeComponent, StyleSheet, View,} from "react-native";
import {sendQuickBrickEvent} from "@applicaster/zapp-react-native-bridge/QuickBrick";

const PlayerBridge = requireNativeComponent("PlayerBridge");

type Props = {
  source: { uri: string },
  item: { content: {} },
  onEnd: any,
  onLoad: any,
  onError: any,
  playableItem: {},
  pluginConfiguration: {}
};

type State = {};

export class VideoPlayer extends React.Component<Props, State> {
  constructor(props) {
    super(props);
    this.state = {};
    this.onLoad = this.onLoad.bind(this);
    this.onError = this.onError.bind(this);
    this.onEnd = this.onEnd.bind(this);
    this.onKeyDown = this.onKeyDown.bind(this);
  }

  onLoad(event) {
  }

  onError(event) {
  }

  onEnd(event) {
  }

  onKeyDown(event) {
    this.setState({
      playerEvent: event
    });
    return true;
  }

  componentDidMount() {
    DeviceEventEmitter.addListener("emitterOnLoad", this.onLoad);
    DeviceEventEmitter.addListener("emitterOnEnd", this.onEnd);
    DeviceEventEmitter.addListener("emitterOnError", this.onError);
    DeviceEventEmitter.addListener("onTvKeyDown", this.onKeyDown);
    sendQuickBrickEvent("blockTVKeyEmit", { blockTVKeyEmit: false });
  }

  componentWillUnmount() {
    DeviceEventEmitter.removeListener("emitterOnLoad", this.onLoad);
    DeviceEventEmitter.removeListener("emitterOnEnd", this.onEnd);
    DeviceEventEmitter.removeListener("emitterOnError", this.onError);
    DeviceEventEmitter.removeListener("onTvKeyDown", this.onKeyDown);
    sendQuickBrickEvent("blockTVKeyEmit", { blockTVKeyEmit: true });
  }

  render() {
    const { playableItem, pluginConfiguration } = this.props;
    let configurations = {};
    if (pluginConfiguration) {
      configurations = pluginConfiguration["configuration_json"] || {}
    }

    //Temp solution. Need to understand how recieve configuration_json
    configurations = {
      "baseSkylarkUrl": "https://publicapi.feature.atas.ostm.io/api/v1",
      "testVideoSrc": "http://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
    };

    const { height, width } = Dimensions.get("window");
    return (
      <React.Fragment>
        <View style={styles.container}>
          <PlayerBridge
            style={{ height, width }}
            playableItem={playableItem}
            pluginConfiguration={configurations}/>
        </View>
      </React.Fragment>
    );
  }
}

const styles = StyleSheet.create({
  container: {},
  settingsContainer: {
    position: 'absolute',
    width: '100%',
    height: '100%'
  },
});
