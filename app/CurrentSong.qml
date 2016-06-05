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

    function setSongPosition(position)
    {
        songProgress.width = (songProgress.parent.width * position) / songLength;
    }

    signal clickNext()
    signal clickPrev()

    Rectangle
    {
        id: row1
        anchors
        {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: parent.height - Screen.pixelDensity*0.5

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
            }

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
                clickNext();
            }
        }
    }

    Rectangle
    {
        id: row2
        anchors
        {
            left: parent.left
            right: parent.right
            top: row1.bottom
            bottom: parent.bottom
        }

        Rectangle
        {
            id: songProgress
            color: "#33ccff"
            anchors
            {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            height: row2.height
            width: 0
        }
    }
}
