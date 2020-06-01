// @flow
import * as React from "react";
import * as R from "ramda";
import { DeviceEventEmitter, Dimensions, requireNativeComponent, StyleSheet, View, Text } from "react-native";
import { sendQuickBrickEvent } from "@applicaster/zapp-react-native-bridge/QuickBrick";
import { sessionStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/SessionStorage";
import { withNavigator } from '@applicaster/zapp-react-native-ui-components/Decorators/Navigator/';

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
type State = {
  showOverlay: boolean,
};
const NAMESPACE = "TelevisionAcademyPlayerPluginTV";

class VideoPlayerComponent extends React.Component<Props, State> {
  constructor(props) {
    super(props);
    this.state = {
      playerEvent: { keyCode: -1, code: "NONE" },
      showOverlay: false
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
    const { navigator } = this.props
    if (this.props.onEnd) {
      this.props.onEnd(event.nativeEvent);
      navigator.canGoBack() && navigator.goBack();
    }
  };

  componentDidMount() {
    DeviceEventEmitter.addListener("emitterOnLoad", this.onLoad);
    DeviceEventEmitter.addListener("emitterOnEnd", this.onEnd);
    DeviceEventEmitter.addListener("emitterOnError", this.onError);
    DeviceEventEmitter.addListener("onTvKeyDown", this.onKeyDown);
    sendQuickBrickEvent("blockTVKeyEmit", { blockTVKeyEmit: false });
    this.timeout = setTimeout(this.retrievePluginConfiguration, 1);
    this._isMounted = true;
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

  // Overlay Methods ---------------------------------------------
  renderOverlay() {
    const { playableItem, navigator } = this.props;

    const { configuration, module: OverlayPluginComponent } =
      this.getOverlayPlugin() || {};

    const isPlayNextFeed = !!playableItem.extensions?.play_next_feed_url;

    if (isPlayNextFeed) {
      return (
        <OverlayPluginComponent
          playableItem={playableItem}
          configuration={configuration}
          navigator={navigator}
          dismissOverlay={(cb = noop) => {
            if (this._isMounted) {
              this.setState({ showOverlay: false }, cb);
            }
          }}
        />
      );
    }
  }

  _onTimeChanged = event => {
    const { playableItem, navigator } = this.props;
    const { showOverlay } = this.state;

    const duration = event.nativeEvent.duration;
    this.currentTime = event.nativeEvent.time;

    const isPlayNextFeed = !!playableItem.extensions?.play_next_feed_url;

    const overlayPlugin = this.getOverlayPlugin();

    const overlayDuration =
      Number(R.path(["configuration", "overlay_duration"], overlayPlugin)) || 0;

    // eslint-disable-next-line max-len
    const overlayTrigger = (R.path(["configuration", "overlay_trigger"], overlayPlugin) === "onStart") ? Number(duration - (duration - overlayDuration)) : Number(duration - overlayDuration)

    const triggerTime = Math.min(duration - overlayDuration, overlayTrigger);

    if (isPlayNextFeed && this.currentTime >= triggerTime && !showOverlay) {
      this.setState({ showOverlay: true });
    }
  };

  getOverlayPlugin() {
    return R.compose(
      R.find(R.propEq("type", "player_overlay")),
      R.prop("plugins")
    )(this.props);
  }
  // Overlay Methods ---------------------------------------------

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
        onVideoTimeChanged: this._onTimeChanged,
      }
    };

    const showOverlay = this.state.showOverlay;

    // TODO : THIS IS A WORKAROUND FOR FIX A BUG HAPPENS WHEN WHE CLICK BACK BUTTON ON REAL DEVICE
    // TODO : WE NEED FIND A BETTER SOLUTION ON THAT PLUGIN !
    const srcVideo = R.path(['content', 'src'], playableItem);
    if (!pluginConfiguration || !srcVideo.includes('https://')) {
      return <View />
    }
    return (
      <React.Fragment>
        <View style={styles.container}>
          <PlayerBridge {...nativeProps}>
            {this._isMounted === true && showOverlay && this.renderOverlay()}
          </PlayerBridge>
        </View>
      </React.Fragment>
    );
  }

  retrievePluginConfiguration = async () => {
    try {
      const baseSkylarkUrl = await sessionStorage.getItem("baseSkylarkUrl", NAMESPACE);
      const testVideoSrc = await sessionStorage.getItem("test_video_url", NAMESPACE);
      const bitmovinAnalyticLicenseKey = await sessionStorage.getItem("BitmovinAnalyticLicenseKey", NAMESPACE);
      const bitmovinPlayerLicenseKey = await sessionStorage.getItem("plist.BitmovinPlayerLicenseKey", NAMESPACE);
      const heartbeatInterval = await sessionStorage.getItem("heartbeat_interval", NAMESPACE);
      this.setState({
        pluginConfiguration: {
          baseSkylarkUrl,
          testVideoSrc,
          bitmovinAnalyticLicenseKey,
          bitmovinPlayerLicenseKey,
          heartbeatInterval
        }
      })
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
export const VideoPlayer = withNavigator(VideoPlayerComponent);
