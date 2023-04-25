import QtQuick
import QtQuick.Controls

Switch {
    property color colorDefault: "#30383f"
    property color colorHoverd: "#00aeff"
    property color colorChecked: "#23272E"
    property color colorText:"#ffffff"

    id: switchCtl
    text: qsTr("Switch")
    indicator: Rectangle {
        implicitWidth: 48
        implicitHeight: 26
        x: switchCtl.leftPadding
        y: parent.height / 2 - height / 2
        radius: 13
        color: switchCtl.checked ? colorChecked :"#ffffff"
        border.color: switchCtl.checked ? colorChecked :  "#cccccc"

        Rectangle {
            x: switchCtl.checked ? parent.width - width : 0
            width: 26
            height: 26
            radius: 13
            color: switchCtl.down ? colorChecked : "#ffffff"
            border.color: switchCtl.checked ? (switchCtl.down ? colorDefault :colorHoverd) : "#999999"
        }
    }

    contentItem: Text {
        text: switchCtl.text
        font: switchCtl.font
        opacity: enabled ? 1.0 : 0.3
        color: switchCtl.down ? colorChecked : colorText
        verticalAlignment: Text.AlignVCenter
        leftPadding: switchCtl.indicator.width + switchCtl.spacing
    }
}
