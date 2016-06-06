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

/*!
    \qmltype SlideView
    The following example will create a slide view containing one button.

    \qml
    SlideView {
        id: slideViewLeft

        sliderPosition: Qt.LeftEdge
        menuVisible: false
        anchors.fill: parent
        autoHideMenu: false
        drawerWidth: Screen.pixelDensity * 11 * 4

        Button {
            text: "Button"
        }
    }
    \endqml

    \sa SlidePage
*/

Item {
    id: root

    property alias drawerHeight: menuView.height
    property alias drawerWidth: menuView.width
    property alias backgroundColor: backgroundItem.color
    property alias backgroundRadius: backgroundItem.radius
    property alias backgroundOpacity: backgroundItem.opacity

    /*! On which side to place the slider.

        By default this is set to \c Qt.TopEdge.
    */
    property int sliderPosition: Qt.TopEdge


    /*! Whether the menu is currently visible or not.
    */
    property bool menuVisible: false

    /*! Whether the menu should be automatically hidden if an item from the menu was selected.

        By default this is set to \c true.
    */
    property bool autoHideMenu: true

    /*! Whether the small button to open the menu should be visible.

        By default this is set to \c true.
    */
    property alias buttonVisible: menuButton.visible

    property int _radius: Screen.pixelDensity * 3

    /*! Shows the menu.
    */
    function showMenu() {
        menuVisible = true
    }

    /*! Hides the menu.
    */
    function hideMenu() {
        menuVisible = false
    }

    function signalVisible()
    {
        console.log("test");
        if(menuVisible)
            shown();
        else
            hidden();
    }

    signal shown();
    signal hidden();

    /*! \internal */
    function _updateItems() {
        var items = root.children
        var filteredItems = []
        var i

        for (i = items.length-1; i >= 0; --i) {
            if (items[i] === menuView )
                continue

            if (items[i] === mouseArea )
                continue

            if (items[i] === menuButton)
                continue

            filteredItems.push(items[i])
        }

        for (i = filteredItems.length-1; i >= 0; --i) {
            filteredItems[i].parent = menuView
        }
    }

    SystemPalette {
        id: systemPalette; colorGroup: SystemPalette.Active
    }

    MouseArea
    {
        property int startX: 0
        property int startY: 0

        property int dragX: pressed ? mouseX - startX : 0
        property int dragY: pressed ? mouseY - startY : 0

        property int dragThresholdX: menuView.width * 0.1
        property int dragThresholdY: menuView.height * 0.1

        id: mouseArea

        anchors.fill: menuView.parent
        z: !menuVisible ? 100 : 0

        onPressed:
        {
            startX = mouseX;
            startY = mouseY;
        }

        onReleased:
        {
            switch(sliderPosition)
            {
                case Qt.TopEdge:
                    if(dragY == 0)
                        return;

                    if(Math.abs(dragY) > dragThresholdY)
                    {
                        if(dragY < 0)
                            menuVisible = false
                        else
                            menuVisible = true
                    }
                    break;
                case Qt.LeftEdge:
                    if(dragX == 0)
                        return;

                    if(Math.abs(dragX) > dragThresholdX)
                    {
                        if(dragX < 0)
                            menuVisible = false
                        else
                            menuVisible = true
                    }
                    break;

                case Qt.RightEdge:
                    if(dragX == 0)
                        return;

                    if(Math.abs(dragX) > dragThresholdX)
                    {
                        if(dragX > 0)
                            menuVisible = false
                        else
                            menuVisible = true
                    }
                    break;
            }
        }
    }

    Rectangle
    {
       id: menuView

       anchors.top: {
           switch(sliderPosition)
           {
                case Qt.TopEdge:
                    return;
                case Qt.LeftEdge:
                    return parent.top;
                case Qt.RightEdge:
                    return parent.top;
                case Qt.BottomEdge:
                    return parent.bottom;
           }
       }

       anchors.bottom: {
           switch(sliderPosition)
           {
                case Qt.TopEdge:
                    return parent.top;
                case Qt.LeftEdge:
                    return parent.bottom;
                case Qt.RightEdge:
                    return parent.bottom;
                case Qt.BottomEdge:
                    return;
           }
       }
       anchors.left: {
           switch(sliderPosition)
           {
                case Qt.TopEdge:
                    return parent.left;
                case Qt.LeftEdge:
                    return;
                case Qt.RightEdge:
                    return parent.right;
                case Qt.BottomEdge:
                    return parent.left
           }
       }

       anchors.right: {
           switch(sliderPosition)
           {
                case Qt.TopEdge:
                    return parent.right;
                case Qt.LeftEdge:
                    return parent.left;
                case Qt.RightEdge:
                    return;
                case Qt.BottomEdge:
                    return parent.right;
           }
       }

       color: "transparent"

       opacity: 1//viewTranslate.y/height
       enabled: opacity != 0
       Rectangle
       {
           id: backgroundItem
           anchors {
               left: parent.left
               top: parent.top
               bottom: parent.bottom
               right: parent.right
           }

           anchors.rightMargin: sliderPosition == Qt.RightEdge ? -root._radius : 0;
           anchors.topMargin: sliderPosition == Qt.TopEdge ? -root._radius : 0;
           anchors.leftMargin: sliderPosition == Qt.LeftEdge ? -root._radius : 0;
           anchors.bottomMargin: sliderPosition == Qt.BottomEdge ? -root._radius : 0;

           color: "gray"
           opacity: 0.5
           radius: root._radius
           z: 0
       }

       transform:
           Translate {
                   id: viewTranslate

                   // signal show/hidden
                   onXChanged: if(x == 0 && (sliderPosition == Qt.LeftEdge || sliderPosition == Qt.RightEdge )) { signalVisible(); }
                   onYChanged: if(y == 0 && (sliderPosition == Qt.TopEdge || sliderPosition == Qt.BottomEdge )) { signalVisible(); }

                   x: {
                       if(sliderPosition == Qt.LeftEdge)
                           return menuVisible ? Math.max(0, menuView.width + Math.min(0, mouseArea.dragX)) :  Math.min(menuView.width, Math.max(0, mouseArea.dragX));
                       else if(sliderPosition == Qt.RightEdge)
                           return menuVisible ? Math.max(-menuView.width, -menuView.width + Math.min(menuView.width, mouseArea.dragX)) :  Math.min(0, Math.max(-menuView.width, mouseArea.dragX));

                       return 0;
                   }

                   y: {
                       // TODO: update for BottomEdge
                       if(sliderPosition != Qt.TopEdge)
                           return 0;

                       return menuVisible ? Math.max(0, menuView.height + Math.min(0, mouseArea.dragY)) :  Math.min(menuView.height, Math.max(0, mouseArea.dragY));
                   }
                   Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutQuad; } }
                   Behavior on y { NumberAnimation { duration: 400; easing.type: Easing.OutQuad; } }
               }
    }

    Rectangle
    {
        id: menuButton
        width: {
            if(sliderPosition == Qt.TopEdge || sliderPosition == Qt.BottomEdge)
                return Screen.pixelDensity * 10;
            else
                return Screen.pixelDensity * 2;
        }
        height: {
            if(sliderPosition == Qt.TopEdge || sliderPosition == Qt.BottomEdge)
                return Screen.pixelDensity * 2;
            else
                return Screen.pixelDensity * 10;
        }
        color: "transparent"
        opacity: 0.8
        z: 0

        anchors {
                    horizontalCenter:
                    {
                        switch(sliderPosition)
                        {
                             case Qt.TopEdge:
                                 return menuView.horizontalCenter;
                             case Qt.LeftEdge:
                                 return;
                             case Qt.RightEdge:
                                 return;
                             case Qt.BottomEdge:
                                 return menuView.horizontalCenter;
                        }
                    }
                    verticalCenter:
                    {
                        switch(sliderPosition)
                        {
                             case Qt.TopEdge:
                                 return;
                             case Qt.LeftEdge:
                                 return menuView.verticalCenter;
                             case Qt.RightEdge:
                                 return menuView.verticalCenter;
                             case Qt.BottomEdge:
                                 return;
                        }
                    }

                    top:
                    {
                        if(sliderPosition == Qt.TopEdge)
                            return menuView.bottom;

                        return;
                    }
                    left:
                    {
                        if(sliderPosition == Qt.LeftEdge)
                            return menuView.right;

                        return;
                    }
                    right:
                    {
                        if(sliderPosition == Qt.RightEdge)
                            return menuView.left;

                        return;
                    }
                    bottom:
                    {
                        if(sliderPosition == Qt.BottomEdge)
                            return menuView.top;

                        return;
                    }

                    margins: 0
                }
        transform: Translate {
                    id: menuButtonTranslate
                    y:
                    {
                        if(sliderPosition == Qt.TopEdge || sliderPosition == Qt.BottomEdge)
                            return viewTranslate.y;

                        return 0.0;
                    }
                    x:
                    {
                        if(sliderPosition == Qt.LeftEdge || sliderPosition == Qt.RightEdge)
                            return viewTranslate.x;

                        return 0.0;
                    }
                }

        Image
        {
            id: buttonImage
            anchors.fill: menuButton
            smooth: true
            sourceSize.width: menuButton.width
            sourceSize.height: menuButton.height
            source:
            {
                switch(sliderPosition)
                {
                     case Qt.TopEdge:
                         return "assets/slider-down.svg";
                     case Qt.LeftEdge:
                         return "assets/slider-left.svg";
                     case Qt.RightEdge:
                         return "assets/slider-right.svg";
                     case Qt.BottomEdge:
                         return "assets/slider-top.svg";
                }
            }
            visible: false
        }
        ColorOverlay {
            anchors.fill: buttonImage
            source: buttonImage
            color: "gray"
            cached: true
            //visible: sliderPosition == Qt.TopEdge ? true : false
        }
    }

    onChildrenChanged: _updateItems()
}

