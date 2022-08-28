import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Encryption 1.0

ApplicationWindow {
    id: app

    initialPage: Component { Page{ id: page

        // from Sailfish.Encryption to determine Home Encryption
        HomeInfo{id: homeInfo}
        property alias encryptionType: homeInfo.type
        property string encryptionDetails: (homeInfo.type || "LUKS") + " " + homeInfo.version

        SilicaFlickable { id: flick
            anchors.fill: parent
            contentHeight: col.height
            Column { id: col
                width: parent.width
                PageHeader { id: header ; title: qsTr("Bug Info (%1)").arg("ok") }
                DetailItem { label: "EncryptionType" ;        value: encryptionType }
                DetailItem { label: "EncryptionDetail" ;      value: encryptionDetails }
            }
        }


    } }

}

// vim: ft=javascript expandtab ts=4 sw=4 st=4
