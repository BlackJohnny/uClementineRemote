import QtQuick 2.4
import Ubuntu.Components 1.3

Page
{
    id: searchPage

    header: PageHeader
    {
        id: searchPageHeader
        title: i18n.tr("uClementineRemote search")
        z: 151

        StyleHints {
            foregroundColor: UbuntuColors.orange
            backgroundColor: UbuntuColors.porcelain
            dividerColor: UbuntuColors.slate
        }
    }

    TextField
    {
        id: searchQuery
        anchors
        {
            top: searchPageHeader.bottom
            left: parent.left
            right: searchButton.left
            rightMargin: units.gu(1)
            leftMargin: units.gu(1)
            topMargin: units.gu(1)
        }
        text: ""
    }
    ButtonSvg
    {
        id: searchButton
        anchors
        {
            right: parent.right
            rightMargin: units.gu(1)
            verticalCenter: searchQuery.verticalCenter
        }
        svg: "assets/play.svg"
        iconHeight: searchQuery.height * 0.8
        iconWidth:  searchQuery.height * 0.8
        onClicked:
        {
            clementineProxy.search(searchQuery.text);
            clementineProxy.onSearchResultsAvailable.connect(searchResults);
        }

        function searchResults(id, provider, songs)
        {
            console.log(provider);
            for(var i = 0; i < songs.length; i++)
            {
                var song = songs[i];
                console.log(song);
                console.log(song.title);
                resultsListModel.append({"sprovider": provider, "name": songs[i].title});
            }
        }
    }
    Component
    {
        id: highlight

        Rectangle
        {

            id: highlightContainer
            width: listViewSearchResults.currentItem.width;
            height: listViewSearchResults.currentItem.height

            color: "transparent";
            border.color: UbuntuColors.orange
            border.width: 2
            radius: 5

            z:10
            y: listViewSearchResults.currentItem.y

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
                    clementineProxy.playSong(listViewSearchResults.currentItem.songIndex, listViewSearchResults.currentItem.playListId);
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
                    clementineProxy.downloadSong(listViewSearchResults.currentItem.playListId, listViewSearchResults.currentItem.songUrl);
                    clementineProxy.propDownloadQueueSize = clementineProxy.downloadQueueSize();
                    slideViewDownloader.visible = true;
                    slideViewDownloader.showMenu();
                }
            }
        }
    }

    ListView
    {
        id: listViewSearchResults
        anchors
        {
            top: searchQuery.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }
        highlight: highlight
        highlightFollowsCurrentItem: false
        model: resultsListModel

        focus: true
        delegate: Item {
            anchors
            {
                left: parent.left
                right: parent.right
            }
            height: songName.height*1.5

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
                    if(listViewSearchResults.currentIndex == index)
                    {
                        //mouse.accepted = false;
                        return;
                    }

                   // mouse.accepted = true;
                    listViewSearchResults.currentIndex = index;
                }
            }
        }
    }

    ListModel
    {
        id: resultsListModel
    }
}


