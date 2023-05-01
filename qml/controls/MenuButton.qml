import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Button {
    id: menubutton
    // CUSTOM PROPERTIES
    property url btnIconSource: "../../images/svg_images/settings_icon.svg"
    property color btnColorDefault: "#161e27"
    property color btnColorMouseOver: "#202c39"
    property color btnColorClicked: "#55aaff"
    property color btnColorOverlay: "#ffffff"
    property color borderColor: "#40405f"
    property int btnRadius: 10
   property int iconWdth : 32
   property int iconHeight: 32
    QtObject {
        id: internal

        // MOUSE OVER AND CLICK CHANGE COLOR
        property var dynamicColor: if (menubutton.down) {
                                       menubutton.down ? btnColorClicked : btnColorDefault
                                   } else {
                                       menubutton.hovered ? btnColorMouseOver : btnColorDefault
                                   }
    }
    width: 64
    height: 64
    clip: true
    background: Rectangle {
        id: bgBtn
        color: internal.dynamicColor
        radius: btnRadius
        anchors.fill: parent
        anchors.margins: 3
        border.color: borderColor
        Image {
            id: iconBtn
            source: btnIconSource
            sourceSize.height: iconHeight
            sourceSize.width: iconWdth
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            fillMode: Image.PreserveAspectFit
            antialiasing: true
        }

        ColorOverlay {
            anchors.fill: iconBtn
            source: iconBtn
            color: btnColorOverlay
            antialiasing: true
        }
    }
}
