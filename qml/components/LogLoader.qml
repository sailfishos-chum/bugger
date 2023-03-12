/*

Apache License 2.0

Copyright (c) 2022,2023 Peter G. (nephros)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.  
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

import QtQuick 2.6

Item {
    id: page

    WorkerScript { id: worker
        source: "../js/logworker.js"
    }
    property ListModel model: ListModel{}

    onModelChanged: reload()

    function reload() {
        if (!model) return
        for (var i = 0; i < model.count; ++i) {
            getFileFrom(i, model.get(i))
        }
    }

    function getFileFrom(index, data) {
        worker.sendMessage({action: "getFile", parms: { model: model, index: index }})
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
