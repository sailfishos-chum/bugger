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
import Nemo.Configuration 1.0
import "pages"
import "cover"
import "components"
import "config/settings.js" as Settings

ApplicationWindow {
    id: app

    property bool developerMode: false

    /* post submit settings */
    property var config
    //readonly property string postScheme:   "sailfishos-bugreport-1" // for a custom Url handler
    readonly property string postScheme:    config.submit.scheme
    readonly property string postHost:      config.submit.host
    readonly property string postUri:       config.submit.uri
    readonly property url    postUrl:       postScheme + '://' + postHost + postUri

    /* forum things:
     * see docs.discourse.org
     */
    //readonly property string bugTemplateHost:     Settings.config.bugtemplate.host
    //readonly property string bugTemplateUri:      Settings.config.bugtemplate.uri
    //readonly property string bugTemplateCategory: Settings.config.bugtemplate.category
    //readonly property url    bugTemplateUrl: "https://" + bugTemplateHost + bugTemplateUri

    /* info sources: */
    readonly property url osInfoFile:  config.sources.os
    readonly property url hwInfoFile:  config.sources.hw
    readonly property url pmInfoFile:  config.sources.pm
    readonly property url ssuInfoFile: config.sources.ssu

    BugInfo { id: bugInfo }

    /* read fileUrl from filesystem, assign to bugInfo according to what */
    function getInfo(fileUrl, what) {

        var r = new XMLHttpRequest()
        r.open('GET', fileUrl);
        r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        r.send();

        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                const bi = {};
                const  mods = {
                    "openrepos":    false,
                    "patchmanager": false,
                    "chum":         false
                }
                r.response.split("\n").forEach(
                    function(v) {
                        if (v.length == 0 ) return;
                        if (v.charAt(0) == "#") return;
                        if (v.charAt(0) == "[") return;
                        if (/^password/.test(v) ) return; // lets not save this
                        if (/^username/.test(v) ) return; // lets not save this
                        const a = v.split("=");
                        if (a[0]){
                            if (what == "pm") {
                                if (a[0] == "applied" && a[1].length > 0) {
                                    mods.patchmanager = true
                                    console.info("Patchmanager detected!")
                                } else { return } // only interested in one line
                            }
                            if (what == "ssu") {
                              if (/^openrepos/.test(a[0]) && mods.openrepos === false) {
                                  mods.openrepos = true;
                                  console.info("OpenRepos detected!")
                              }
                              if (/^sailfishos-chum/.test(a[0])) {
                                  mods.chum = true;
                                  console.info("Chum detected!")
                              }
                            }

                          bi[a[0].toLowerCase()] = a[1].toString().replace(/\"/g,"");
                        }
                    }
                );
                //console.info("gathered info:" , JSON.stringify(bi,null,2));
                if (what == "os") bugInfo.setOs(bi);
                if (what == "hw") bugInfo.setHw(bi);
                if (what == "ssu") bugInfo.setSsu(bi);
                if (mods.openrepos === true)    bugInfo.setMod("openrepos");
                if (mods.patchmanager === true) bugInfo.setMod("patchmanager");
                if (mods.chum === true)         bugInfo.setMod("chum");
            }
        }
    }


    Component.onCompleted: {
        // for sailjail
        Qt.application.domain  = "sailfish.nephros.org";
        Qt.application.version = "unreleased";
        console.info("Intialized", Qt.application.name, "version", Qt.application.version, "by", Qt.application.organization );
        console.debug("Parameters: " + Qt.application.arguments.join(" "))
        // correct landscape for Gemini, set once on start
        allowedOrientations = (devicemodel === 'planetgemini')
            ? Orientation.LandscapeInverted
            : defaultAllowedOrientations

        // bind the loaded file
        config = Settings.config

        if (Qt.application.arguments.indexOf("-developermode") > -1) {
            developerMode = true
            console.info("testing/developer mode enabled!")
            console.debug("Loaded settings:", JSON.stringify(Settings,null, 2))
        }
        /* LOAD ALL THE THINGS */
        getInfo(osInfoFile, "os");
        getInfo(hwInfoFile, "hw");
        getInfo(pmInfoFile, "pm");
        getInfo(ssuInfoFile, "ssu");
    }

    // correct landscape for Gemini
    ConfigurationValue {
        id: devicemodel
        key: "/desktop/lipstick-jolla-home/model"
    }
    /*
    // application settings:
    ConfigurationGroup  {
        id: settings
        path: "/org/nephros/" + Qt.application.name
    }
    ConfigurationGroup  {
        id: config
        scope: settings
        path:  "app"
        //property bool gravity: true // true: pull to bottom
        //property int ordering: 1 // 1: top to bottom
    }
    */

    initialPage: Component { MainPage{} }
    cover: CoverPage{}

}

// vim: ft=javascript expandtab ts=4 sw=4 st=4
