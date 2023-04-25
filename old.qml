import QtQuick
import QtMultimedia
import QtQuick.Controls
import QtQuick.Dialogs
Window {
    id: window
    visible: true
    title: qsTr("Hello World")
    color: "#000000"
    minimumHeight: 160
    minimumWidth: 285

    width: 480
    height: 270
    x: 100
    y: 100

    FileDialog {
        id: dlg
        nameFilters: [ "Video files (*.mp4 *.flv *.ts *.mpg *.3gp *.ogv *.m4v *.mov)", "All files (*)" ]
        title: "Please choose a video file"
        modality: Qt.WindowModal
        onAccepted: {
            console.log("You chose: " + dlg.currentFile)
            player.source = dlg.currentFile
            return
        }
        onRejected: {
            console.log("Canceled")
            return
        }
    }
    DropArea {
        id: drop
        anchors.fill: parent

        enabled: true

        onEntered:
            console.log("entered");

        onExited:
            console.log("exited")

        onDropped: {
            drop.acceptProposedAction()
            if (drop.hasUrls)
            {
                console.log("dropped url:", drop.urls)
                player.source = drop.urls[0]
            }
            else if (drop.hasText)
            {
                console.log("dropped text:", drop.text)
                player.source = drop.text
            }
        }
    }
    Item {
        id: myurls
        focus: true
        /*
        Keys.onPressed: (event)=> {
            if (event.key === Qt.Key_Q) Qt.quit()
            if (event.key === Qt.Key_F)
                if (window.visibility === Window.FullScreen) window.showNormal()
                else if (window.visibility === Window.Windowed) window.showFullScreen()
            if (event.key === Qt.Key_Down)
                if (player.volume > 0.1) player.volume -= 0.1
            if (event.key === Qt.Key_Up)
                if (player.volume < 1.0) player.volume += 0.1
            if (event.key === Qt.Key_M)
                if (player.muted === true) player.muted = false
                else if (player.muted === false) player.muted = true
            if (event.key === Qt.Key_U) console.log(myclip)
            if (event.key === Qt.Key_Right) player.seek(player.position + 20000)
            if (event.key === Qt.Key_Left) player.seek(player.position - 20000)
            if (event.key === Qt.Key_Space)
                if (player.playbackState == MediaPlayer.PlayingState)
                    player.pause()
                else
                    player.play()

        }*/
        Menu {
            id: contextMenu
            MenuItem {
                text: 'open File'
                onTriggered: dlg.visible = true
            }
            MenuSeparator {
            }
            MenuItem {
                text: 'Exit'
                onTriggered: player.play()
            }

        }
    }

    Rectangle {
        Component.onCompleted:
        {
            console.log("Welcome ...")
        }
        width: parent.width
        height: parent.height
        anchors.bottom: parent.bottom
        color: "black"

        Video {
            id: player
            anchors.fill: parent
            volume: 0.9
        }

    }
    MouseArea{
        id: iMouseArea
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        property int prevX: 0
        property int prevY: 0
        anchors.fill: parent
        onWheel: {
            if (wheel.angleDelta.y > 0)
            {window.width += 20;
                window.height = window.width / 1.778;}
            else
            {window.width -= 20;
                window.height = window.width / 1.778;}
        }

        onPressed:  (mouse)=>  {prevX=mouse.x; prevY=mouse.y}
        onPositionChanged: (mouse)=>  {
            var deltaX = mouse.x - prevX;
            window.x += deltaX;
            prevX = mouse.x - deltaX;

            var deltaY = mouse.y - prevY
            window.y += deltaY;
            prevY = mouse.y - deltaY;
        }
        onClicked:  (mouse)=> {
            if (mouse.button === Qt.RightButton)
                contextMenu.popup()
            else if (mouse.button === Qt.LeftButton)
                return
        }
    }
}
