import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Button {
    id: leftbutton

    // Custom Properties
    property color colorDefault: "#1d1d2b"
    property color colorMouseOver: "#40405f"
    property color colorTextBtn: "#ffffff"
    property color colorPressed: "#55aaff"
    property color btnColorOverlay: "#ffffff"
    property color borderColor:  "#33334c"
    property url btnIconSource: "../../images/svg_images/help_icon.svg"

    QtObject{
        id: internal

        property var dynamicColor: if(leftbutton.down){
                                       leftbutton.down ? colorPressed : colorDefault
                                   }else{
                                       leftbutton.hovered ? colorMouseOver : colorDefault
                                   }
    }
    implicitWidth: 200
    implicitHeight: 40
    text: qsTr("Button")
    icon.color: "#ffffff"
    font.pointSize: 9
    font.family: "Segoe UI"
    contentItem: Item{
        id: item1
        Text {
            id: name
            text: leftbutton.text
            font: leftbutton.font
            color: colorTextBtn
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 37
        }
        Image {
            id: iconBtn
            sourceSize.height: 24
            sourceSize.width: 24
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            source: btnIconSource
            anchors.leftMargin: 5
            fillMode: Image.PreserveAspectFit
            antialiasing: true
        }
        Image {
            id: iconArrow
            sourceSize.height: 18
            sourceSize.width: 18
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            source: "qrc:/images/icons/cil-arrow-right.svg"
            anchors.rightMargin: 3
            fillMode: Image.PreserveAspectFit
            antialiasing: true
        }
        ColorOverlay{
            anchors.fill: iconBtn
            source: iconBtn
            color: btnColorOverlay
            antialiasing: true
        }
        ColorOverlay{
            anchors.fill: iconArrow
            source: iconArrow
            color: btnColorOverlay
            antialiasing: true
        }

    }

    background: Rectangle{
        color: "#00000000"
        radius: 0
        border.color:borderColor

        Rectangle{
            anchors.fill: parent
            anchors.bottomMargin: 1
            anchors.topMargin: 0
            color: internal.dynamicColor
        }
    }
}
