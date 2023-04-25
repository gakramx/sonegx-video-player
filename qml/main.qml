import QtQuick
import "controls"
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtMultimedia
import QtQuick.Dialogs
import QtQml
Window {

    flags: Qt.Window | Qt.FramelessWindowHint
    id: mainWindow
    width: 1024
    height: 640
    title: qsTr("Dapp")
    visible: true
    color: "#00000000"
    minimumHeight: 500
    minimumWidth: 800
    property int windowStatus: 0
    property int windowMargin: 2
    QtObject{
        id: internal
        function resetResizeBorders(){
            // Resize visibility
            resizeLeft.visible = true
            resizeRight.visible = true
            resizeBottom.visible = true
            resizeWindow.visible = true
        }

        function maximizeRestore(){
            if(windowStatus == 0){
                mainWindow.showMaximized()
                windowStatus = 1
                windowMargin = 0
                // Resize visibility
                resizeLeft.visible = false
                resizeRight.visible = false
                resizeBottom.visible = false
                resizeWindow.visible = false
                topBarMaxBtn.btnIconSource = "qrc:/images/icons/cil-window-restore.svg"
            }
            else{
                mainWindow.showNormal()
                windowStatus = 0
                windowMargin = 2
                // Resize visibility
                internal.resetResizeBorders()
                topBarMaxBtn.btnIconSource = "qrc:/images/icons/cil-window-maximize.svg"
            }
        }

        function ifMaximizedWindowRestore(){
            if(windowStatus == 1){
                mainWindow.showNormal()
                windowStatus = 0
                windowMargin = 2
                // Resize visibility
                internal.resetResizeBorders()
                topBarMaxBtn.btnIconSource = "qrc:/images/icons/cil-window-maximize.svg"
            }
        }

        function restoreMargins(){
            windowStatus = 0
            windowMargin = 2
            // Resize visibility
            internal.resetResizeBorders()
            topBarMaxBtn.btnIconSource = "qrc:/images/icons/cil-window-maximize.svg"
        }
    }

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

    Rectangle {
        id: bg
        color: Style.bgColor
        anchors.fill: parent
        radius: 7
        Rectangle {
            id: appContainer
            color: "#00236123"
            anchors.fill: parent
            anchors.rightMargin: windowMargin
            anchors.leftMargin: windowMargin
            anchors.bottomMargin: windowMargin
            anchors.topMargin: windowMargin

            Row {
                id: row
                x: 409
                width: 105
                height: 35
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 2
                anchors.rightMargin: 2

                TopBarButton {
                    id: topBarMinBtn
                    btnColorOverlay: Style.oColor
                    btnColorMouseOver: Style.hColor
                    btnColorDefault: Style.bgColor
                    btnIconSource: "qrc:/images/icons/cil-window-minimize.svg"
                    onClicked: {
                        mainWindow.showMinimized()
                        internal.restoreMargins()
                    }
                }

                TopBarButton {
                    id: topBarMaxBtn
                    btnColorOverlay: Style.oColor
                    btnColorDefault: Style.bgColor
                    btnColorMouseOver: Style.hColor
                    btnIconSource: "qrc:/images/icons/cil-window-maximize.svg"
                    onClicked: internal.maximizeRestore()
                }

                TopBarButton {
                    id: topBarCloseBtn
                    btnColorMouseOver: "#f9005b"
                    btnColorDefault: Style.bgColor
                    btnColorOverlay: Style.oColor
                    btnIconSource: "qrc:/images/icons/cil-x.svg"
                    onClicked: mainWindow.close()
                }
            }

            Rectangle {
                id: content
                color: "black"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: topBar.bottom
                anchors.bottom: parent.bottom
                anchors.topMargin: 15
                anchors.rightMargin: 5
                anchors.leftMargin: 5
                anchors.bottomMargin: 5
                clip: true

                CustomSwitch{
                    id:switchDark
                    width: 153
                    height: 38
                    z:0
                    text: "Dark "
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    colorDefault:Style.fColor
                    colorChecked:Style.sColor
                    colorText:Style.textColor
                    onCheckedChanged: if(switchDark.checked==true){
                                          Style.cur=1
                                      }
                                      else{
                                          Style.cur=2
                                      }
                }

                Video {
                    id: player
                    anchors.fill: parent

                    volume: 0.9

                    MouseArea{
                        id: iMouseArea
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        property int prevX: 0
                        property int prevY: 0
                        anchors.fill: parent


                        onPressed:  (mouse)=>  {prevX=mouse.x; prevY=mouse.y}

                        onClicked:  (mouse)=> {
                                        if (mouse.button === Qt.RightButton)
                                        contextMenu.popup()
                                        else if (mouse.button === Qt.LeftButton)
                                        {
                                            if(player.playbackState == MediaPlayer.PlayingState){
                                                animationOpenMenu2.start()

                                                timeranimationMenu2.restart()
                                            }

                                        }
                                    }
                        onDoubleClicked: {
                            if (player.playbackState == MediaPlayer.PlayingState){
                                player.pause()
                            }
                            else{
                                player.play()
                            }
                            animationMenu.running = true
                        }
                    }
                }

                Rectangle {
                    id: playerMenu
                    y: 597
                    height: 0
                    opacity: 0.569
                    z:1
                    clip:true
                    color: "#ffffff"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.rightMargin: 0
                    anchors.leftMargin: 0
                    PropertyAnimation{
                        id: animationMenu
                        target: playerMenu
                        property: "height"
                        running: false
                        to:
                            if(player.playbackState != MediaPlayer.PlayingState) return 200; else return 0
                        duration: 200
                        easing.type: Easing.Linear
                    }
                    PropertyAnimation{
                        id: animationOpenMenu2
                        target: playerMenu
                        property: "height"
                        running: false
                        to:200
                        duration: 200
                        easing.type: Easing.Linear
                    }
                    PropertyAnimation{
                        id: animationCloseMenu2
                        target: playerMenu
                        property: "height"
                        running: false
                        to:0
                        duration: 200
                        easing.type: Easing.Linear
                    }
                }

            }
            Timer {
                id:timeranimationMenu2
                interval: 2000; running: false; repeat: false
                onTriggered:{
                    console.log(" treggggggggggggggggggggggggggg")
                    animationCloseMenu2.start()
                }
            }
            Rectangle {
                id: topBar
                height: 23
                color: "#00000000"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 147
                anchors.leftMargin: 105
                anchors.topMargin: 0

                MouseArea {
                    id: mouseResize
                    anchors.fill: parent
                    onDoubleClicked: {internal.maximizeRestore()

                    }
                    DragHandler {
                        onActiveChanged: if(active){
                                             mainWindow.startSystemMove()
                                         }
                    }
                }

            }

            MouseArea {
                id: resizeWindow
                x: 1020
                width: 10
                height: 35
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 0
                DragHandler {
                    target: null
                    onActiveChanged: if (active){
                                         mainWindow.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
                                     }
                }
                anchors.bottomMargin: 0
                cursorShape: Qt.SizeFDiagCursor
            }
        }

        MouseArea {
            id: resizeLeft
            x: -6
            width: 10
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.topMargin: 10
            cursorShape: Qt.SizeHorCursor

            DragHandler{
                target: null
                onActiveChanged: if (active) { mainWindow.startSystemResize(Qt.LeftEdge) }
            }
        }

        MouseArea {
            id: resizeRight
            x: 1020
            y: 11
            width: 10
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: -1
            anchors.bottomMargin: 35

            anchors.topMargin: 35
            cursorShape: Qt.SizeHorCursor

            DragHandler{
                target: null
                onActiveChanged: if (active) { mainWindow.startSystemResize(Qt.RightEdge) }
            }
        }

        MouseArea {
            id: resizeBottom
            x: 11
            y: 576
            height: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 1
            anchors.leftMargin: 19
            anchors.bottomMargin: -6
            cursorShape: Qt.SizeVerCursor

            DragHandler{
                target: null
                onActiveChanged: if (active) { mainWindow.startSystemResize(Qt.BottomEdge) }
            }
        }
    }

}
