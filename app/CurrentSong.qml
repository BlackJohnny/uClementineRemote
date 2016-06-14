/****************************************************************************
**
** Copyright (C) 2014 Alexander Rössler
** License: LGPL version 2.1
**
** This file is part of QtQuickVcp.
**
** All rights reserved. This program and the accompanying materials
** are made available under the terms of the GNU Lesser General Public License
** (LGPL) version 2.1 which accompanies this distribution, and is available at
** http://www.gnu.org/licenses/lgpl-2.1.html
**
** This library is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
** Lesser General Public License for more details.
**
** Contributors:
** Alexander Rössler @ The Cool Tool GmbH <mail DOT aroessler AT gmail DOT com>
**
****************************************************************************/

import QtQuick 2.0
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.3

Rectangle {
    id: root
    property alias title: songTitle.text
    property int songLength: 0
    property alias art: artImage

    function setSongPosition(position)
    {
        songProgress.width = (songProgress.parent.width * position) / songLength;
    }
    function onParentXChanged(parentX)
    {
        console.log(parentX)
    }

    Component.onCompleted: {
        root.parent.onYChanged.connect(onParentXChanged);
    }

    signal clickNext()
    signal clickPrev()
    signal playPause()

    Rectangle
    {
        id: progressBar
        border.width: 1
        height: 4
        border.color: UbuntuColors.orange
        anchors
        {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: songControls.top
        }

        Rectangle
        {
            id: songProgress
            color: UbuntuColors.orange

            anchors
            {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            height: progressBar.height
            width: 0
        }
    }

    Rectangle
    {
        id: songControls
        anchors
        {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: parent.height - progressBar.height

        ButtonSvg
        {
            id: buttonPrev

            anchors
            {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }

            svg: "assets/prev.svg"
            iconHeight: parent.height * 0.8
            iconWidth:  parent.height * 0.8

            onClicked:
            {
                Haptics.play();
                clickPrev();
            }
        }
        Text
        {
            id: songTitle
            anchors
            {
                left: buttonPrev.right
                right: buttonNext.left
                top: parent.top
                bottom: parent.bottom
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
            }
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: FontUtils.modularScale("small") * units.dp(20)
        }

        ButtonSvg
        {
            id: buttonNext

            anchors
            {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            svg: "assets/next.svg"
            iconHeight: parent.height * 0.8
            iconWidth:  parent.height * 0.8

            onClicked:
            {
                Haptics.play();
                clickNext();
            }
        }

        ButtonSvg
        {
            id: buttonPlay
            anchors
            {
                top: songTitle.bottom
                horizontalCenter: parent.horizontalCenter
            }

            svg: "assets/playpause.svg"
            iconHeight: parent.height * 0.8
            iconWidth:  parent.height * 0.8

            onClicked:
            {
                Haptics.play();
                playPause();
            }
        }
        Image
        {
            id: artImage
            smooth: true
            anchors
            {
                top: buttonPlay.bottom
                topMargin: units.gu(1)
                horizontalCenter: parent.horizontalCenter
            }

            height:
            {
                if(sourceSize.height > sourceSize.width)
                    return units.gu(30);
                else
                    return (width/sourceSize.width)*sourceSize.height;
            }
            width:
            {
                if(sourceSize.height > sourceSize.width)
                    (height/sourceSize.height)*sourceSize.width;
                else
                    return units.gu(30);
            }
        }
    }
}
