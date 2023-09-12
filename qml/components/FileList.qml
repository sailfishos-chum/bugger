// Copyright (c) 2022,2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0

SilicaGridView { id: root
    property bool showPlaceholder: true
    property bool filtered: false
    width: parent.width
    height: Theme.iconSizeLarge * Math.max(count, 2)
    cellWidth: parent.width/2
    cellHeight: Theme.iconSizeLarge
    delegate: LogfileDelegate { hidden: ( root.filtered && (pastedUrl.length ==0)) }
    ViewPlaceholder {
        enabled: (root.count == 0) && showPlaceholder
        text: qsTr("No files.")
        hintText: qsTr("Use <b>%1</b> to add log files.").arg(qsTr("Collect Logs"))
    }
}
// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
