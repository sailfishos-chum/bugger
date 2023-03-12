// Copyright (c) 2022,2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6

Item {

    property ListModel model: ListModel{}

    WorkerScript { id: worker
        source: "../js/logworker.js"
    }

    function reload() {
        if (!model) return
        worker.sendMessage({action: "reload",  model: model})
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
