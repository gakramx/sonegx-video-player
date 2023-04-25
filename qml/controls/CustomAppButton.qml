import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Button {
    id: button

    // Custom Properties
    property color colorDefault: "#30383f"
    property color colorMouseOver: "#23272E"
    property color colorPressed: "#00a1f1"
     property color colorButtonText:"#ffffff"
    property color btnColorOverlay:"#ffffff"
    property url setIcon: "../../images/svg_images/pix_icon.svg"

    implicitWidth: 120
    implicitHeight: 95

    QtObject{
        id: internal

        property var dynamicColor: if(button.down){
                                       button.down ? colorPressed : colorDefault
                                   }else{
                                       button.hovered ? colorMouseOver : colorDefault
                                   }
    }

    text: qsTr("Button")
    icon.color: "#ffffff"
    font.family: "Segoe UI"
    contentItem: Item{
        id: itemBtn
        Text {

            id: name
            text: button.text
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            verticalAlignment: Text.AlignBottom
            anchors.leftMargin: 2
            anchors.bottomMargin: 5
            font: button.font
            color: colorButtonText
        }
        Image {
            id: icon
            anchors.left: parent.left
            anchors.top: parent.top
            source: setIcon
            anchors.leftMargin: 2
            anchors.topMargin: 2
            sourceSize.height: 25
            sourceSize.width: 25
            fillMode: Image.PreserveAspectFit
            antialiasing: false
        }
        ColorOverlay{
            anchors.fill: icon
            source: icon
            color: btnColorOverlay
            antialiasing: false
        }
    }

    background: Rectangle{
        color: internal.dynamicColor
        radius: 10
        border.color: "#4b5863"
        border.width: 0.5

    }
}
/*##^##
Designer {
    D{i:0;height:95;width:120}
}
##^##*/
