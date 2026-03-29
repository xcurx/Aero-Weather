import QtQuick
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import "components" as Components
import org.kde.kirigami as Kirigami

Item {
    id: fullRepresentationRoot

    readonly property int popupPadding: Kirigami.Units.smallSpacing
    readonly property real popupPreferredWidth: Kirigami.Units.gridUnit * 14
    readonly property real popupPreferredHeight: Kirigami.Units.gridUnit * 10
    readonly property real popupMaxWidth: Kirigami.Units.gridUnit * 16
    readonly property real popupMaxHeight: Kirigami.Units.gridUnit * 12

    implicitWidth: Math.min(Math.max(contentLayout.implicitWidth + (popupPadding * 2), popupPreferredWidth), popupMaxWidth)
    implicitHeight: Math.min(Math.max(contentLayout.implicitHeight + (popupPadding * 2), popupPreferredHeight), popupMaxHeight)
    Layout.minimumWidth: popupPreferredWidth
    Layout.minimumHeight: popupPreferredHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.maximumWidth: popupMaxWidth
    Layout.maximumHeight: popupMaxHeight

    Components.WeatherData {
        id: weatherData
    }

    property int temperatureUnit: Plasmoid.configuration.temperatureUnit
    property color fontColorResolved: root.useCustomFontColor ? root.fontColor : Kirigami.Theme.textColor

    function sumarDia(a) {
        var currentDay = (new Date()).getDay()
        var day = ((currentDay + a) % 7 ) === 7 ? 0 : (currentDay + a) % 7
        return day
    }

    property string tomorrow: sumarDia(1)
    property string dayAftertomorrow: sumarDia(2)
    property string twoDaysAfterTomorrow: sumarDia(3)

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: popupPadding
        spacing: Kirigami.Units.smallSpacing

        // --- Offline / Error State ---
        Item {
            id: offlineState
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: visible ? 1 : 0
            visible: !weatherData.dataAvailable

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Icon {
                    source: weatherData.networkError ? "network-disconnect" : (weatherData.isDay ? "weather-clear" : "weather-clear-night")
                    Layout.preferredWidth: Kirigami.Units.iconSizes.large
                    Layout.preferredHeight: Kirigami.Units.iconSizes.large
                    Layout.alignment: Qt.AlignHCenter
                    opacity: 0.6
                }

                PlasmaComponents3.Label {
                    text: weatherData.networkError
                          ? i18n("No Internet Connection")
                          : i18n("Loading weather data…")
                    font.pixelSize: Kirigami.Units.gridUnit
                    font.weight: Font.DemiBold
                    color: fontColorResolved
                    opacity: 0.9
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                PlasmaComponents3.Label {
                    text: weatherData.networkError
                          ? i18n("Please check your network and try again.")
                          : i18n("Fetching the latest weather information.")
                    font.pixelSize: Kirigami.Units.gridUnit * 0.8
                    color: fontColorResolved
                    opacity: 0.55
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.maximumWidth: parent.width * 0.8
                }

                PlasmaComponents3.Button {
                    text: i18n("Retry")
                    icon.name: "view-refresh"
                    visible: weatherData.networkError
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        weatherData.updateWeather(1);
                    }
                }
            }
        }

        // --- Normal Weather Content ---
        Item {
            id: currentWeather
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: visible ? Kirigami.Units.gridUnit * 5.4 : 0
            visible: weatherData.dataAvailable
            
            Column {
                id: currentSection
                width: parent.width
                height: temperatura.implicitHeight + longweathertext.implicitHeight + probText.implicitHeight
                anchors.centerIn: parent
                spacing: 0

                PlasmaComponents3.Label {
                    id: temperatura
                    text: temperatureUnit === 0 ? weatherData.temperaturaActual + "°C" : weatherData.temperaturaActual + "°F"
                    width: parent.width
                    font.pixelSize: Kirigami.Units.gridUnit * 3
                    color: fontColorResolved
                    horizontalAlignment: Text.AlignHCenter
                }
                PlasmaComponents3.Label {
                    id: longweathertext
                    text: weatherData.weatherLongtext
                    width: parent.width
                    font.pixelSize: Kirigami.Units.gridUnit * 1.2
                    color: fontColorResolved
                    horizontalAlignment: Text.AlignHCenter
                }
                PlasmaComponents3.Label {
                    id: probText
                    text: weatherData.textProbability + ": " + weatherData.probabilidadDeLLuvia + "%"
                    width: parent.width
                    font.pixelSize: Kirigami.Units.gridUnit * 0.8
                    color: fontColorResolved
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Row {
            id: forecastSection
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: visible ? Kirigami.Units.gridUnit * 4 : 0
            spacing: 0
            visible: weatherData.dataAvailable

            Repeater {
                model: 3
                delegate: Column {
                    height: parent.height
                    width: parent.width / 3
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents3.Label {
                        width: parent.width
                        text: days[sumarDia((modelData + 1))]
                        color: fontColorResolved
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Kirigami.Units.gridUnit * 0.8
                    }

                    Kirigami.Icon {
                        source: weatherData.asingicon(modelData === 0 ? weatherData.codeweatherTomorrow : modelData === 1 ? weatherData.codeweatherDayAftertomorrow : weatherData.codeweatherTwoDaysAfterTomorrow)
                        width: Kirigami.Units.iconSizes.medium
                        height: Kirigami.Units.iconSizes.medium
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Row {
                        spacing: Kirigami.Units.smallSpacing
                        anchors.horizontalCenter: parent.horizontalCenter
                        PlasmaComponents3.Label {
                            text: Math.round(modelData === 0 ? weatherData.maxweatherTomorrow : modelData === 1 ? weatherData.maxweatherDayAftertomorrow : weatherData.maxweatherTwoDaysAfterTomorrow) + "°"
                            color: fontColorResolved
                            font.weight: Font.Bold
                        }
                        PlasmaComponents3.Label {
                            text: Math.round(modelData === 0 ? weatherData.minweatherTomorrow : modelData === 1 ? weatherData.minweatherDayAftertomorrow : weatherData.minweatherTwoDaysAfterTomorrow) + "°"
                            color: fontColorResolved
                            opacity: 0.6
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 900000
        running: true
        repeat: true
        onTriggered: {
            tomorrow = sumarDia(1)
            dayAftertomorrow = sumarDia(2)
            twoDaysAfterTomorrow = sumarDia(3)
        }
    }
}
