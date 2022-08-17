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
//import "../components"

Page {
  id: about

  readonly property string copyright: "Peter G. (nephros) and other Authors"
  readonly property string email: "mailto:sailfish@nephros.org?bcc=sailfish+app@nephros.org&subject=A%20message%20from%20a%20" + Qt.application.name + "%20user&body=Hello%20nephros%2C%0A"
  readonly property string license: "Apache-2.0"
  readonly property string licenseurl: "https://www.apache.org/licenses/LICENSE-2.0.html"
  readonly property string source: "https://github.com/sailfishos-chum/bugger"
  readonly property string helpurl: "https://forum.sailfishos.org/t/10935"

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
        SectionHeader { text: qsTr("What's %1?").arg(Qt.application.name) }
        LinkedLabel {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignJustify
            wrapMode: Text.WordWrap
            plainText: qsTr( '%1 is little tool to assist reporting bugs on https://forum.sailfishos.org, following a more or less standardized template.\nReporting bugs in this way should improve Jollas ability to pick them up and track them internally. For more information, see %2').arg(qsTr(Qt.application.name)).arg(helpurl)
        }

        DetailItem { label: qsTr("Version:");      value: Qt.application.version }
        DetailItem { label: qsTr("Copyright:");    value: copyright;                            BackgroundItem { anchors.fill: parent; onClicked: Qt.openUrlExternally(email) } }
        DetailItem { label: qsTr("License:");      value: license + " (" + licenseurl + ")";    BackgroundItem { anchors.fill: parent; onClicked: Qt.openUrlExternally(licenseurl) } }
        DetailItem { label: qsTr("Source Code:");  value: source;                               BackgroundItem { anchors.fill: parent; onClicked: Qt.openUrlExternally(source) } }
        SectionHeader { text: qsTr("Credits") }
        DetailItem { label: qsTr("Bug Coodination Team Lead: "); value: "pherjung" }
        DetailItem { label: qsTr("Contributions and Help: "); value: "thigg,\nflypig" }
        DetailItem { label: qsTr("Translation: %1",  "%1 is the native language name").arg(Qt.locale("de").nativeLanguageName); value: "nephros" }
        DetailItem { label: qsTr("Translation: %1",  "%1 is the native language name").arg(Qt.locale("sv").nativeLanguageName); value: "eson" }
    }
  }
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4
