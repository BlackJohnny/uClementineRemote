import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.Window 2.2
import Ubuntu.Content 1.3
import QtQuick.LocalStorage 2.0
import UClementineRemote 1.0

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "uclementineremote.blackjohnny"

    width: units.gu(100)
    height: units.gu(75)

    PageStack
    {
        id: pageStack
        Component.onCompleted: push(mainPage)

        Page
        {
            id: mainPage

            function statusMessage(message)
            {
                statusMessageArea.text = message;
            }

            header: PageHeader
            {
                id: pageHeader
                title: "uClementineRemote"
                z: 151
                leadingActionBar.actions: [
                    Action
                    {
                        id: actionConnect
                        iconName: "switch"
                        text: i18n.tr("Connect")

                        onTriggered:
                        {
                            if(clementineProxy.isConnected)
                                clementineProxy.disconnect();
                            else
                                clementineProxy.connectRemote(settingsPage.hostName, settingsPage.port, settingsPage.authCode);
                        }
                    },
                    Action
                    {
                        iconName: "system-shutdown"
                        text: i18n.tr("Quit")
                        onTriggered: Qt.quit();
                    }
                ]
                trailingActionBar.actions: [
                    Action
                    {
                        iconName: "settings"
                        text: i18n.tr("Settings")
                        onTriggered:
                        {
                            pageStack.push(settingsPage);
                        }
                    },
                    Action
                    {
                        iconSource: "assets/playlists.svg"
                        text: i18n.tr("Play lists")
                        onTriggered:
                        {
                            slideViewPlayLists.isVisible() ? slideViewPlayLists.hideMenu() : slideViewPlayLists.showMenu();
                        }
                    },
                    Action
                    {
                        iconName: "search"
                        text: i18n.tr("Search")
                        onTriggered:
                        {
                            pageStack.push(Qt.resolvedUrl("SearchPage.qml"));
                        }
                    }
                ]

                StyleHints {
                    foregroundColor: UbuntuColors.orange
                    backgroundColor: UbuntuColors.porcelain
                    dividerColor: UbuntuColors.slate
                }
            }

            ActivityIndicator
            {
                id: busyIndicator
                running: false
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label
            {
                id: statusMessageArea
                anchors
                {
                    top: busyIndicator.bottom
                    horizontalCenter: busyIndicator.horizontalCenter
                }
                visible: busyIndicator.running
            }

            ClementineProxy
            {
                id: clementineProxy
                property int propDownloadQueueSize

                Component.onCompleted:
                {
                    clementineProxy.playLists = playLists;
                    clementineProxy.onUpdatePlayerStatus.connect(currentSong.onPlayerStatus);
                }

                onUpdatePlayLists:
                {
                    listModelPlayLists.clear();

                    for(var i = 0; i < playLists.length; i++)
                    {
                        listModelPlayLists.append({"name": playLists[i].name, "id": playLists[i].id,
                                                      "isActive": playLists[i].isActive});
                    }
                    mainPage.statusMessage(i18n.tr("Loading songs ..."));
                }

                onActiveSongChanged:
                {
                    currentSong.title = song.title;
                    currentSong.songLength = song.length;
                    currentSong.art.source = "image://songArt/current" + Math.random();
                }

                onUpdateSongPosition:
                {
                    currentSong.setSongPosition(position);
                }

                onUpdateDownloadProgress:
                {
                    if(chunk == 0)
                    {
                        downloadManager.downloadTitle = songFileName;
                        return;
                    }

                    propDownloadQueueSize = clementineProxy.downloadQueueSize();

                    downloadManager.setDownloadProgress((chunk/chunks)*100);

                    // Download completed
                    if(chunk == chunks)
                    {
                        transferSongFilePage.songFile = clementineProxy.getCacheFolder() + "/" + downloadManager.downloadTitle;
                        pageStack.push(transferSongFilePage);
                        downloadManager.setDownloadProgress(0);
                        downloadManager.downloadTitle = i18n.tr("Waiting for the next file ...");

                    }

                    if(propDownloadQueueSize === 0)
                    {
                        downloadManager.setDownloadQueueSizeInfo("");
                        downloadManager.downloadTitle = "...";
                        slideViewDownloader.hideMenu();
                        slideViewDownloader.visible = false;
                    }
                    else
                    {
                        if(propDownloadQueueSize > 1)
                            downloadManager.setDownloadQueueSizeInfo("(" + propDownloadQueueSize + i18n.tr(" in queue)"));
                        else
                            downloadManager.setDownloadQueueSizeInfo("");
                    }
                }

                onConnectionStatusChanged:
                {
                    // TODO add GUI for connection status
                    switch(connectionStatus)
                    {
                        case ClementineProxy.Connecting:
                            mainPage.statusMessage(i18n.tr("Connecting to Clementine player ..."));
                            busyIndicator.running = true;
                            actionConnect.text = i18n.tr("Connecting ...");
                            actionConnect.enabled = false;
                            break;

                        case ClementineProxy.Connected:
                            mainPage.statusMessage(i18n.tr("Loading playlists ..."));
                            actionConnect.text = i18n.tr("Disconnect");
                            actionConnect.enabled = true;
                            break;

                        case ClementineProxy.Disconnected:
                            busyIndicator.running = false;
                            actionConnect.text = i18n.tr("Connect");
                            actionConnect.enabled = true;
                            break;

                        case ClementineProxy.ConnectionError:
                            mainPage.statusMessage(clementineProxy.getCommunicationError());
                            actionConnect.text = i18n.tr("Connect");
                            actionConnect.enabled = true;
                            break;

                    }
                }
            }

            PlayLists
            {
                id: playLists
                function setActivePlayList(playList)
                {
                    currentPlayListModel.clear();

                    currentPlayListName.text = playList.name;

                    var songs = playList.songs();

                    for(var i = 0; i < songs.length; i++)
                    {
                        currentPlayListModel.append({"name": songs[i].title, "id": songs[i].id, "sindex": songs[i].index,
                                                        "surl": songs[i].url, "sfilename": songs[i].filename,
                                                        "plid": playList.id
                                                    });
                    }
                }

                onActivePlayListChanged:
                {
                    setActivePlayList(playList);
                }

                onPlayListSongs:
                {
                    // Stop the loading indicator
                    busyIndicator.running = false;
                    setActivePlayList(playList);
                }

                onClearPlaylists:
                {
                    listModelPlayLists.clear();
                }
            }

            SlideView
            {
                id: slideViewDownloader
                sliderPosition: Qt.TopEdge
                backgroundColor: "transparent"
                menuVisible: false
                anchors
                {
                    top: pageHeader.bottom
                    left: parent.left
                    right: parent.right
                }
                visible: false
                autoHideMenu: false
                drawerHeight: downloadManager.height + units.gu(1) // add the top margin from the DownloadManager
                drawerWidth: parent.width
                z: 150

                DownloadManager
                {
                    id: downloadManager
                    anchors
                    {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        topMargin: units.gu(1)
                        leftMargin: units.gu(5)
                        rightMargin: units.gu(5)
                    }

                    backgroundColor: "white"
                }
            }

            SlideView
            {
                id: slideViewPlayLists
                z: 100
                sliderPosition: Qt.LeftEdge
                menuVisible: false
                buttonVisible: false

                anchors
                {
                    top: pageHeader.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: units.gu(2)
                }

                backgroundColor: "#F0F0F0"
                backgroundOpacity: 1.0
                border.color: UbuntuColors.orange
                border.width: 1

                autoHideMenu: false
                drawerWidth: parent.width * 0.8
                drawerHeight: height
                height: parent.height - pageHeader.height - currentSong.height - units.gu(4)

                onShown:
                {
                    //z = 100;
                }

                onHidden:
                {
                    //z = 0;
                }

                Text
                {
                    id: drawerHeader
                    anchors
                    {
                        top: parent.top
                        left: parent.left
                        right: parent.right

                        topMargin:units.gu(1)
                        leftMargin: units.gu(1)
                        rightMargin: units.gu(1)
                    }

                    text: i18n.tr("Play lists")
                    color: UbuntuColors.orange
                    font.bold: true
                    font.pixelSize: FontUtils.modularScale("small") * units.dp(20)
                }

                Component {
                    id: highlightPlayLists
                    Rectangle
                    {
                        width: 180; height: 140
                        color: "lightsteelblue"; radius: 5
                        y: listViewPlayLists.currentItem.y

                        Behavior on y
                        {
                            NumberAnimation { duration: 400; easing.type: Easing.OutQuad; }
                        }
                    }
                }
                ListView
                {
                    id: listViewPlayLists
                    anchors
                    {
                        top: drawerHeader.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: units.gu(2)
                        rightMargin: units.gu(10)
                    }
                    highlight: highlightPlayLists
                    height: parent.height
                    model: listModelPlayLists

                    delegate: Item {
                        width: parent.width
                        height: label.height*1.5
                        property int playListId: id
                        Text
                        {
                            id: label
                            text: name

                            anchors
                            {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            font.pixelSize: FontUtils.modularScale("small") * units.dp(20)
                            elide: Text.ElideRight
                        }
                        MouseArea
                        {
                            id: mouseArea
                            z: 1
                            hoverEnabled: false
                            anchors.fill: parent
                            onClicked:
                            {
                                if(listViewPlayLists.currentIndex == index)
                                {
                                    return;
                                }

                                listViewPlayLists.currentIndex = index;
                                clementineProxy.playSong(0, playListId);
                            }
                        }
                    }
                }

                ListModel
                {
                    id: listModelPlayLists
                }
            }

            Text
            {
                id: currentPlayListName
                anchors
                {
                    top: pageHeader.bottom
                    left: parent.left
                    right: parent.right

                    topMargin: units.gu(1)
                    leftMargin: units.gu(1)
                }
                font.bold: true
                font.pixelSize: FontUtils.modularScale("small") * units.dp(20)
            }

            Component
            {
                id: highlight

                Rectangle
                {

                    id: highlightContainer
                    width: listViewPlayList.currentItem.width;
                    height: listViewPlayList.currentItem.height

                    color: "transparent";
                    border.color: UbuntuColors.orange
                    border.width: 2
                    radius: 5

                    z:10
                    y: listViewPlayList.currentItem.y

                    Behavior on y {
                        SpringAnimation {
                            spring: 3
                            damping: 0.2
                        }
                    }

                    ButtonSvg
                    {
                        id: buttonPlay

                        anchors
                        {
                            right: buttonDownload.left
                            rightMargin: units.gu(1)
                            verticalCenter: parent.verticalCenter
                        }
                        svg: "assets/play.svg"
                        iconHeight: parent.height * 0.8
                        iconWidth:  parent.height * 0.8
                        z: 10
                        onClicked:
                        {
                            Haptics.play();
                            clementineProxy.playSong(listViewPlayList.currentItem.songIndex, listViewPlayList.currentItem.playListId);
                        }
                    }

                    ButtonSvg
                    {
                        id: buttonDownload
                        visible: clementineProxy.propDownloadQueueSize < 3
                        anchors
                        {
                            right: parent.right
                            rightMargin: units.gu(1)
                            verticalCenter: parent.verticalCenter
                        }
                        svg: "assets/download.svg"
                        iconHeight: parent.height * 0.8
                        iconWidth:  parent.height * 0.8
                        z: 10
                        onClicked:
                        {
                            Haptics.play();
                            clementineProxy.downloadSong(listViewPlayList.currentItem.playListId, listViewPlayList.currentItem.songUrl);
                            clementineProxy.propDownloadQueueSize = clementineProxy.downloadQueueSize();
                            slideViewDownloader.visible = true;
                            slideViewDownloader.showMenu();
                        }
                    }
                }
            }

            ListView
            {
                id: listViewPlayList
                anchors
                {
                    top: currentPlayListName.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: units.gu(2)
                    rightMargin: units.gu(2)
                    bottomMargin: currentSong.height
                }
                highlight: highlight
                highlightFollowsCurrentItem: false
                model: currentPlayListModel

                focus: true
                delegate: Item {
                    anchors
                    {
                        left: parent.left
                        right: parent.right
                    }
                    height: songName.height*1.5
                    property int songIndex: sindex
                    property int songId: id
                    property int playListId: plid
                    property string songUrl: surl
                    property string songFileName: sfilename
                    Text
                    {
                        id: songName
                        text: name
                        anchors
                        {
                            left: parent.left
                            right: parent.right
                            leftMargin: units.gu(1)
                            verticalCenter: parent.verticalCenter
                        }
                        elide: Text.ElideMiddle
                        font.pixelSize: FontUtils.modularScale("small") * units.dp(20)
                    }
                    MouseArea {
                        id: mouseAreaPlayListItem
                        hoverEnabled: false
                        anchors.fill: parent
                        propagateComposedEvents: true
                        onClicked:
                        {
                            if(listViewPlayList.currentIndex == index)
                            {
                                //mouse.accepted = false;
                                return;
                            }

                           // mouse.accepted = true;
                            listViewPlayList.currentIndex = index;
                        }
                    }
                }
            }

            ListModel
            {
                id: currentPlayListModel
            }

            SlideView
            {
                id: slideViewCurrentSong
                sliderPosition: Qt.BottomEdge
                backgroundColor: "white"
                backgroundOpacity: 1.0
                restPosition: currentSong.height
                menuVisible: false
                anchors
                {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                visible: true
                autoHideMenu: false
                drawerHeight: parent.height/2 + units.gu(1)
                drawerWidth: parent.width

                z: 150

                CurrentSong
                {
                    id: currentSong

                    function onPlayerStatus(playerStatus)
                    {
                        switch(playerStatus)
                        {
                            case ClementineProxy.Playing:
                                console.log("playing");
                                break;
                            case ClementineProxy.Paused:
                                console.log("paused");
                                break;
                            case ClementineProxy.Stopped:
                                console.log("stopped");
                                break;
                        }
                    }

                    z: slideViewCurrentSong.dragAreaZ + 100
                    anchors
                    {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }

                    height: units.gu(5)

                    onClickNext:
                    {
                        clementineProxy.playNext();
                    }
                    onClickPrev:
                    {
                        clementineProxy.playPrev();
                    }

                    onPlayPause:
                    {
                        clementineProxy.playPause();
                    }
                }
            }
        }

        Page
        {
            id: transferSongFilePage
            header:
                PageHeader
                {
                    id: pageHeaderTransfer
                    title: "uClementineRemote"
                    z: 151

                    StyleHints {
                        foregroundColor: UbuntuColors.orange
                        backgroundColor: UbuntuColors.porcelain
                        dividerColor: UbuntuColors.slate
                    }
                }

            visible: false
            property var activeTransfer
            property string songFile

            ContentItem
            {
                id: exportItem
            }
            ContentPeerPicker
            {
                id: peerPicker
                handler: ContentHandler.Destination
                contentType: ContentType.Music

                anchors
                {
                    top: pageHeaderTransfer.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                onPeerSelected:
                {
                    if(peer)
                    {
                        var transfer = peer.request();
                        var items = new Array;
                        exportItem.url = transferSongFilePage.songFile;
                        items.push(exportItem);
                        transfer.items = items;
                        transfer.state = ContentTransfer.Charged;

                        transferSongFilePage.activeTransfer = transfer;
                        pageStack.push(mainPage);
                    }
                }
                onCancelPressed: {
                    pageStack.push(mainPage);
                }
            }

            ContentTransferHint
            {
                id: transferHint
                visible: true
                anchors.fill: transferSongFilePage
                activeTransfer: transferSongFilePage.activeTransfer
            }
        }

        Page
        {
            id: settingsPage

            property alias hostName: hostNameSetting.text
            property alias port: portSetting.text
            property alias authCode: authCodeSetting.text

            Component.onCompleted: loadSettings();

            function loadSettings()
            {
                var db = LocalStorage.openDatabaseSync("uClementineRemote", "1.0", "uClementineRemote!", 100000);
                db.transaction(
                    function(tx) {
                        // Create the tables they dont exist
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Settings(qmlId TEXT NOT NULL, qmlProperty TEXT NOT NULL, qmlValue TEXT)');

                        // Get all the settings
                        var rs = tx.executeSql('SELECT * FROM Settings');

                        var qmlObject;

                        for(var row = 0; row < rs.rows.length; row++)
                        {
                            var items = settingsPage.children;

                            for (var i = 0; i < items.length; i++)
                            {
                                qmlObject = items[i];

                                if(qmlObject)
                                {
                                    if(rs.rows.item(row).qmlId === qmlObject.qmlId)
                                    {
                                        qmlObject[rs.rows.item(row).qmlProperty] = rs.rows.item(row).qmlValue;
                                    }
                                }
                            }
                        }
                    }
                )
            }

            function saveSettings()
            {
                var db = LocalStorage.openDatabaseSync("uClementineRemote", "1.0", "uClementineRemote!", 100000);
                db.transaction(
                    function(tx) {
                        // Create the tables they dont exist
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Settings(qmlId TEXT NOT NULL, qmlProperty TEXT NOT NULL, qmlValue TEXT)');

                        // Get all the chains
                        var rs = tx.executeSql('DELETE FROM Settings');

                        var qmlObject;
                        var items = settingsPage.children;

                        for (var i = 0; i < items.length; i++)
                        {
                            qmlObject = items[i];

                            if(qmlObject.qmlId)
                            {
                                console.log("Save setting: " + qmlObject.qmlId);
                                tx.executeSql('INSERT INTO Settings(qmlId, qmlProperty, qmlValue) VALUES(?,?,?)', [
                                                qmlObject.qmlId,
                                                qmlObject.qmlProperty,
                                                qmlObject[qmlObject.qmlProperty]
                                              ]);
                            }
                        }
                    }
                )
            }

            header: PageHeader
            {
                id: settingsPageHeader
                title: i18n.tr("uClementineRemote settings")
                z: 151

                StyleHints {
                    foregroundColor: UbuntuColors.orange
                    backgroundColor: UbuntuColors.porcelain
                    dividerColor: UbuntuColors.slate
                }
            }

            visible: false

            onVisibleChanged:
            {
                if(!settingsPage.visible)
                    settingsPage.saveSettings();
            }

            Text
            {
                id: connectionSectionText

                anchors
                {
                    top: settingsPageHeader.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: units.gu(1)
                    leftMargin: units.gu(1)
                }

                font.bold: true
                text: i18n.tr("Connection")

            }
            Label
            {
                id: hostNameSettingLabel
                anchors
                {
                    top: connectionSectionText.bottom
                    left: parent.left
                    leftMargin: units.gu(2)
                    topMargin: units.gu(1)
                    bottomMargin: units.gu(1)
                }
                height: hostNameSetting.height
                width: authCodeSettingLabel.width
                verticalAlignment: Text.AlignVCenter
                text: i18n.tr("Host:")
            }
            TextField
            {
                id: hostNameSetting

                property string qmlId: "hostNameSetting"
                property string qmlProperty: "text"

                anchors
                {
                    left: hostNameSettingLabel.right
                    verticalCenter: hostNameSettingLabel.verticalCenter
                    leftMargin: units.gu(1)
                }
                maximumLength: 20
                verticalAlignment: Text.AlignVCenter
            }
            Label
            {
                id: portSettingLabel
                anchors
                {
                    top: hostNameSettingLabel.bottom
                    left: parent.left
                    leftMargin: units.gu(2)
                    topMargin: units.gu(1)
                    bottomMargin: units.gu(1)
                }
                height: portSetting.height
                width: authCodeSettingLabel.width
                verticalAlignment: Text.AlignVCenter
                text: i18n.tr("Port:")
            }
            TextField
            {
                id: portSetting

                property string qmlId: "portSetting"
                property string qmlProperty: "text"

                anchors
                {
                    left: portSettingLabel.right
                    verticalCenter: portSettingLabel.verticalCenter
                    leftMargin: units.gu(1)
                }
                inputMask: "#####"
                verticalAlignment: Text.AlignVCenter
            }
            Label
            {
                id: authCodeSettingLabel
                anchors
                {
                    top: portSettingLabel.bottom
                    left: parent.left
                    leftMargin: units.gu(2)
                    topMargin: units.gu(1)
                    bottomMargin: units.gu(1)
                }
                height: authCodeSetting.height
                verticalAlignment: Text.AlignVCenter
                text: i18n.tr("Authentication code:")
            }
            TextField
            {
                id: authCodeSetting

                property string qmlId: "authCodeSetting"
                property string qmlProperty: "text"

                anchors
                {
                    left: authCodeSettingLabel.right
                    verticalCenter: authCodeSettingLabel.verticalCenter
                    leftMargin: units.gu(1)
                }
                inputMask: "#####"
                verticalAlignment: Text.AlignVCenter
            }

            Label
            {
                id: cacheFolderLabel
                anchors
                {
                    top: authCodeSetting.bottom
                    left: parent.left
                    leftMargin: units.gu(1)
                    topMargin: units.gu(2)
                    bottomMargin: units.gu(1)
                }

                verticalAlignment: Text.AlignVCenter
                text: i18n.tr("<b>Cache folder:</b> ") + clementineProxy.getCacheFolder()
                wrapMode: Text.WrapAnywhere
            }
        }
    }
}



