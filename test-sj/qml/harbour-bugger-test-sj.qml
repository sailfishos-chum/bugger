import QtQuick 2.6
import Sailfish.Silica 1.0
import org.nemomobile.devicelock 1.0

ApplicationWindow {
    id: app

    initialPage: Component { Page{ id: page

        EncryptionSettings{id: encs}


        SilicaFlickable { id: flick
            anchors.fill: parent
            contentHeight: col.height
            Column { id: col
                width: parent.width
                PageHeader { id: header ; title: qsTr("Bug Info (%1)").arg("ok") }
                DetailItem { label: "EncryptionSetting" ;      value: encs.homeEncrypted }
            }
        }


    } }

}

// vim: ft=javascript expandtab ts=4 sw=4 st=4
