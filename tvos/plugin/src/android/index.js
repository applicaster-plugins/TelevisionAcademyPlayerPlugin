// @flow
import * as React from "react";
import { DeviceEventEmitter, Dimensions, requireNativeComponent, StyleSheet, View } from "react-native";
import { sendQuickBrickEvent } from "@applicaster/zapp-react-native-bridge/QuickBrick";
import SettingsView from '../SettingsView';
import * as R from "ramda";
import { withNavigator } from '@applicaster/zapp-react-native-ui-components/Decorators/Navigator/';

const PlayerView = requireNativeComponent("TVAQuickBrickPlayer");

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
  keyEvent: {}
};

class VideoPlayerComponent extends React.Component<Props, State> {
  constructor(props) {
    super(props);
    this.state = {
      playerEvent: { keyCode: -1, code: "NONE" },
      settings: null,
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

  onShowSettings = (event) => {
    typeof event == "object" && event instanceof Array && event.length == 0 ? 
    this.setState({
      settings: null
    }) :
    this.setState({
      settings: event
    });
  };

  componentDidMount() {
    DeviceEventEmitter.addListener("emitterOnLoad", this.onLoad);
    DeviceEventEmitter.addListener("emitterOnEnd", this.onEnd);
    DeviceEventEmitter.addListener("emitterOnError", this.onError);
    DeviceEventEmitter.addListener("onTvKeyDown", this.onKeyDown);
    DeviceEventEmitter.addListener("onShowSettings", this.onShowSettings);
    sendQuickBrickEvent("blockTVKeyEmit", { blockTVKeyEmit: true });
    this.timeout = setTimeout(this.retrievePluginConfiguration, 1);
    this._isMounted = true;
  }

  componentWillUnmount() {
    DeviceEventEmitter.removeListener("emitterOnLoad", this.onLoad);
    DeviceEventEmitter.removeListener("emitterOnEnd", this.onEnd);
    DeviceEventEmitter.removeListener("emitterOnError", this.onError);
    DeviceEventEmitter.removeListener("onTvKeyDown", this.onKeyDown);
    DeviceEventEmitter.removeListener("onShowSettings", this.onShowSettings);
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }

  onKeyDown(event) {
    let { settings } = this.state;
    if (settings) {
      const keyEventAction = this.keyEventToAction(event);
      if (keyEventAction === "back" || keyEventAction === "menu") {
        settings = null;
      }
      this.setState({
        settings,
        settingsAction: keyEventAction,
      });
    } else {
      this.setState({
        playerEvent: event
      });
    }
    return true;
  }

  onVideoStart = () => {};

  onVideoEnd = (event) => {
    const { navigator } = this.props
    const overlay = this.state.showOverlay;

    if (this.props.onEnded && (!overlay)) {
      this.props.onEnded(event.nativeEvent);
      navigator.canGoBack() && navigator.goBack();
    }
  };

  onVideoPause = () => {};

  onVideoProgress = (event) => {
    const { playableItem } = this.props;
    const { showOverlay } = this.state;

    const duration = event.nativeEvent.playableDuration;
    this.currentTime = event.nativeEvent.currentTime;

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
  
  onVideoSeek = (event) => {};
  onVideoError = (event) => {};

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

  getOverlayPlugin() {
    return R.compose(
      R.find(R.propEq("type", "player_overlay")),
      R.prop("plugins")
    )(this.props);
  }

  render() {
    const { playableItem, pluginConfiguration } = this.props;
    let configurations = {};
    if (pluginConfiguration) {
      configurations = pluginConfiguration["configuration_json"] || {}
    }

    const { playerEvent, settingsAction, settings, selectedSetting } = this.state;
    const { height, width } = Dimensions.get("window");
    let settingsView = null;
    if (settings) {
      settingsView = (
        <SettingsView style={styles.settingsContainer} settings={settings}
          keyAction={settingsAction}
          onSettingSelected={(selectedSetting) => {
            const updatedSettings = settings.map(setting => {
              if (setting.type === selectedSetting.type) {
                return {
                  ...setting,
                  ...{ selectedId: selectedSetting.id },
                  subtitle: selectedSetting.title
                }
              } else {
                return setting
              }
            });
            this.setState({ settings: null, selectedSetting, settingsAction: "back" })
          }} />);
    }

    const showOverlay = this.state.showOverlay;

    return (
      <React.Fragment>
        <View style={styles.container}>
          <PlayerView
            playableItem={playableItem}
            style={{ height, width }}
            onKeyChanged={playerEvent}
            pluginConfiguration={configurations}
            onSettingSelected={selectedSetting}
            eventVideoStart={this.onVideoStart}
            onVideoEnd={this.onVideoEnd}
            eventVideoPause={this.onVideoPause}
            onVideoProgress={this.onVideoProgress}
            onVideoSeek={this.onVideoSeek}
            onVideoError={this.onVideoError}
          />
          {this._isMounted === true && showOverlay && this.renderOverlay()}
          {settingsView}
        </View>
      </React.Fragment>
    );
  }

  keyEventToAction = (keyEvent) => {
    if (keyEvent.keyCode === 19) {
      return "up"
    } else if (keyEvent.keyCode === 20) {
      return "down"
    } else if (keyEvent.keyCode === 23 || keyEvent.keyCode === 22) {
      return "enter"
    } else if (keyEvent.keyCode === 4 || keyEvent.keyCode === 21) {
      return "back"
    } else if (keyEvent.keyCode === 82) {
      return "menu"
    }
    return "";
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

export const AndroidPlayer = withNavigator(VideoPlayerComponent);
