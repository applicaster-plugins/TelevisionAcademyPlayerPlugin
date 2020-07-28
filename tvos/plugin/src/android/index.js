// @flow
import * as React from "react";
import {DeviceEventEmitter, Dimensions, requireNativeComponent, StyleSheet, View} from "react-native";
import {sendQuickBrickEvent} from "@applicaster/zapp-react-native-bridge/QuickBrick";
import SettingsView from '../SettingsView';

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
  keyEvent: {}
};

export class AndroidPlayer extends React.Component<Props, State> {
  constructor(props) {
    super(props);
    this.state = {
      playerEvent: { keyCode: -1, code: "NONE" },
      settings: null
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
    sendQuickBrickEvent("blockTVKeyEmit", { blockTVKeyEmit: false });
  }

  componentWillUnmount() {
    DeviceEventEmitter.removeListener("emitterOnLoad", this.onLoad);
    DeviceEventEmitter.removeListener("emitterOnEnd", this.onEnd);
    DeviceEventEmitter.removeListener("emitterOnError", this.onError);
    DeviceEventEmitter.removeListener("onTvKeyDown", this.onKeyDown);
    DeviceEventEmitter.removeListener("onShowSettings", this.onShowSettings);
    sendQuickBrickEvent("blockTVKeyEmit", { blockTVKeyEmit: true });
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

  onVideoEnd = () => {
    console.log("on video end");
  };

  onVideoProgress = (currentTime, playableDuration, seekableDuration) => {
    console.log("on video progress");
  };

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
            onVideoEnd={this.onVideoEnd}
            onVideoProgress={this.onVideoProgress}
          />
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
}

const styles = StyleSheet.create({
  container: {},
  settingsContainer: {
    position: 'absolute',
    width: '100%',
    height: '100%'
  },
});
