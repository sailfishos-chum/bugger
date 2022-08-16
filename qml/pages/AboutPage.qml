/*

Apache License 2.0

Copyright (c) 2022 Peter G. (nephros)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.  
You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"

Page {
  id: about

  readonly property string copyright: "Peter G. (nephros)"
  readonly property string email: "mailto:sailfish@nephros.org?bcc=sailfish+app@nephros.org&subject=A%20message%20from%20a%20" + Qt.application.name + "%20user&body=Hello%20nephros%2C%0A"
  readonly property string license: "Apache-2.0"
  readonly property string licenseurl: "https://www.apache.org/licenses/LICENSE-2.0.html"
  readonly property string source: "https://codeberg.org/nephros/template"

  SilicaFlickable {
    contentHeight: col.height + Theme.itemSizeLarge
    anchors.fill: parent
    VerticalScrollDecorator {}
    Column {
        id: col
        width: parent.width - Theme.horizontalPageMargin
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingLarge
        PageHeader { title: qsTr("About") + " " + Qt.application.name + " " + Qt.application.version }
        /*
        SectionHeader { text: qsTr("What's %1?").arg(Qt.application.name) }
        HelpLabel {
          text: qsTr(
' '
)
        }
        */
        DetailItem { label: qsTr("Version:");      value: Qt.application.version }
        DetailItem { label: qsTr("Copyright:");    value: copyright;                            BackgroundItem { anchors.fill: parent; onClicked: Qt.openUrlExternally(email) } }
        DetailItem { label: qsTr("License:");      value: license + " (" + licenseurl + ")";    BackgroundItem { anchors.fill: parent; onClicked: Qt.openUrlExternally(licenseurl) } }
        DetailItem { label: qsTr("Source Code:");  value: source;                               BackgroundItem { anchors.fill: parent; onClicked: Qt.openUrlExternally(source) } }
    }
  }
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4
