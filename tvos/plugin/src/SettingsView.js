import React, {PureComponent} from 'react';
import {Image, StyleSheet, Text, View} from 'react-native';
import PropTypes from 'prop-types';

const styles = StyleSheet.create({
  container: {
    flexDirection: 'column',
    alignItems: 'center',
    backgroundColor: '#00000099',
    justifyContent: 'center'
  },
  textContainer: {
    height: 90,
    flexDirection: 'row',
    borderBottomWidth: 1,
    borderBottomColor: 'gray',
    paddingLeft: 30,
    paddingRight: 30,
    alignItems: 'center'
  },
  selectedTextContainer: { backgroundColor: "#FFF5" },
  settingTitleText: {
    fontSize: 33,
    width: 330,
    color: 'white'
  },
  settingValueText: {
    fontSize: 33,
    width: 300,
    color: "#28AAE0",
  },
  image: {
    marginLeft: 50,
    width: 40,
    height: 90,
    resizeMode: 'center'
  }
});

export default class SettingsView extends PureComponent {

  state = { selectedIndex: 0 };

  render() {
    const { settings, keyAction, onSettingSelected } = this.props;

    let { showSettings, selectedIndex } = this.state;

    let selectedList = showSettings ? showSettings.available : settings;
    if (keyAction === "down") {
      selectedIndex++;
      selectedIndex = selectedIndex % selectedList.length
    } else if (keyAction === "up") {
      selectedIndex--;
      selectedIndex = (selectedIndex + selectedList.length) % selectedList.length
    } else if (keyAction === "enter") {
      if (showSettings) {
        const selectedSetting = showSettings.available[selectedIndex];
        onSettingSelected(selectedSetting);
        showSettings = null;
      } else {
        showSettings = settings[selectedIndex]
      }
      selectedIndex = 0;
    } else if (keyAction === "back") {
      showSettings = null;
    }
    this.state = { selectedIndex, showSettings };

    return (
      <View style={[styles.container, this.props.style]}>
        {!showSettings ? settings.map((setting, index) => {
          return (
            <View
              key={setting.title}
              style={[styles.textContainer, (index === selectedIndex) ? styles.selectedTextContainer : null]}>
              <Text style={styles.settingTitleText} key={setting.title}>{setting.title}</Text>
              <Text style={styles.settingValueText} key={setting.subtitle}>{setting.subtitle}</Text>
              <Image source={require('./img/drop-down-arrow.png')} style={styles.image}/>
            </View>
          )
        }) : showSettings.available.map((setting, index) => {
          return (
            <View
              key={setting.title}
              style={[styles.textContainer, (index === selectedIndex) ? styles.selectedTextContainer : null]}>
              <Text style={styles.settingTitleText}>{setting.title}</Text>
              <Image
                source={(showSettings.selectedId === setting.id) ? require('./img/checkmark.png') : null}
                style={styles.image}/>
            </View>
          )
        })}
      </View>)
  }
}

SettingsView.propTypes = {
  settings: PropTypes.array.isRequired,
  keyAction: PropTypes.string,
  onSettingSelected: PropTypes.func.isRequired
};
