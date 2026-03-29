import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.1
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
  id: root
  readonly property real compactImplicitWidthValue: (compactRepresentation && compactRepresentation.implicitWidth > 0) ? compactRepresentation.implicitWidth : Kirigami.Units.gridUnit * 6
  readonly property real compactImplicitHeightValue: (compactRepresentation && compactRepresentation.implicitHeight > 0) ? compactRepresentation.implicitHeight : Kirigami.Units.gridUnit * 4

  implicitWidth: compactImplicitWidthValue
  implicitHeight: compactImplicitHeightValue
  width: implicitWidth
  height: implicitHeight
  Layout.preferredWidth: implicitWidth
  Layout.preferredHeight: implicitHeight
  Layout.minimumWidth: compactImplicitWidthValue
  Layout.minimumHeight: compactImplicitHeightValue
  Layout.maximumWidth: implicitWidth
  Layout.maximumHeight: implicitHeight

  switchWidth: Math.round(compactImplicitWidthValue) + 1
  switchHeight: Math.round(compactImplicitHeightValue) + 1

  property var days: []

  Plasmoid.backgroundHints: Plasmoid.formFactor === PlasmaCore.Types.Planar
      ? (PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground)
      : (PlasmaCore.Types.NoBackground | PlasmaCore.Types.ConfigurableBackground)
  preferredRepresentation: compactRepresentation

  property bool boldfonts: plasmoid.configuration.boldfonts
  property string temperatureUnit: plasmoid.configuration.temperatureUnit
  property string sizeFontConfg: plasmoid.configuration.sizeFontConfig
  property bool useCustomFontColor: plasmoid.configuration.useCustomFontColor
  property string fontColor: plasmoid.configuration.fontColor

  DayOfWeekRow {
    id: daysWeek
    visible:  false
    delegate: Item {
      Component.onCompleted: {
        days.push(shortName)
      }
    }
  }

  compactRepresentation: CompactRepresentation {

  }
  fullRepresentation: FullRepresentation {
  }
}
