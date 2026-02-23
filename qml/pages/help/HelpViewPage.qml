// Copyright (c) 2025 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../../config/meta.js" as Meta
import "../../components"

Page { id: root
    allowedOrientations: Orientation.All

    property string category
    property string title
    property string desc

    readonly property var titles: {
     "tip":   qsTr("Community Tips"),
     "link":   qsTr("Documentation Links"),
     "script": qsTr("Try these commands")
    }


    readonly property var notes: {
     "tip":    qsTr("some things you may try."),
     "link":   qsTr("read these first!"),
     "script": qsTr("but please make sure you know what you're doing. If in doubt, don't.")
    }

    onCategoryChanged: {
        if (!category.length) return
        Meta.data.categories.forEach(function(e) {
            if (e.name == category) {
                e.help.forEach(function(h) {
                    if (h.type == "tip") {
                        h.text = JSON.stringify(h.text)
                        h.links = JSON.stringify(h.links)
                    }
                    if (h.type == "script") {
                        // avoid stupid model-in-a-model
                        h.commands = JSON.stringify(h.commands)
                        h.cleanup = JSON.stringify(h.cleanup)
                    }
                    helpModel.append(h)
                })
            }
        })
    }
    ListModel { id: helpModel }

    SilicaListView {
        anchors.fill: parent
        spacing: Theme.paddingMedium
        model: helpModel
        header: PageHeader { title: qsTr("Resources on %1").arg(root.title); description: root.desc }
        section.property: "type"
        section.delegate: Column {
            width: parent.width
            bottomPadding: Theme.paddingMedium
            SectionHeader { text: root.titles[section] }
            Label { text: root.notes[section]
                width: parent.width*2/3
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.Wrap
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
            }
        }
        delegate: helpItem
        PullDownMenu {
            MenuItem { text: qsTr("Suggest a resource (Email)")
                onClicked: Qt.openUrlExternally("mailto:sailfish@nephros.org?subject=Bugger!:%20New%20Help%20Item:&body=%0A##Title%0A%0A##Description%0A%0A##Links%0A%0A" )
            }
            MenuItem { text: qsTr("Suggest a resource (GitHub)")
                onClicked: Qt.openUrlExternally("https://github.com/sailfishos-chum/bugger/issues/new?title=New%20Help%20Item:&body=%0A##Title%0A%0A##Description%0A%0A##Links%0A%0A" )
            }
        }
    }
         Component { id: helpItem
         ListItem {
            contentHeight: Math.max(Theme.itemSizeMedium, content.height)
            Column { id: content
                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                Loader { active: type == "link"
                    width: parent.width
                    sourceComponent: Row {
                        width: parent.width
                        height: icon.height
                        spacing: Theme.paddingSmall
                        Icon { id: icon
                            source: /sailfishos.org/.test(link)
                               ? "image://theme/icon-m-sailfish"
                               : ( /jolla.com/.test(link)
                                   ? "image://theme/icon-m-jolla"
                                   : "image://theme/icon-m-website"
                               )
                        }
                        Column {
                            width: parent.width - (icon.width + Theme.paddingSmall)
                            anchors.top: icon.top
                            Label{ width: parent.width; text: description; color: Theme.secondaryHighlightColor }
                            Label{ width: parent.width; text: link; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor  }
                        }
                    }
                }
                Loader { active: type == "tip"
                    width: parent.width
                    x: Theme.paddingSmall
                    //height: item.height
                    sourceComponent: Column { width: parent.width
                    Label{ width: parent.width; text: description; color: Theme.secondaryHighlightColor }
                    Repeater {
                        model: JSON.parse(text)
                        delegate: Label{ width: parent.width; text: modelData
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.Wrap
                        }
                    }
                    Repeater {
                        model: JSON.parse(links)
                        delegate: LinkedLabel{ width: parent.width; plainText: modelData
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }}
                Loader { active: type == "script"
                    width: parent.width
                    //height: item.height
                    sourceComponent: Column { width: parent.width
                    Label{ width: parent.width; text: description; color: Theme.secondaryHighlightColor }
                    Label{ width: parent.width; color: Theme.secondaryColor
                        visible: username.length > 0
                        text: qsTr("Run as: %1").arg(username);
                        property string username: {
                                if (needsuser == "0")      return "root"
                                if (needsuser == "100000") return "user"
                                return username
                        }
                    }
                    Repeater {
                        model: JSON.parse(commands)
                        delegate: Label{ width: parent.width; text: "%1: %2".arg(index+1).arg(modelData)
                            font.family: "monospace"; font.pixelSize: Theme.fontSizeTiny
                            wrapMode: Text.Wrap
                        }
                    }
                    Label{ width: parent.width; text: qsTr("To clean up:"); visible: cleanup; color: Theme.secondaryColor  }
                    Repeater {
                        model: JSON.parse(cleanup)
                        delegate: Label{ width: parent.width; text: "%1: %2".arg(index+1).arg(modelData)
                            font.family: "monospace"; font.pixelSize: Theme.fontSizeTiny
                            wrapMode: Text.Wrap
                        }
                    }
                }}
            }
            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Copy to clipboard")
                    onClicked: toClip()
                }
            }
            function toClip() {
                var clip = ""
                if (type == "script") {
                    clip = [
                        "# " + description,
                        "# run as %1".arg(needsuser),
                        "#" + JSON.parse(commands).join("\n#"),
                        "# to clean up:",
                        "#" + JSON.parse(cleanup).join("\n#"),
                        ].join("\n")
                } else
                if (type == "tip") {
                    clip = [
                        JSON.parse(text).join("\n#"),
                        JSON.parse(links).join("\n#"),
                    ].join("\n#")
                } else
                if (type == "link") {
                    clip = link
                }
                Clipboard.text = clip
            }
            onClicked: {
                if (type == "link") { Qt.openUrlExternally(link) }
            }
        }
        }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
