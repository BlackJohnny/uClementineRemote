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
    property alias downloadTitle: songTitle.text
    property alias backgroundColor: root.color

    function setDownloadProgress(position)
    {
        downloadProgress.width = (downloadProgress.parent.width * position) / 100;
    }

    function setDownloadQueueSizeInfo(queueSizeInfo)
    {
        queueStatus.text = queueSizeInfo;
    }

    signal clickCancel()

    border.color: UbuntuColors.orange
    border.width: units.gu(0.1)
    radius: units.gu(1)
    height: title.height + songTitle.height + progressBar.height + units.gu(3)

    Text
    {
        id: title
        text: i18n.tr("Downloading")
        anchors
        {
            left: parent.left
            //right: parent.right
            top: parent.top
            topMargin: units.gu(1)
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
        }
        verticalAlignment: Text.AlignVCenter
        font.bold: true
        font.pixelSize: FontUtils.modularScale("small") * units.dp(20)
    }
    Text
    {
        id: queueStatus
        anchors
        {
            left: title.right
            right: parent.right
            leftMargin: units.gu(1)
            verticalCenter: title.verticalCenter
        }
        verticalAlignment: Text.AlignVCenter
        font.bold: false
        font.pixelSize: FontUtils.modularScale("small") * units.dp(20)
    }
    Text
    {
        id: songTitle
        anchors
        {
            left: parent.left
            right: parent.right
            top: title.bottom
            topMargin: units.gu(1)
            leftMargin: units.gu(5)
            rightMargin: units.gu(5)
        }
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: FontUtils.modularScale("small") * units.dp(20)
    }
    Rectangle
    {
        id: progressBar
        anchors
        {
            left: parent.left
            right: parent.right
            top: songTitle.bottom
            leftMargin: units.gu(5)
            rightMargin: units.gu(5)
        }

        height: units.gu(3)
        border.color: UbuntuColors.orange
        border.width: units.gu(0.3)

        Rectangle
        {
            id: downloadProgress
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

    ButtonSvg
    {
        id: buttonCancel

        anchors
        {
            left: progressBar.right
            leftMargin: units.gu(1)
            verticalCenter: progressBar.verticalCenter
        }

        svg: "assets/cancel.svg"
        iconHeight: progressBar.height
        iconWidth:  progressBar.height

        onClicked:
        {
            clickCancel();
        }
    }
}
