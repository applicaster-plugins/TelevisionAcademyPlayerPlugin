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
    this.state = {
      playerEvent: { keyCode: -1, code: "NONE" },
    };
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
      ...this.state,
      playerEvent: event
    });
    return true;
  }

  _onEnd = event => {
    if (this.props.onEnd) {
      this.props.onEnd(event.nativeEvent);
    }
  };

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

    const nativeProps = {
      ...this.props,
      ...{
        style: { height, width },
        playableItem,
        pluginConfiguration,
        onVideoEnd: this._onEnd,
      }
    };

    // TODO : THIS IS A WORKAROUND FOR FIX A BUG HAPPENS WHEN WHE CLICK BACK BUTTON ON REAL DEVICE
    // TODO : WE NEED FIND A BETTER SOLUTION ON THAT PLUGIN !
    const srcVideo = path(['content', 'src'], playableItem);
    if (!pluginConfiguration || !srcVideo.includes('https://')) {
      return <View/>
    }
    return (
      <React.Fragment>
        <View style={styles.container}>
          <PlayerBridge {...nativeProps}/>
        </View>
      </React.Fragment>
    );
  }

  retrievePluginConfiguration = async () => {
    try {
      const baseSkylarkUrl = await sessionStorage.getItem("baseSkylarkUrl", NAMESPACE);
      const testVideoSrc = await sessionStorage.getItem("test_video_url", NAMESPACE);
      this.setState({ pluginConfiguration: { baseSkylarkUrl, testVideoSrc } })
    } catch (e) {
      this.setState({ pluginConfiguration: {} })
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
