import QtQuick
import QtQuick.Controls 6.3

Rectangle {

    property string messageText: "Hello world"
    property url newVideo: "file://test"
   height: Math.max(msgText.implicitHeight + 80, 88)
z:1
    width: Math.max(msgText.implicitWidth + 40, 206)
    radius: 5
    id: react
    color: "#e41b2631"
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter

    Row {
        id: row
        width: 202
        height: 42
        anchors.bottom: progressBar.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 1
        layoutDirection: Qt.LeftToRight
        spacing: 5

        MenuButton {
            id: watchButton
            width: 100
            height: 40
            contentItem: Text {
                color: "#ffffff"
                text: "Watch"
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                font.pointSize: 12
                //   font: openButton.font

            }
            onClicked: {
                react.parent.source=newVideo
                  react.visible=false
            react.parent.play()
            }
        }
        MenuButton {
            id: continueButton
            width: 100
            height: 40
            contentItem: Text {
                color: "#ffffff"
                text: "Continue"
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                font.pointSize: 12

                //   font: openButton.font
            }
            onClicked: {
                 react.visible=false
                react.parent.play()

            }
        }
    }

    TextArea {
        id: msgText
        width: parent.width - 20
            height: implicitHeight
            wrapMode: TextArea.Wrap
         text: messageText
        anchors.top: parent.top
        font.pixelSize: 14
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        readOnly: true
        selectByMouse:false
            cursorVisible: false

        color: "White"
    }

    ProgressBar {
        id: progressBar
        height: 3
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 1
        anchors.leftMargin: 1
        anchors.bottomMargin: 0
        value: 1.0
    }
    Timer {
        id: timer
        interval: 50 // 1 second interval
        running: false
        repeat: true
        onTriggered: {
            if (progressBar.value > 0) {
                progressBar.value -= 0.01; // decrease the value by 20% each time
            } else {
                timer.stop(); // stop the timer when the progress bar is empty
                react.parent.play()
                react.visible=false

            }
        }
    }
    Component.onCompleted: {
        timer.start(); // start the timer when the component is completed
    }
}


