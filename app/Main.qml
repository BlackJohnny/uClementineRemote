import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.Window 2.2
import Ubuntu.Content 1.3
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

            header: PageHeader
            {
                id: pageHeader
                title: "uClementineRemote"
                z: 151
                leadingActionBar.actions: [
                    Action
                    {
                        iconName: "contact"
                        text: "Connect"
                        //onTriggered: clementineProxy.connectRemote("192.168.1.11", 5500, 0);
                        onTriggered: clementineProxy.connectRemote("192.168.0.9", 5500, 0);
                        //onTriggered: clementineProxy.connectRemote("10.42.0.1", 5500, 0);
                    },
                    Action
                    {
                        iconName: "quit"
                        text: "Play lists"
                        onTriggered:
                        {
                            slideView.z = 100;
                            slideView.showMenu();
                        }
                    },
                    Action
                    {
                        iconName: "quit"
                        text: "Quit"
                    }
                ]
                trailingActionBar.actions: [
                    Action
                    {
                        iconName: "settings"
                        text: "First"
                        onTriggered:
                        {
                            pageStack.push(settingsPage);
                        }
                    },
                    Action
                    {
                        iconSource: "assets/download.svg"
                        text: i18n.tr("Downloads")
                        onTriggered:
                        {
                            slideViewTop.showMenu();
                        }
                    },
                    Action
                    {
                        iconName: "search"
                        text: "Second"
                    }
                ]

                StyleHints {
                    foregroundColor: UbuntuColors.orange
                    backgroundColor: UbuntuColors.porcelain
                    dividerColor: UbuntuColors.slate
                }
            }

            ClementineProxy
            {
                id: clementineProxy
                property int propDownloadQueueSize

                Component.onCompleted: {
                    clementineProxy.playLists = playLists;
                }

                onUpdatePlayLists:
                {
                    listModelPlayLists.clear();

                    for(var i = 0; i < playLists.length; i++)
                    {
                        listModelPlayLists.append({"name": playLists[i].name, "id": playLists[i].id,
                                                      "isActive": playLists[i].isActive});
                    }
                }

                onActiveSongChanged:
                {
                    currentSong.title = song.title;
                    currentSong.songLength = song.length;
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
                        downloadManager.downloadTitle = i18n.tr("Idle");
                        slideViewTop.hideMenu();
                        slideViewTop.visible = false;
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
                    setActivePlayList(playList);
                }

                onClearPlaylists:
                {
                    listModelPlayLists.clear();
                }
            }

            SlideView
            {
                id: slideViewTop
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
                drawerWidth: downloadManager.width
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
                id: slideView
                z: 100
                sliderPosition: Qt.LeftEdge
                menuVisible: false
                buttonVisible: false

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                backgroundColor: "#F0F0F0"
                backgroundOpacity: 1.0

                autoHideMenu: false
                drawerWidth: parent.width * 0.8

                height: parent.height - pageHeader.height

                onShown:
                {
                    z = 100;
                }

                onHidden:
                {
                    z = 0;
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
                        rightMargin: units.gu(2)
                    }
                    highlight: highlightPlayLists
                    height: parent.height
                    model: listModelPlayLists

                    delegate: Item {
                        width: parent.width
                        height: label.height*1.5
                        property int playListId: id
                        Text {
                            id: label
                            text: name
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: FontUtils.modularScale("small") * units.dp(20)
                        }
                        MouseArea {
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

                Rectangle {

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
                            downloadManager.downloadTitle = i18n.tr("Downloading");
                            clementineProxy.downloadSong(listViewPlayList.currentItem.playListId, listViewPlayList.currentItem.songUrl);
                            clementineProxy.propDownloadQueueSize = clementineProxy.downloadQueueSize();
                            slideViewTop.visible = true;
                            slideViewTop.showMenu();
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
                    bottom: currentSong.top
                    leftMargin: units.gu(2)
                    rightMargin: units.gu(2)
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

            CurrentSong
            {
                id: currentSong

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                height: Screen.pixelDensity*10

                onClickNext:
                {
                    clementineProxy.playNext();
                }
                onClickPrev:
                {
                    clementineProxy.playPrev();
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

            Rectangle
            {
                id: connectionSection
                anchors
                {
                    top: settingsPageHeader.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: units.gu(1)
                    leftMargin: units.gu(1)
                }

                Text
                {
                    id: connectionSectionText
                    anchors
                    {
                        top: connectionSection.bottom
                        left: parent.left
                        right: parent.right
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
                        leftMargin: units.gu(1)
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
                        leftMargin: units.gu(1)
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
                        leftMargin: units.gu(1)
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
                    anchors
                    {
                        left: authCodeSettingLabel.right
                        verticalCenter: authCodeSettingLabel.verticalCenter
                        leftMargin: units.gu(1)
                    }
                    inputMask: "#####"
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}



