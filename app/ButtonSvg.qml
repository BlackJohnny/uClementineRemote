import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

Item {
    id: root

    property alias svg: buttonImage.source
    property alias iconHeight: buttonImage.sourceSize.height
    property alias iconWidth: buttonImage.sourceSize.width

    signal clicked()

    width: iconWidth
    height: iconHeight

    Component.onCompleted:
    {
        buttonMouseArea.clicked.connect(clicked)
    }

    Image
    {
        id: buttonImage
        anchors
        {
            horizontalCenter: root.horizontalCenter
        }
        smooth: true
        visible: true
        opacity: buttonMouseArea.pressed ? 0.5 : 1.0
    }

    MouseArea
    {
        id: buttonMouseArea
        anchors.fill: buttonImage
        z: 50
    }
}

