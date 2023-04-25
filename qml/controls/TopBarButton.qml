import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
Button {
    id: topBarBtn
    property url btnIconSource: "../../images/svg_images/minimize_icon.svg"
    property color btnColorDefault:  "#1c1d20"
    property color btnColorMouseOver: "#23272E"
    property color btnColorClicked: "#00a1f1"
    property color btnColorOverlay: "#ffffff"
    icon.color: "#ffffff"
           QtObject{
               id: internal

               // MOUSE OVER AND CLICK CHANGE COLOR
               property var dynamicColor: if(topBarBtn.down){
                                              topBarBtn.down ? btnColorClicked : btnColorDefault
                                          } else {
                                              topBarBtn.hovered ? btnColorMouseOver : btnColorDefault
                                          }
           }

           implicitWidth: 35
           implicitHeight: 35
           background: Rectangle{
               id: bgBtn
               color: internal.dynamicColor
               Image {
                   id: iconBtn
                   source: btnIconSource
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.horizontalCenter: parent.horizontalCenter
                   height: 16
                   width: 16
                   fillMode: Image.PreserveAspectFit
                   visible: false
               }
               ColorOverlay{
                   anchors.fill: iconBtn
                   source: iconBtn
                   color: btnColorOverlay
                   antialiasing: false
               }
           }
       }


/*##^##
Designer {
    D{i:0;autoSize:true;height:60;width:70}
}
##^##*/
