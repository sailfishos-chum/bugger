import QtQuick 2.6
import Sailfish.Silica 1.0

CoverBackground {
    id: coverPage

    /*
    Image {
        source: "./background.png"
        z: -1
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        sourceSize.width: parent.width
        fillMode: Image.PreserveAspectFit
        opacity: 0.2
    }
    */

    CoverPlaceholder {
        text: Qt.application.name
        textColor: Theme.highlightColor
        icon.source: "image://theme/icon-splus-error"
        /*
        CoverActionList {
            CoverAction { iconSource: "image://theme/icon-m-sync";            onTriggered: {app.sheepModel.getNewData} }
            CoverAction { iconSource: "image://theme/icon-m-media-playlists"; onTriggered: {pageStack.push(Qt.resolvedUrl("VideoPage.qml"), {"playlist": sheepModel.getPlayList(), "generation": sheepModel.gen, "imgid": qsTr("all")} ) } }
        }
        */
    }
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4
