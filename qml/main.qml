import QtQuick
import "controls"
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtMultimedia
import QtQuick.Dialogs

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
        function msToTimeString(duration) {
            var milliseconds = Math.floor((duration % 1000) / 100),
            seconds = Math.floor((duration / 1000) % 60),
            minutes = Math.floor((duration / (1000 * 60)) % 60),
            hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

            hours = (hours < 10) ? "0" + hours : hours;
            minutes = (minutes < 10) ? "0" + minutes : minutes;
            seconds = (seconds < 10) ? "0" + seconds : seconds;

            return hours + ":" + minutes + ":" + seconds; //+ "." + milliseconds;
        }
        function toMilliseconds(hrs,min,sec){
            return (hrs*60*60+min*60+sec)*1000;
        }
    }

    FileDialog {
        id: dlg
        //    nameFilters: [ "Video files (*.mp4 *.flv *.ts *.mpg *.3gp *.ogv *.m4v *.mov)", "All files (*)" ]
        title: "Please choose a video file"
        modality: Qt.WindowModal
        onAccepted: {
            console.log("You chose: " + dlg.currentFile)
            player.source = dlg.currentFile
            player.play()
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
                color: "transparent"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: topBar.bottom
                anchors.bottom: parent.bottom
                anchors.topMargin: 15
                anchors.rightMargin: 5
                anchors.leftMargin: 5
                anchors.bottomMargin: 5
                clip: true
                Video {
                    id: player
                    anchors.fill: parent
                    volume: volumeSlider.value
                    playbackRate: 1.0
                    fillMode: VideoOutput.Stretch
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
                                            if(player.playbackState == MediaPlayer.PlayingState && playerMenu.height==0 ){
                                                animationOpenMenu2.start()
                                                timeranimationMenu2.restart()
                                            }
                                            else if(player.playbackState == MediaPlayer.PlayingState )
                                             animationCloseMenu.start()
                                        }
                                    }
                        onDoubleClicked: {
                            if (player.playbackState == MediaPlayer.PlayingState){
                                playBtn.btnIconSource= "qrc:/images/icons/cil-media-play.svg"
                                player.pause()
                                animationOpenMenu.start()
                            }
                            else{
                                playBtn.btnIconSource= "qrc:/images/icons/cil-media-pause.svg"
                                player.play()
                                animationCloseMenu.start()
                            }
                        }
                    }
                    property string timeText: {
                        var positionSeconds = Math.floor(player.position)
                        var hours = Math.floor(positionSeconds / 3600)
                        var minutes = Math.floor((positionSeconds - hours * 3600) / 60)
                        var seconds = Math.floor(positionSeconds - hours * 3600 - minutes * 60)

                        return hours.toString() + ":" + minutes.toString() + ":" + seconds.toString()
                                + " / " + (player.duration / 3600).toFixed(0) + ":" +
                                ((player.duration / 60) % 60).toFixed(0) + ":" +
                                (player.duration % 60).toFixed(0)
                    }
                    function updatePlaybackRate(delta) {
                        // modify the playback rate by adding the delta value
                        playbackRate += delta
                    }

                    function switchFillMode() {
                        // switch the fill mode to the next value in the sequence
                        switch (player.fillMode) {
                        case VideoOutput.Stretch:
                            player.fillMode = VideoOutput.PreserveAspectCrop
                            break
                        case VideoOutput.PreserveAspectCrop:
                            player.fillMode = VideoOutput.PreserveAspectFit
                            break
                        case VideoOutput.PreserveAspectFit:
                            player.fillMode = VideoOutput.Stretch
                            break
                        default:
                            player.fillMode = VideoOutput.Stretch
                        }
                    }
                    onPlaybackStateChanged: {
                    if(playbackState == MediaPlayer.PlayingState)
                           playBtn.btnIconSource= "qrc:/images/icons/cil-media-pause.svg"
                    else{
                          playBtn.btnIconSource= "qrc:/images/icons/cil-media-play.svg"
                    }

                    }

                }
                Rectangle {
                    id: playerMenu
                    y: 597
                    height: 0
                    opacity: 0.7
                    z:1
                    clip:true
                    color: Style.hColor
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.rightMargin: 0
                    anchors.leftMargin: 0

                    PropertyAnimation{
                        id: animationOpenMenu
                        target: playerMenu
                        property: "height"
                        running: false
                        to:200
                        duration: 200
                        easing.type: Easing.Linear
                    }
                    PropertyAnimation{
                        id: animationCloseMenu
                        target: playerMenu
                        property: "height"
                        running: false
                        to:0
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
                    Slider {
                        id: progressSlider
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: 40
                        anchors.rightMargin: 40
                        anchors.topMargin: 20
                        onHoveredChanged: hovered ? timeranimationMenu2.stop():
                                                    timeranimationMenu2.restart();
                        z:1
                        enabled: player.seekable
                        value: player.duration > 0 ? player.position / player.duration : 0
                        background: Rectangle {
                            implicitHeight: 8
                            color: "white"
                            radius: 3
                            Rectangle {
                                width: progressSlider.visualPosition * parent.width
                                height: parent.height
                                color: "#1D8BF8"
                                radius: 3
                            }
                        }
                        handle: Item {}
                        onMoved: function () {
                            player.position = player.duration * progressSlider.position

                        }
                    }

                    Row {
                        id: rowButtons
                        width: 242
                        height: 86
                        anchors.top: parent.top
                        anchors.topMargin: 59
                        z:1
                        anchors.horizontalCenter: parent.horizontalCenter
                        rightPadding: 2
                        leftPadding: 2
                        bottomPadding: 2
                        topPadding: 2
                        spacing: 4
                        MenuButton {
                            id: decreaseSpeed
                            onHoveredChanged: hovered ? timeranimationMenu2.stop():
                                                        timeranimationMenu2.restart();
                            onClicked: player.updatePlaybackRate(-0.1) // decrease the playback rate by 0.1

                        }

                        MenuButton {
                            id: playBtn
                            onHoveredChanged: hovered ? timeranimationMenu2.stop():
                                                        timeranimationMenu2.restart();
                            btnIconSource: "qrc:/images/icons/cil-media-play.svg"
                            onClicked: {
                                if (player.playbackState == MediaPlayer.PlayingState){
                                    player.pause()
                                    playBtn.btnIconSource= "qrc:/images/icons/cil-media-play.svg"
                                }
                                else{
                                    player.play()
                                    playBtn.btnIconSource= "qrc:/images/icons/cil-media-pause.svg"
                                }
                            }
                        }
                        MenuButton {
                            id: increaseSpeed
                            onHoveredChanged: hovered ? timeranimationMenu2.stop():
                                                        timeranimationMenu2.restart();
                            onClicked: player.updatePlaybackRate(0.1) // increase the playback rate by 0.1
                        }

                        MenuButton {
                            id: switchFillMode
                            onClicked: player.switchFillMode()
                        }
                    }
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            timeranimationMenu2.stop()
                        }
                        onExited: {
                            if(!progressSlider.hovered && !decreaseSpeed.hovered && !playBtn.hovered  && !increaseSpeed.hovered)
                                timeranimationMenu2.restart()
                        }

                        Label {
                            id: timeLabel
                            text: internal.msToTimeString(
                                      player.position) + " / " + internal.msToTimeString(
                                      player.duration)
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            horizontalAlignment: Text.AlignLeft
                            font.bold: true
                            font.pointSize: 14
                            anchors.rightMargin: 803
                            anchors.topMargin: 50
                            anchors.bottomMargin: 117
                            anchors.leftMargin: 40
                        }
                        Slider {
                            id: volumeSlider
                            x: 724
                            width: 200
                            height: 33

                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 20
                            anchors.rightMargin: 90
                            anchors.topMargin: 39
                            // orientation: Qt.Vertical
                            value: 0.5
                        }

                        Label {
                            id: volumeLabel
                            x: 714
                            text: Math.floor(volumeSlider.value*100) + "%"
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.rightMargin: 40
                            anchors.topMargin: 41
                            horizontalAlignment: Text.AlignLeft
                            font.bold: true
                            font.pointSize: 14
                        }
                    }
                }

                Rectangle {
                    id: oprnArea
                    y: 23
                    width: 256
                    height: 319
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    antialiasing: true
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        id: image
                        width: 256
                        height: 256
                        anchors.top: parent.top
                        horizontalAlignment: Image.AlignHCenter
                        source: "qrc:/images/sonegx_open.png"
                        sourceSize.height: 256
                        sourceSize.width: 256
                        anchors.topMargin: 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        antialiasing: true
                        fillMode: Image.PreserveAspectFit
                    }

                    MenuButton {
                        id: openButton
                        text: "Open"
                        colorDefault:"transparent"
                        borderColor:  "#636394"
                        anchors.top: image.bottom
                        anchors.topMargin: 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        contentItem: Text{
                            color: "#ffffff"
                            text: "+"
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                            font.pointSize: 29
                            anchors.horizontalCenter: parent.horizontalCenter
                         //   font: openButton.font
                        }
                        onClicked:   dlg.visible = true
                    }
                }
            }
            Timer {
                id:timeranimationMenu2
                interval: 5000; running: false; repeat: false
                onTriggered:{
                    if(player.playbackState == MediaPlayer.PlayingState)
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
