// Copyright (c) 2022,2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

pragma Singleton
import QtQuick 2.6
import Nemo.DBus 2.0

Item { id: root

    // public functions:
    /*! \qmlmethod getUnitState(unit, callback)

       Queries the \c status property of a Systemd Unit
       named \a unit, and executes \a callback.

       The \c callback function takes a single argument,
       the containing ithe result of the query, e.g.
       "active", "failed" etc.
    */

    function getUnitState(unit, callback) { manager.getUnitState(unit, callback) }
    /*! \qmlmethod toggleGather()
       Toggles the \c harbour-bugger-gather-logs.target on
       or off (enables/disables it via systemd).
    */

    function toggleGather() {  manager.toggleGather() }
    /*! \qmlmethod togglePlugins()
       Toggles the \c
       harbour-bugger-gather-logs-plugin@.service on or
       off (enables/disables it via systemd).
    */
    function togglePlugins() { manager.togglePlugins() }

    /*! \qmlmethod toggleJournal()

       Triggers the \c harbour-bugger-journalconf.service,
       which will either place or remove a logg config
       file int \c /etc/systemd/journald.conf.d, and
       restart the journal daemon.

    */
    function toggleJournal() { journald.toggle() }

    /*! \qmlproperty knownUnits
        List of "applicable" units, i.e. ones that are suitable to request a log file of.
        The names are stored as a comma-separated stringlist.
     */
    property string knownUnits

    /*! \qmlmethod listUnits()
        Populates or Updates the \c knownUnits property.
    */
    function refreshUnits() { manager.listUnits() }

    property var watchedJobs: new Object()      // record jobs we launched, used as key-value store

    function successMsg(message, result) {
        app.popup(result + ": " + message)
        console.debug(result + ": " + message)
    }
    function failMsg(message, result) {
        app.popup(result + ": " + message)
        console.warn(result + ": " + message)
    }
    DBusInterface { id: manager
        bus: DBus.SessionBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1"
        iface: "org.freedesktop.systemd1.Manager"

        // receive signals:
        signalsEnabled: true;
        Component.onCompleted: call('Subscribe')

        propertiesEnabled: true

        // just so we get signals for them:
        property int nNames
        onNNamesChanged: { listUnits(); }

        function toggleGather() {
            var u = "harbour-bugger-gather-logs.target"
            getUnitState(u, function(state){
                if (state === "enabled") disable(u)
                if (state === "disabled") enable(u)
            })
        }
        function togglePlugins() {
            var u = "harbour-bugger-gather-logs-plugin@.service"
            getUnitState(u, function(state){
                if (state === "enabled") disable(u)
                if (state === "disabled") enable(u)
            })
        }
        function listUnits() {
            call("ListUnits", [],
                function(result) {
                    var running = []
                    result.forEach(function(e) {
                        if (! /service$/.test(e[0])) return
                        if (e[2] == "loaded" && (e[3] == "active" || e[3] == "failed")) {
                            running.push(e[0])
                        }
                    })
                    knownUnits = running.join(',')
                },
                function(result) { console.warn(qsTr("Start"), JSON.stringify(result)) }
            );
        }

        function enable(u) {
            //console.debug("dbus enable unit", u );
            typedCall('EnableUnitFiles', [
                { "type": "as", "value": [u] },
                { "type": "b", "value": false },
                { "type": "b", "value": false },
            ],
                function(result) { successMsg(qsTr("Enable %1").arg(u), result[1]); app.refresh() },
                function(result) { failMsg(qsTr("Enable %1").arg(u), result[1]) }
            );
        }
        function disable(u) {
            //console.debug("dbus disable unit", u );
            typedCall('DisableUnitFiles', [
                { "type": "as", "value": [u] },
                { "type": "b", "value": false },
            ],
                function(result) { successMsg(qsTr("Disable %1").arg(u), result); app.refresh() },
                function(result) { failMsg(qsTr("Disable %1").arg(u), result) }
            );
        }
        function start(u) {
            //console.debug("dbus start unit", u );
            call('StartUnit',
                [u, "replace",],
                function(result) { console.debug("Job:", JSON.stringify(result)); watchJob(result, qsTr("Start")); },
                function(result) { failMsg(qsTr("Start %1").arg(u), result) }
            );
        }
        function stop(u) {
            //console.debug("dbus stop unit", u );
            call('StopUnit',
                [u, "replace",],
                function(result) { console.debug("Job:", JSON.stringify(result)); watchJob(result, qsTr("Stop")); },
                function(result) { failMsg(qsTr("Stop %1").arg(u), result) }
            );
        }
        function restart(u) {
            //console.debug("dbus restart unit", u );
            call('RestartUnit',
                [u, "replace",],
                function(result) { console.debug("Job:", JSON.stringify(result)); watchJob(result, qsTr("Restart")); },
                function(result) { failMsg(qsTr("Restart %1").arg(u), result) }
            );
        }
        function preset(u) {
            //console.debug("dbus restart unit", u );
            call('PresetUnitFiles',
                [u, false, false,],
                function(result) { successMsg(qsTr("Preset %1").arg(u), result) },
                function(result) { failMsg(qsTr("Preset %1").arg(u), result) }
            );
        }
        function daemon_reload() {
            //console.debug("daemon reload ");
            call('Reload',
                [],
                function(result) { successMsg(qsTr("Preset %1").arg(u), result) },
                function(result) { failMsg(qsTr("Preset %1").arg(u), result) }
            );
        }

        //signal handler for finished jobs:
        function jobRemoved(id, job, unit, result) {
            // TODO: maybe we want notifications about all jobs:
            if (!watchedJobs.hasOwnProperty(job) ) { return; }
            console.debug("Job removed: ", id, "/", result, unit)
            if (result == "done") {
                successMsg(watchedJobs[job], qsTr("%2 for unit %3", "successful message, e.g. 'start for unit foo'").arg(result).arg(unit))
            } else {
                failMsg(watchedJobs[job], qsTr("%1 %2 for unit %3","failure message, e.g. 'starting failed for unit foo'").arg(watchedJobs[job]).arg(result).arg(unit))
            }
            unwatchJob(job);
            app.refresh();
        }
        // handle the internal job queue, we only report jobs we triggered:
        // TODO: maybe we want notifications about all jobs:
        function watchJob(job, action) {
            console.debug("watching:",job);
            watchedJobs[job] = action;
        }
        function unwatchJob(job) {
            console.debug("unwatching:",job);
            if (watchedJobs.hasOwnProperty(job)) {
                delete watchedJobs[job];
            } else {
                console.warn("Trying to remove job not in list");
            }
        }

        // parameters: unit, callback cb
        function getUnitState(u, cb) {
            call('GetUnitFileState',
                [u],
                function(result) { cb(result) },
                function(result) { console.debug("failure: ", u, result) }
            );
        }
    }

    DBusInterface { id: journald
        bus: DBus.SystemBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1/unit/harbour_2dbugger_2djournalconf_2eservice"
        iface: "org.freedesktop.systemd1.Unit"

        propertiesEnabled: true
        property string activeState
        function toggle() {
            if (activeState == "inactive") {
                call('Start',
                    ["replace",],
                    function(result) { console.debug("Job:", JSON.stringify(result)); },
                    function(error, message) { console.warn("Error starting:", message) }
                );
            } else {
                console.warn("Trying to toggle while %1, ignoring".arg(activeState))
            }
        }
    }

}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
