// @flow
import * as React from "react";
import {DeviceEventEmitter, Dimensions, requireNativeComponent, StyleSheet, View,} from "react-native";
import {sendQuickBrickEvent} from "@applicaster/zapp-react-native-bridge/QuickBrick";
import {sessionStorage} from "@applicaster/zapp-react-native-bridge/ZappStorage/SessionStorage";

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

const NAMESPACE = "TelevisionAcademyPlayerPluginTV";

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
    this.timeout = setTimeout(this.retrievePluginConfiguration, 1);
  }

  componentWillUnmount() {
    DeviceEventEmitter.removeListener("emitterOnLoad", this.onLoad);
    DeviceEventEmitter.removeListener("emitterOnEnd", this.onEnd);
    DeviceEventEmitter.removeListener("emitterOnError", this.onError);
    DeviceEventEmitter.removeListener("onTvKeyDown", this.onKeyDown);
    sendQuickBrickEvent("blockTVKeyEmit", { blockTVKeyEmit: true });
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }

  render() {
    const { playableItem } = this.props;
    const { pluginConfiguration } = this.state;

    const { height, width } = Dimensions.get("window");
    return (
      <React.Fragment>
        <View style={styles.container}>
          <PlayerBridge
            style={{ height, width }}
            playableItem={playableItem}
            pluginConfiguration={pluginConfiguration}/>
        </View>
      </React.Fragment>
    );
  }

  retrievePluginConfiguration = async () => {
    try {
      const tempConfigurations = {
        "baseSkylarkUrl": "https://publicapi.feature.atas.ostm.io/api/v1",
        "testVideoSrc": "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
      };
      const baseSkylarkUrl = await sessionStorage.getItem("baseSkylarkUrl", NAMESPACE);
      const testVideoSrc = await sessionStorage.getItem("testVideoSrc", NAMESPACE);

      if (baseSkylarkUrl && testVideoSrc) {
        this.setState({ pluginConfiguration: { baseSkylarkUrl, testVideoSrc } })
      } else {
        this.setState({ pluginConfiguration: tempConfigurations })
      }
    } catch (e) {
      this.setState({ pluginConfiguration: tempConfigurations })
    }
  };
}

const styles = StyleSheet.create({
  container: {},
  settingsContainer: {
    position: 'absolute',
    width: '100%',
    height: '100%'
  },
});
