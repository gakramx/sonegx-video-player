import QtQuick
import "controls"
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtMultimedia
import QtQuick.Dialogs
import QtQuick.Controls.Material
import JsonFile
import AesCrypt
Window {
    Material.theme: Material.Dark
    Material.accent: Material.Blue
    flags: Qt.Window | Qt.FramelessWindowHint
    id: mainWindow
    width: 1024
    height: 640
    title: qsTr("Sonegx video player MPV")
    visible: true
    color: "#00000000"
    minimumHeight: 500
    minimumWidth: 800
    property int windowStatus: 0
    property int windowMargin: 2

    QtObject {
        id: internal
        function resetResizeBorders() {
            // Resize visibility
            resizeLeft.visible = true
            resizeRight.visible = true
            resizeBottom.visible = true
            resizeWindow.visible = true
        }

        function maximizeRestore() {
            if (windowStatus == 0) {
                mainWindow.showMaximized()
                windowStatus = 1
                windowMargin = 0
                // Resize visibility
                resizeLeft.visible = false
                resizeRight.visible = false
                resizeBottom.visible = false
                resizeWindow.visible = false
                topBarMaxBtn.btnIconSource = "qrc:/images/icons/cil-window-restore.svg"
            } else {
                mainWindow.showNormal()
                windowStatus = 0
                windowMargin = 2
                // Resize visibility
                internal.resetResizeBorders()
                topBarMaxBtn.btnIconSource = "qrc:/images/icons/cil-window-maximize.svg"
            }
        }

        function ifMaximizedWindowRestore() {
            if (windowStatus == 1) {
                mainWindow.showNormal()
                windowStatus = 0
                windowMargin = 2
                // Resize visibility
                internal.resetResizeBorders()
                topBarMaxBtn.btnIconSource = "qrc:/images/icons/cil-window-maximize.svg"
            }
        }

        function restoreMargins() {
            windowStatus = 0
            windowMargin = 2
            // Resize visibility
            internal.resetResizeBorders()
            topBarMaxBtn.btnIconSource = "qrc:/images/icons/cil-window-maximize.svg"
        }
        function msToTimeString(duration) {
            var milliseconds = Math.floor(
                        (duration % 1000) / 100), seconds = Math.floor((duration / 1000) % 60), minutes = Math.floor((duration / (1000 * 60)) % 60), hours = Math.floor((duration / (1000 * 60 * 60)) % 24)

            hours = (hours < 10) ? "0" + hours : hours
            minutes = (minutes < 10) ? "0" + minutes : minutes
            seconds = (seconds < 10) ? "0" + seconds : seconds

            return hours + ":" + minutes + ":" + seconds //+ "." + milliseconds;
        }
        function toMilliseconds(hrs, min, sec) {
            return (hrs * 60 * 60 + min * 60 + sec) * 1000
        }
        function timeToMilliseconds(time) {
            var timeParts = time.split(":")
            var hours = parseInt(timeParts[0])
            var minutes = parseInt(timeParts[1])
            var seconds = parseInt(timeParts[2])
            return (hours * 60 * 60 + minutes * 60 + seconds) * 1000
        }
    }

    QtObject {
        id:json
        //for single video
        property string videoName
        property string videoFile
        property int videoId
        property int currentvideoId

        property var timeLines:[]

        property var namesList:[]
        property var descList:[]

        property var proRectangles:[]
        signal filevideoChanged(string videoFile)
        function getVideoName(file)
        {
            var data =  file.read()
            //  videoName=JSON.stringify(data.fvideo)
            videoName=data.fvideo
            return JSON.stringify(data.fvideo)
        }
        function getTimeline(file)
        {
            var data =  file.read()
            var timelines = [];
            //data.timeline[0].show_time
            for(var i=0;i<data.timeline.length;i++)
            {
                timelines.push(data.timeline[i].show_time)
                //  console.log(data.timeline[i].show_time)
            }
            timeLines=timelines
            return timelines
        }
        function printRecation(player,file){

            var position = internal.msToTimeString(player.position)
            var data=file.read()
            var component;
            var sprite;
            for(var i=0;i<timeLines.length;i++)
            {
                if(position==timeLines[i]){
                    player.pause()
                    component = Qt.createComponent("qrc:/qml/controls/ReactTmp.qml");
                    sprite = component.createObject(player, {"messageText": data.timeline[i].msg_text});
                    sprite = component.createObject(player, {"messageText": data.timeline[i].msg_text,"newVideo":dlg.currentFolder+"/"+data.timeline[i].vpath});
                    //   console.log("VPATH -------------------------------------------- "+ dlg.currentFolder+"/"+data.timeline[i].vpath)
                }
            }

        }
        function printRectangleSlider(file,parentComponent){
            if(proRectangles==0){
                // console.log("Work  " )
                var component;
                var sprite;
                var positionRec;
                for (var i = 0; i < timeLines.length; i++) {
                    //  console.log("Create  " + timeLines[i])
                    positionRec =  positionRedRectangle(timeLines[i])
                    //  console.log("Create positsion   " + positionRec )
                    component = Qt.createComponent("qrc:/qml/controls/PRec.qml");
                    sprite = component.createObject(parentComponent, {"x": positionRec-i});
                    proRectangles.push(sprite)
                }
            }
            else if (timeLines!=0 && proRectangles!=0){

                for (var i = 0; i < proRectangles.length; i++) {
                    // console.log("Resize  " + timeLines[i])
                    positionRec =  positionRedRectangle(timeLines[i])
                    //  console.log("Resize positsion  " + positionRec )
                    proRectangles[i].x=positionRec-i
                }
            }
        }
        function positionRedRectangle(targetTime) {
            var targetPosition = internal.timeToMilliseconds(
                        targetTime) / player.duration
            return targetPosition * progressRect.width
        }
        //---------------------------------------------------------------//

        function getfirstvideo(file)
        {

            var data =  file.read()
            //  videoName=JSON.stringify(data.fvideo)
            videoName=data.videos[0].vName
            json.currentvideoId=0
            return JSON.stringify(data.fvideo)
        }
        function getidvideo(file,namevideo)
        {

            var data =  file.read()
            //  videoName=JSON.stringify(data.fvideo)
            for(var i = 0; i < data.videos.length; i++)
            {

                var video =  data.videos[i].vName;
                if(video==namevideo){
                    json.currentvideoId=i
                    return videoId=i

                }
                else {
                    videoId=0
                    json.currentvideoId=0
                }
            }

        }
        function getinfovideo(file)
        {

            var data =  file.read()
            var nameslist=[]
            var desclist=[]
            //  videoName=JSON.stringify(data.fvideo)
            for(var i = 0; i < data.videos.length; i++)
            {
                nameslist.push(data.videos[i].vName)
                desclist.push(data.videos[i].desc)
            }
            namesList= nameslist
            descList= desclist
        }
        function getfilevideo(file,id)
        {
            var data =  file.read()
            videoFile  =  data.videos[id].vbaseName;
            filevideoChanged(videoFile)
            console.log("getfilevideo : "+videoFile)
            return videoFile;
        }
        function gettimelinebyid(file,videoid)
        {
            var data =  file.read()
            var timelines = [];
            for(var i = 0; i < data.videos[videoid].timeline.length; i++)
            {
                //   console.log(data.videos[videoid].timeline[i].show_time)
                timelines.push(data.videos[videoid].timeline[i].show_time)
            }
            timeLines=timelines
            return timelines
        }
        function printRecationDialog(player,file){

            var position = internal.msToTimeString(player.position)
            var data=file.read()
            var component;
            var sprite;
            for(var i=0;i<timeLines.length;i++)
            {
                if(position==timeLines[i]){
                    player.pause()
                    component = Qt.createComponent("qrc:/qml/controls/ReactTmp.qml");
                    // sprite = component.createObject(player, {"messageText": data.videos[json.currentvideoId].timeline[i].msg_text});
                    sprite = component.createObject(player, {"messageText": data.videos[json.currentvideoId].timeline[i].msg_text,"newVideo":data.videos[json.currentvideoId].timeline[i].wvideo});
                    //console.log("VPATH -------------------------------------------- "+ dlg.currentFolder+"/"+data.timeline[i].vpath)
                }
            }

        }


    }
    /*
      run init() function
     in swtich to next video from reaction
     run

      */
    AES {
        id: aes
         property string workPath
        onEncryptionVideoProgressChanged: {
            openArea.visible=false
            player.visible = false
            loadArea.visible=true
            loadLabe.text="Loading "+ progress +" %"
            decryptProgress.value=progress
        }
        onDecryptionVideoFinished:(fullname) => {
                                      loadArea.visible = false
                                      // console.log(fullname)
                                      var videoFullname="file://"+fullname

                                      player.source=  videoFullname
                                      player.visible = true
                                      //    console.log("NEW source player :"+player.source)
                                      animationOpenMenu.start()

                                      //     player.volume(0)

                                  }
        onDecryptionProjectFinished: (projectFile)=>{
                                         aes.workPath=getinputPath();
                                         console.log(workPath)
                                         jsfile.name =projectFile
                                         json.getfirstvideo(jsfile)
                                         json.gettimelinebyid(jsfile,0)
                                         json.getfilevideo(jsfile,0)
                                         json.getinfovideo(jsfile)
                                         videosMdl.updateModel()
                                     }
    }
    Connections {
        target: json
        function onFilevideoChanged(videoFile){
            // Handle the emitted signal
            var videoin=aes.workPath+"/"
            aes.decryptVideo(videoin+videoFile,videoFile,"1234")
        }
    }

    JsonFile {
        id: jsfile
    }


    Timer {
        interval: 1000 // 1 second
        repeat: true
        running: player.playbackState === MediaPlayer.PlayingState
        onTriggered: {
            json.printRecationDialog(player,jsfile)
        }
    }
    FileDialog {
        id: dlg
        //  nameFilters: [ "Video files (*.mp4 *.flv *.ts *.mpg *.3gp *.ogv *.m4v *.mov)", "All files (*)" ]
        title: "Please choose a video file"
        modality: Qt.WindowModal
        onAccepted: {
            //  console.log("You chose: " + dlg.currentFile)
            openArea.visible = false
            // player.source = dlg.currentFile
            // player.play()
            //  jsfile.name = dlg.currentFile
            // json.gettimelinebyid(jsfile,1)
            // console.log(json.timeLines)
            //var data =  jsfile.read()
            //  var store = JSON.stringify(jsfile.read())
            // console.log("Folder: " +dlg.currentFolder)
            //json.getVideoName(jsfile)
            //  var fullVideoPath = dlg.currentFolder+"/"+json.videoName
            //    json.getTimeline(jsfile)
            //  player.source=fullVideoPath
            aes.decrypt(dlg.currentFile, "1234567891234567")
            // var timeList = json.getTimeline(jsfile)
            return
        }
        onRejected: {
            console.log("Canceled")
            //  aes.encryptVideo("notes.mp4","videotest2.dat0","1234")
            // var data =aes.encrypt("1.json", "1234567891234567")
            //   console.log(data)
            //  var data2=aes.decrypt("1.json.encrypted", "1234567891234567")
            // var data2=aes.encrypt("testproject", "1234567891234567")
            // console.log(data2)
            //  aes.decryptVideo("output.enc","input.mp4","1234")
            return
        }
    }

    Menu {
        id: contextMenu
        MenuItem {
            text: 'open File'
            onTriggered: dlg.visible = true
        }
        MenuSeparator {}
        MenuItem {
            text: 'Exit'
            onTriggered: player.play()
        }
    }

    Rectangle {
        id: bg
        color: Style.bgColor
        anchors.fill: parent

        //radius: 7
        Rectangle {
            id: appContainer
            color: "#00236123"
            anchors.fill: parent
            anchors.rightMargin: windowMargin
            anchors.leftMargin: windowMargin
            anchors.bottomMargin: windowMargin
            anchors.topMargin: windowMargin
            clip: true
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
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: 38
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
                    property bool firstRun: true
                    onSourceChanged: {
                        json.printRectangleSlider(jsfile,progressRect)
                        if(firstRun)
                            volume=0.0
                        play()
                    }
                    onErrorChanged: {
                        console.log("Video Error:", player.errorString)
                    }
                    onPositionChanged: {
                        if(position>300&&firstRun){
                            pause()
                            volume=volumeSlider.value
                            firstRun=false
                        }
                    }

                    MouseArea {
                        id: iMouseArea
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        property int prevX: 0
                        property int prevY: 0
                        anchors.fill: parent

                        onPressed: mouse => {
                                       prevX = mouse.x
                                       prevY = mouse.y
                                   }
                        onClicked: mouse => {
                                       if (mouse.button === Qt.RightButton)
                                       contextMenu.popup()
                                       else if (mouse.button === Qt.LeftButton) {
                                           if (player.playbackState == MediaPlayer.PlayingState
                                               && playerMenu.height == 0) {
                                               animationOpenMenu.start()
                                               timeranimationMenu.restart()
                                           } else if (player.playbackState
                                                      == MediaPlayer.PlayingState){
                                               animationCloseMenu.start()
                                               animationCloseoptionMenu.start()
                                           }
                                       }
                                   }
                        onDoubleClicked: {
                            if (player.playbackState == MediaPlayer.PlayingState) {
                                player.pause()
                                animationOpenMenu.start()
                            } else {
                                player.play()
                                animationCloseMenu.start()
                                animationCloseoptionMenu.start()
                            }
                        }
                    }
                    property string timeText: {
                        var positionSeconds = Math.floor(player.position)
                        var hours = Math.floor(positionSeconds / 3600)
                        var minutes = Math.floor(
                                    (positionSeconds - hours * 3600) / 60)
                        var seconds = Math.floor(
                                    positionSeconds - hours * 3600 - minutes * 60)

                        return hours.toString(
                                    ) + ":" + minutes.toString() + ":" + seconds.toString(
                                    ) + " / " + (player.duration / 3600).toFixed(
                                    0) + ":" + ((player.duration / 60) % 60).toFixed(0)
                                + ":" + (player.duration % 60).toFixed(0)
                    }
                    function updatePlaybackRate(delta) {
                        // modify the playback rate by adding the delta value
                        playbackRate += delta
                        if (playbackRate > 1.5) {
                            playbackRate = 1.5
                        } else if (playbackRate < 0.5) {
                            playbackRate = 0.5
                        }
                        playBackRateStatus.text= "Speed: "+ playbackRate.toFixed(1)+"x"
                        playBackRateStatus.visible = true
                        timerHidestatus.restart()

                    }
                    Timer {
                        id: timerHidestatus
                        interval: 1000 // 1 second
                        onTriggered: {
                            playBackRateStatus.visible = false
                            timerHidestatus.stop()
                        }
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
                        if (playbackState == MediaPlayer.PlayingState) {
                            // progressSlider.positionRedRectangle()

                            playBtn.btnIconSource = "qrc:/images/icons/cil-media-pause.svg"
                        } else {
                            playBtn.btnIconSource = "qrc:/images/icons/cil-media-play.svg"
                        }
                    }


                }
                Rectangle {
                    id: playerMenu
                    //  y: 433
                    height: 0
                    opacity: 1
                    color: "#e41b2631"
                    //  z: 1
                    clip: true
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.rightMargin: 0
                    anchors.leftMargin: 0

                    PropertyAnimation {
                        id: animationOpenMenu
                        target: playerMenu
                        property: "height"
                        running: false
                        to: 150
                        duration: 200
                        easing.type: Easing.Linear
                    }
                    PropertyAnimation {
                        id: animationCloseMenu
                        target: playerMenu
                        property: "height"
                        running: false
                        to: 0
                        duration: 200
                        easing.type: Easing.Linear
                    }
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            timeranimationMenu.stop()
                        }
                        onExited: {
                            if (!progressSlider.hovered
                                    && !decreaseSpeed.hovered
                                    && !playBtn.hovered
                                    && !increaseSpeed.hovered)
                                timeranimationMenu.restart()
                        }
                    }

                    Row {
                        id: toolRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: timeLabel.bottom
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        anchors.topMargin: 1
                        anchors.rightMargin: 5
                        anchors.leftMargin: 5

                        Row {
                            id: rowButtons
                            width: 246
                            height: 0
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            layer.textureMirroring: ShaderEffectSource.MirrorVertically
                            anchors.leftMargin: 15
                            anchors.bottomMargin: 0
                            z: 1
                            rightPadding: 0
                            leftPadding: 0
                            bottomPadding: 0
                            topPadding: 0
                            spacing: 4
                            MenuButton {
                                id: decreaseSpeed
                                anchors.verticalCenter: parent.verticalCenter
                                onHoveredChanged: hovered ? timeranimationMenu.stop(
                                                                ) : timeranimationMenu.restart()
                                onClicked: player.updatePlaybackRate(
                                               -0.1) // decrease the playback rate by 0.1
                                btnIconSource: "qrc:/images/icons/cil-chevron-double-left.svg"

                            }

                            MenuButton {
                                id: playBtn
                                width: 90
                                height: 90
                                anchors.verticalCenter: parent.verticalCenter
                                onHoveredChanged: hovered ? timeranimationMenu.stop(
                                                                ) : timeranimationMenu.restart()
                                btnIconSource: "qrc:/images/icons/cil-media-play.svg"
                                iconWdth:64
                                iconHeight: 64
                                onClicked: {
                                    if (player.playbackState == MediaPlayer.PlayingState) {
                                        player.pause()

                                    } else {
                                        player.play()
                                    }
                                }

                            }
                            MenuButton {
                                id: increaseSpeed
                                anchors.verticalCenter: parent.verticalCenter
                                onHoveredChanged: hovered ? timeranimationMenu.stop(
                                                                ) : timeranimationMenu.restart()
                                onClicked: player.updatePlaybackRate(
                                               0.1) // increase the playback rate by 0.1
                                btnIconSource: "qrc:/images/icons/cil-chevron-double-right.svg"

                            }
                        }

                        Image {
                            id: volume_icon
                            width: 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: rowButtons.right
                            source: "qrc:/images/icons/cil-volume-high.svg"
                            anchors.leftMargin: 2
                            fillMode: Image.PreserveAspectFit



                        }
                        ColorOverlay {
                            anchors.fill: volume_icon
                            source: volume_icon
                            color: "white"
                            antialiasing: true
                        }
                        MouseArea{
                            anchors.fill: volume_icon
                            onClicked: volumeSlider.mute_umute()

                        }

                        Slider {
                            property  real  tempValue: 0
                            id: volumeSlider
                            width: 150
                            height:  20
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: volume_icon.right
                            anchors.leftMargin: 2

                            onValueChanged: {
                                if(value==0)
                                    volume_icon.source="qrc:/images/icons/cil-volume-off.svg"
                                else if (value<=0.5)
                                    volume_icon.source="qrc:/images/icons/cil-volume-low.svg"
                                else
                                    volume_icon.source="qrc:/images/icons/cil-volume-high.svg"
                            }
                            function mute_umute() {
                                if(value!=0){
                                    tempValue=value
                                    value=0
                                }
                                else if(value==0)
                                {
                                    if(tempValue==0)
                                        value=70
                                    else
                                        value=tempValue
                                }
                            }

                            //     anchors.margins: 20
                            //   orientation: Qt.Vertical
                            PropertyAnimation {
                                id: animationOpenvolumeSlider
                                target: volumeSlider
                                property: "height"
                                running: false
                                to: 150
                                duration: 200
                                easing.type: Easing.Linear
                            }
                            PropertyAnimation {
                                id: animationClosevolumeSlider
                                target: volumeSlider
                                property: "height"
                                running: false
                                to: 0
                                duration: 200
                                easing.type: Easing.Linear
                            }
                            value: 1
                        }

                        Label {
                            id: volumeLabel
                            text: Math.floor(volumeSlider.value * 100) + "%"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: volumeSlider.right
                            horizontalAlignment: Text.AlignLeft
                            anchors.leftMargin: 10
                            font.bold: true
                            font.pointSize: 14
                        }

                        Row {
                            id: rowButtons1
                            width: 270
                            height: 60
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            bottomPadding: 2
                            z: 1
                            rightPadding: 2
                            layoutDirection: Qt.RightToLeft


                            MenuButton {
                                anchors.verticalCenter: parent.verticalCenter
                                btnIconSource: "qrc:/images/icons/cil-menu.svg"

                                onClicked: {
                                    if(optionMenu.width==0){
                                        animationOpenoptionMenu.start()
                                    }
                                    else{
                                        animationCloseoptionMenu.start()
                                    }
                                }
                            }

                            MenuButton {
                                id: switchFillMode

                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: player.switchFillMode()
                                btnIconSource: "qrc:/images/icons/cil-flip-to-front.svg"
                            }

                            MenuButton {
                                id:fullscrenButton
                                anchors.verticalCenter: parent.verticalCenter
                                btnIconSource: "qrc:/images/icons/cil-fullscreen.svg"
                                onClicked: {
                                    if (content.parent == appContainer) {
                                        fullscrenButton.btnIconSource= "qrc:/images/icons/cil-fullscreen-exit.svg"
                                        // Go fullscreen
                                        appContainer.visible = false
                                        content.parent = bg
                                        content.anchors.topMargin = 0
                                        content.anchors.rightMargin = 0
                                        content.anchors.leftMargin = 0
                                        content.anchors.bottomMargin = 0
                                        mainWindow.visibility = "FullScreen"
                                    } else {
                                        fullscrenButton.btnIconSource= "qrc:/images/icons/cil-fullscreen.svg"
                                        // Restore normal size
                                        mainWindow.visibility = "Windowed"
                                        content.parent = appContainer
                                        content.anchors.left = appContainer.left
                                        content.anchors.right = appContainer.right
                                        content.anchors.top = appContainer.top
                                        content.anchors.bottom = appContainer.bottom
                                        content.anchors.topMargin = 38
                                        content.anchors.rightMargin = 5
                                        content.anchors.leftMargin = 5
                                        content.anchors.bottomMargin = 5
                                        appContainer.visible = true
                                    }
                                }

                                onHoveredChanged: hovered ? timeranimationMenu.stop(
                                                                ) : timeranimationMenu.restart()
                            }
                            spacing: 4
                            leftPadding: 2
                            topPadding: 2
                        }




                    }

                    Slider {
                        id: progressSlider
                        onHoveredChanged: hovered ? timeranimationMenu.stop(
                                                        ) : timeranimationMenu.restart()
                        z: 1
                        enabled: player.seekable
                        value: player.duration > 0 ? player.position / player.duration : 0
                        onWidthChanged: {
                            json.printRectangleSlider(jsfile,progressRect)

                        }
                        onHeightChanged: {
                            json.printRectangleSlider(jsfile,progressRect)
                        }
                        background: Rectangle {
                            id: progressRect
                            implicitHeight: 4
                            color: "white"
                            radius: 3
                            anchors.verticalCenter: parent.verticalCenter
                            width: progressSlider.availableWidth
                            height: implicitHeight
                            x: progressSlider.leftPadding


                            /*
                            anchors.top: parent.top
                            anchors.topMargin: 0*/
                            Rectangle {
                                id: progressSliderRect
                                width: progressSlider.visualPosition * parent.width
                                height: parent.height
                                color: "#1D8BF8"
                                radius: 3
                            }
                        }
                        //handle: Item {}
                        handle: Rectangle {
                            //   x: progressSliderRect.width - 6
                            x: progressSlider.leftPadding + progressSlider.visualPosition
                               * (progressSlider.availableWidth - width)
                            y: progressSlider.topPadding
                               + progressSlider.availableHeight / 2 - height / 2
                            implicitWidth: 12
                            implicitHeight: 12
                            radius: 13
                            color: progressSlider.pressed ? "#1b2631" : "#f6f6f6"
                            border.color: "#bdbebf"

                            antialiasing: true
                        }
                        onMoved: function () {
                            player.position = player.duration * progressSlider.position
                        }

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 20
                        anchors.topMargin: 5
                        anchors.leftMargin: 20
                        //

                        Component.onCompleted: {

                            //    positionRedRectangle("00:22:10");
                        }
                    }

                    Label {
                        id: timeLabel
                        x: 830
                        width: 164
                        height: 26
                        text: internal.msToTimeString(player.position) +"/"+internal.msToTimeString(player.duration)
                        anchors.right: progressSlider.right
                        anchors.top: progressSlider.bottom
                        horizontalAlignment: Text.AlignLeft
                        anchors.rightMargin: 0
                        anchors.topMargin: 2
                        font.bold: true
                        font.pointSize: 14
                        color: "white"
                    }
                }

                Rectangle {
                    id: openArea
                    width: 308
                    color: "transparent"
                    //   color: "white"
                    anchors.top: parent.top
                    anchors.topMargin: 47
                    anchors.bottom: playerMenu.top
                    clip: true
                    anchors.bottomMargin: 30

                    anchors.horizontalCenterOffset: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    antialiasing: true

                    Column {
                        id: column
                        anchors.fill: parent

                        Image {
                            id: image


                            source: "qrc:/images/sonegx_open.png"
                            anchors.horizontalCenter: parent.horizontalCenter


                            sourceSize.height: 256
                            sourceSize.width: 256
                            antialiasing: true
                            //fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }

                        MenuButton {
                            id: openButton
                            text: "Open"
                            anchors.top: image.bottom
                            anchors.topMargin: 5

                            anchors.horizontalCenterOffset: -5
                            anchors.horizontalCenter: parent.horizontalCenter
                            contentItem: Text {
                                color: "#ffffff"
                                text: "+"
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.bold: true
                                font.pointSize: 29
                                //   font: openButton.font
                            }
                            onClicked: dlg.visible = true
                        }
                    }
                }

                Rectangle {
                    id: optionMenu
                    //    x: 814
                    //    width:  200
                    color: "#e41b2631"
                    anchors.right: parent.right
                    anchors.top: player.top
                    anchors.bottom: playerMenu.top
                    anchors.bottomMargin: 10
                    clip:true
                    anchors.topMargin: 10
                    anchors.rightMargin: 0

                    PropertyAnimation {
                        id: animationOpenoptionMenu
                        target: optionMenu
                        property: "width"
                        running: false
                        to: player.width/4
                        duration: 200
                        easing.type: Easing.Linear
                    }
                    PropertyAnimation {
                        id: animationCloseoptionMenu
                        target: optionMenu
                        property: "width"
                        running: false
                        to: 0
                        duration: 200
                        easing.type: Easing.Linear
                    }

                    ListModel {
                        id:videosMdl
                        function updateModel(){
                            videosMdl.clear()
                            for (var i = 0; i < json.namesList.length; i++) {
                                //    console.log(json.descList[i])
                                videosMdl.append({
                                                     "name": json.namesList[i],
                                                     "description": json.descList[i]
                                                 })
                            }
                        }
                    }
                    Component {
                        id: contactDelegate
                        Rectangle {
                            width: listVideos.width
                            height: 60
                            color: index === listVideos.currentIndex ? "#567995" : "#334758"
                            border.color: index === listVideos.currentIndex ? "#567995" : "#2d343b"

                            Column{
                                id: column1
                                Text {
                                    id: nameLabel
                                    text: '<b>Name: </b>' + name
                                    anchors.left: parent.left
                                    color: "white"
                                    anchors.leftMargin: 10
                                }

                                Text {
                                    id: descriptionLabel
                                    text: '<b>description: </b>' + description
                                    anchors.left: parent.left
                                    color: "white"
                                    anchors.leftMargin: 10
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // Handle click event here
                                    console.log("Clicked item:", index, name)
                                    player.pause()
                                    console.log(json.getfilevideo(jsfile,index))
                                    listVideos.currentIndex = index
                                }
                            }
                        }


                    }

                    ListView {
                        id: listVideos
                        anchors.fill: parent
                        anchors.rightMargin: 2
                        anchors.leftMargin: 2
                        anchors.bottomMargin: 2
                        anchors.topMargin: 2
                        z: 0

                        model: videosMdl
                        delegate:contactDelegate
                        highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
                    }

                }

                Rectangle {
                    id: loadArea
                    width: 567
                    height: 200
                    visible: false
                    color: "#00000000"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    Slider {
                        id: decryptProgress
                        y: 212
                        from:0
                        to:100
                        width: 394
                        height: 48
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 1
                        value: 0
                        handle: Item {

                        }
                    }

                    Label {
                        id: loadLabe
                        visible: true
                        text: qsTr("Label")
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: 18
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                Rectangle {
                    id: statusArea
                    width: 241
                    height: 45
                    color: "#00ffffff"
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 20
                    anchors.topMargin: 20
                    property color textColor: "White"
                    property int fontSize: 18
                    property bool statusVisible: false
                    Text {
                        anchors.fill: parent
                        font.pointSize: statusArea.fontSize
                        id: playBackRateStatus
                        color: statusArea.textColor
                        text: qsTr("text")
                        visible: false
                    }
                }
            }
            Timer {
                id: timeranimationMenu
                interval: 3000
                running: false
                repeat: false
                onTriggered: {
                    if (player.playbackState == MediaPlayer.PlayingState)
                        animationCloseMenu.start()
                    animationCloseoptionMenu.start()
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
                    onDoubleClicked: {
                        internal.maximizeRestore()
                    }
                    DragHandler {
                        onActiveChanged: if (active) {
                                             mainWindow.startSystemMove()
                                         }
                    }

                    Label {
                        id: label
                        color:"white"
                        text: qsTr("Sonegx player")
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        anchors.topMargin: 4
                        font.pointSize: 13
                        anchors.horizontalCenter: parent.horizontalCenter
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
                    onActiveChanged: if (active) {
                                         mainWindow.startSystemResize(
                                                     Qt.RightEdge | Qt.BottomEdge)
                                     }
                }
                anchors.bottomMargin: 0
                cursorShape: Qt.SizeFDiagCursor
            }
            /*
            Image {
                id: image1
                x: -9
                y: 139
                width: 512
                height: 512
               // horizontalAlignment: Image.AlignHCenter
                source: "qrc:/images/sonegx_open.svg"
                fillMode: Image.Stretch
                cache: false
                sourceSize.height: 512
                sourceSize.width: 512
                autoTransform: false
                mipmap: false
                antialiasing: true
                smooth: false


              //  anchors.horizontalCenterOffset: -321




               // anchors.horizontalCenter: parent.horizontalCenter

            }*/
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

            DragHandler {
                target: null
                onActiveChanged: if (active) {
                                     mainWindow.startSystemResize(Qt.LeftEdge)
                                 }
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

            DragHandler {
                target: null
                onActiveChanged: if (active) {
                                     mainWindow.startSystemResize(Qt.RightEdge)
                                 }
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

            DragHandler {
                target: null
                onActiveChanged: if (active) {
                                     mainWindow.startSystemResize(Qt.BottomEdge)
                                 }
            }
        }
    }
}



/*##^##
Designer {
    D{i:0}D{i:25;invisible:true}
}
##^##*/
