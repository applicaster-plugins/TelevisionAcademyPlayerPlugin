// @flow
import * as React from "react";
import {pathOr, default as R} from "ramda";
import {DeviceEventEmitter, Dimensions, requireNativeComponent, StyleSheet, View,NativeModules,NativeEventEmitter} from "react-native";
import {sendQuickBrickEvent} from "@applicaster/zapp-react-native-bridge/QuickBrick";
import SettingsView from '../SettingsView';
const { ZappPlugin } = NativeModules;
const eventEmitter = new NativeEventEmitter(NativeModules.PlayerView);
const PlayerView = requireNativeComponent("TVAQuickBrickPlayer");

type Props = {
  source: { uri: string },
  item: { content: {} },
  onEnd: any,
  onLoad: any,
  onError: any,
  playableItem: {},
  timeChanged: {},
  pluginConfiguration: {}
};

type State = {
  keyEvent: {}
};

export class AndroidPlayer extends React.Component<Props, State> {
  constructor(props) {
    super(props);
    this.state = {
      playerEvent: { keyCode: -1, code: "NONE" },
      settings: null,
      showOverlay: false,
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

  // == Next Video Overlay == //

  // TODO: move into a helper file
  getOverlayPlugin() {
    return R.compose(
      R.find(R.propEq("type", "player_overlay")),
      R.prop("plugins")
    )(this.props);
  }

  renderOverlay() {
    const { playableItem, navigator } = this.props;
    const { configuration, module: OverlayPluginComponent } = this.getOverlayPlugin() || {};
    const isPlayNextFeed = !!playableItem.extensions?.play_next_feed_url;

    if (isPlayNextFeed && OverlayPluginComponent) {
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


  onShowSettings = (event) => {
    this.setState({
      settings: event
    });
  };

  _onTimeChanged = (event) => {
    console.log('-----',event)
    const { playableItem } = this.props;
    const { showOverlay } = this.state;
    if (showOverlay) return; // stop if already showed

//    // video time
    const duration = event.duration;
    this.currentTime = event.time;
//
//    const overlayPlugin = this.getOverlayPlugin();
//    const playNextFeed = pathOr(undefined, ['extensions', 'play_next_field_url'], playableItem);
//    const overlayDuration = Number(pathOr(0, ["configuration", "overlay_duration"], overlayPlugin));
//    const overlayTrigger = (R.path(["configuration", "overlay_trigger"], overlayPlugin) === "onStart") ?
//      Number(duration - (duration - overlayDuration)) :
//      Number(duration - overlayDuration);
//
//    const triggerTime = Math.min(duration - overlayDuration, overlayTrigger);
//
//    if (playNextFeed && this.currentTime >= triggerTime && !showOverlay) {
//      this.setState({ showOverlay: true });
//    }
  };

  componentDidMount() {
    console.log('componentDidMount')
    DeviceEventEmitter.addListener("emitterOnLoad", this.onLoad);
    DeviceEventEmitter.addListener("emitterOnEnd", this.onEnd);
    DeviceEventEmitter.addListener("emitterOnError", this.onError);
    DeviceEventEmitter.addListener("onTvKeyDown", this.onKeyDown);
    DeviceEventEmitter.addListener("onShowSettings", this.onShowSettings);
    eventEmitter.addListener('onTimeChanged', this._onTimeChanged);
    sendQuickBrickEvent("blockTVKeyEmit", { blockTVKeyEmit: false });
//    this.timeout = setTimeout(this.retrievePluginConfiguration, 1);
//    this._isMounted = true;
  }

  componentWillUnmount() {
    DeviceEventEmitter.removeListener("emitterOnLoad", this.onLoad);
    DeviceEventEmitter.removeListener("emitterOnEnd", this.onEnd);
    DeviceEventEmitter.removeListener("emitterOnError", this.onError);
    DeviceEventEmitter.removeListener("onTvKeyDown", this.onKeyDown);

    DeviceEventEmitter.removeListener("onShowSettings", this.onShowSettings);
    eventEmitter.removeAllListeners('onTimeChanged');
    sendQuickBrickEvent("blockTVKeyEmit", { blockTVKeyEmit: true });
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
    this._isMounted = true;
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

  render() {
    const { timeChanged, playableItem, pluginConfiguration } = this.props;
    let configurations = {};
    if (pluginConfiguration) {
      configurations = pluginConfiguration["configuration_json"] || {}
    }

    const { playerEvent, settingsAction, settings, selectedSetting, showOverlay } = this.state;
    const { height, width } = Dimensions.get("window");
    let settingsView = null;
    if (settings) {
      settingsView = (
        <SettingsView
          style={styles.settingsContainer} settings={settings}
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
            this.setState({ settings: updatedSettings, selectedSetting, settingsAction: "back" })
          }}/>);
    }

    return (
      <React.Fragment>
        <View style={styles.container}>
          <PlayerView
            playableItem={playableItem}
            style={{ height, width }}
            onKeyChanged={playerEvent}
            pluginConfiguration={configurations}
            onSettingSelected={selectedSetting}
          />
          {settingsView}
          {this._isMounted && showOverlay && this.renderOverlay()}
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
}

const styles = StyleSheet.create({
  container: {},
  settingsContainer: {
    position: 'absolute',
    width: '100%',
    height: '100%'
  },
});
