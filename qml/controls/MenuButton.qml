import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
Button{
        id: menubutton
        // CUSTOM PROPERTIES
        property url btnIconSource: "../../images/svg_images/settings_icon.svg"
        property color btnColorDefault: "#1b2631"
        property color btnColorMouseOver: "#40405f"
        property color btnColorClicked: "#55aaff"
        property color btnColorOverlay: "#ffffff"
        property color borderColor: "#40405f"
        property int btnRadius: 10

        QtObject{
            id: internal

            // MOUSE OVER AND CLICK CHANGE COLOR
            property var dynamicColor: if(menubutton.down){
                                           menubutton.down ? btnColorClicked : btnColorDefault
                                       } else {
                                           menubutton.hovered ? btnColorMouseOver : btnColorDefault
                                       }

        }

        width: 64
        height: 64
        background: Rectangle{
            id: bgBtn
            color: internal.dynamicColor
            radius: btnRadius
            anchors.fill: parent
            anchors.margins: 3
border.color:borderColor
            Image {
                id: iconBtn
                source: btnIconSource
                sourceSize.height: 22
                sourceSize.width: 22
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false
                fillMode: Image.PreserveAspectFit
                antialiasing: true
            }

            ColorOverlay{
                anchors.fill: iconBtn
                source: iconBtn
                color: btnColorOverlay
                antialiasing: true
            }
        }
    }
