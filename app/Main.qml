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
                    Action {
                        iconName: "contact"
                        text: "Connect"
                        onTriggered: clementineProxy.connectRemote()
                    },
                    Action {
                        iconName: "quit"
                        text: "Quit"
                    }
                ]
                trailingActionBar.actions: [
                    Action {
                        iconName: "settings"
                        text: "First"
                    },
                    Action {
                        iconName: "info"
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
            menuVisible: true

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            backgroundColor: "#F0F0F0"
            backgroundOpacity: 1.0

            autoHideMenu: false
            drawerWidth: parent.width/2

            height: parent.height - pageHeader.height

            onShown:
            {
                z = 100;
            }

            onHidden:
            {
                z = 0;
            }

            ListView {
                id: listViewPlayLists
                anchors
                {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                height: parent.height
                model: listModelPlayLists

                delegate: Item {
                    width: parent.width
                    height: label.height*1.5

                    Text {
                        id: label
                        text: name
                        anchors.verticalCenter: parent.verticalCenter
                        font.bold: true
                        font.pixelSize: Screen.pixelDensity*5
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
                currentPlayList.clear();
                currentPlayListName.text = playList.name;

                var songs = playList.songs();

                for(var i = 0; i < songs.length; i++)
                {
                    currentPlayList.append({"name": songs[i].title});
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

        CurrentSong
        {
            id: currentSong

            anchors {
                top: pageHeader.bottom
                left: parent.left
                right: parent.right
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

        Text
        {
            id: currentPlayListName
            anchors
            {
                top: currentSong.bottom
                left: parent.left
                right: parent.right
            }
            font.bold: true
            font.pixelSize: FontUtils.modularScale("small") * units.dp(20)
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
            }

            width: parent.width
            model: currentPlayList

            delegate: Item {
                width: parent.width
                height: songName.height*1.5

                Text {
                    id: songName
                    text: name
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: FontUtils.modularScale("small") * units.dp(20)
                }
            }
        }

        ListModel
        {
            id: currentPlayList
        }
    }
}



