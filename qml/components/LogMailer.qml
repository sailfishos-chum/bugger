/*

Apache License 2.0

Copyright (c) 2022 Peter G. (nephros)

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
import Nemo.DBus 2.0

QtObject {
    id: page

    function newMail(subject, to, body) {
        mailface.new(subject, to, body)
    }

    DbusInterface {
    /*
    <node name="com.jolla.email.ui">
        <interface name="com.jolla.email.ui">
        <method name="compose">
        <arg name="emailSubject" type="s" direction="in" />
        <arg name="emailTo" type="s" direction="in" />
        <arg name="emailCc" type="s" direction="in" />
        <arg name="emailBcc" type="s" direction="in" />
        <arg name="emailBody" type="s" direction="in" />
        </method>
        */

        service: "com.jolla.email.ui"
        iface:   "com.jolla.email.ui"
        path:   "com/jolla/email/ui"
        function new(subject, to, body) {
            call('compose',
                [subject, to, '', '', body,],
                function(result) { }, //console.debug("Job:",       JSON.stringify(result))
                function(result) { console.warn(qsTr("New Mai;"), JSON.stringify(result)) }
            );
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
