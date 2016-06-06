import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.Window 2.2
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

    Page {
        header:
            PageHeader
            {
                id: pageHeader
                title: i18n.tr("uClementineRemote")
                leadingActionBar.actions: [
                    Action
                    {
                        iconName: "contact"
                        text: "Connect"
                        //onTriggered: clementineProxy.connectRemote("192.168.0.9", 5500)
                        onTriggered: clementineProxy.connectRemote("10.42.0.1", 5500)
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
                    },
                    Action
                    {
                        iconName: "info"
                        text: "Second"
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

        ClementineProxy {
            id: clementineProxy

            Component.onCompleted: {
                clementineProxy.playLists = playLists;
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
            onConnectionStatusChanged:
            {
                // TODO add GUI for connection status
            }
        }

        SlideView {
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
                Rectangle {
                    width: 180; height: 140
                    color: "lightsteelblue"; radius: 5
                    y: listViewPlayLists.currentItem.y

                    Behavior on y {
                        SpringAnimation {
                            spring: 3
                            damping: 0.2
                        }
                    }
                }
            }
            ListView {
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
                    currentPlayListModel.append({"name": songs[i].title, "id": songs[i].id, "sindex": songs[i].index, "plid": playList.id});
                }
            }
            onNewPlayList:
            {
                listModelPlayLists.append({"name": playList.name, "id": playList.id, "isActive": playList.isActive});
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

        Component {
            id: highlight
            Rectangle {
                width: 180; height: 140
                color: "lightsteelblue"; radius: 5
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
                        clementineProxy.playNext();
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
            highlightFollowsCurrentItem: true
            model: currentPlayListModel
            focus: true
            delegate: Item {
                width: parent.width
                height: songName.height*1.5
                property int songIndex: sindex
                property int songId: id
                property int playListId: plid
                Text {
                    id: songName
                    text: name
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: FontUtils.modularScale("small") * units.dp(20)
                }
                MouseArea {
                    id: mouseArea
                    z: 1
                    hoverEnabled: false
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onClicked:
                    {
                        if(listViewPlayList.currentIndex == index)
                        {
                            mouse.accepted = false;
                            return;
                        }

                        mouse.accepted = true;
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
}



