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
     "tip":   qsTr("Author's Tip"),
     "link":   qsTr("Documentation Links"),
     "script": qsTr("Try these commands")
    }

    onCategoryChanged: {
        if (!category.length) return
        Meta.data.categories.forEach(function(e) {
            if (e.name == category) {
                e.help.forEach(function(h) {
                    console.debug(JSON.stringify(h))
                    if (h.type == "script") {
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
        section.delegate: SectionHeader { text: root.titles[section] }
        delegate: ListItem {
            contentHeight: content.height
            Column { id: content
                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                Label{ width: parent.width; text: description; color: Theme.secondaryHighlightColor }
                Label{ width: parent.width; text: link; visible: type == "link"; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor  }
                Column{ width: parent.width; visible: type == "script"
                    Label{ width: parent.width; text: qsTr("Run as: %1").arg(needsuser); color: Theme.secondaryColor  }
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
                }
            }
            onClicked: {
                if (type == "link") { Qt.openUrlExternally(link) }
            }
            menu: ContextMenu {
                enabled: (type == "script")
                MenuItem {
                    text: qsTr("Copy to clipboard")
                    onClicked: cmdToClip()
                }
            }
            function cmdToClip() {
                var script = [
                    "# " + description,
                    "# run as %1".arg(needsuser),
                    "#" + JSON.parse(commands).join("\n#"),
                    "# to clean up:",
                    "#" + JSON.parse(cleanup).join("\n#"),
                    ].join("\n")
                 Clipboard.text = script
            }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
