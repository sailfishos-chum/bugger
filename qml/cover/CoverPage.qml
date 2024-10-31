import QtQuick 2.6
import Sailfish.Silica 1.0

CoverBackground {
    id: coverPage

    property int numBugs: Math.random() * (50 - 10) + 10;

    Grid {
        anchors.centerIn: parent
        columns: 5
        width: parent.width * 1.2
        height: parent.height * 1.2
        spacing: Theme.paddingLarge
        Repeater {
            model: numBugs
            delegate: Image {
                source: "./bgbug.svg"
                z: -1
                opacity: Math.random() - 0.33
                rotation: Math.random() * (180 - 1) + 1
                sourceSize.width: Math.floor(Theme.iconSizeMedium * (Math.random() + 0.5) )
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    CoverPlaceholder {
        text: "Bugger!"
        textColor: Theme.highlightColor
        icon.source: "image://theme/harbour-bugger"
    }
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4 syntax=qml
