//this file is part the thesa: tryton client based PySide2(qml2)
// tools Scan with QZXing, need to plugin QZXing
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
//__license__ = "GPL"
//__version__ = "1.0.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.12

import QZXing 2.3

Dialog {
    id: dialog
    anchors.centerIn: parent
    title: qsTr("Scan")

    width: maxWidthDialog
    height:boolShortWidth135?container.height:maxWidthDialog
    modal: true
    focus: true
    visible: false
    standardButtons: Dialog.Cancel
    closePolicy: Dialog.NoAutoClose
    onRejected: {closing()}
    padding: 10
    // onAccepted: console.log("Ok clicked")
    property var listCameras:[]
    property var listCamerasNames:[]
    property int enableDeco: QZXing.DecoderFormat_EAN_13 | QZXing.DecoderFormat_CODE_39 | QZXing.DecoderFormat_QR_CODE
    signal signalTagFound(string tag)
    signal signalClose()
    function closing(){
        tstop.start();
        tcloseAll.start()
    }
    function setEnableDecoders(deco){
        enableDeco=deco;
    }
    Component.onCompleted: {
        listCamerasNames=[];
        listCameras=QtMultimedia.availableCameras;
        for(var i=0, len=listCameras.length;i<len;i++){
            listCamerasNames.push(listCameras[i].displayName);
        }
        if(listCameras.length > 1){
            ilistcameras.enabled=true;
        }
        ilistcameras.model=listCamerasNames;
    }

    onVisibleChanged: {
        if(visible){
            camera.start();
        }
    }

    Timer{
        id:tcloseAll
        interval: 500
        onTriggered: {destroy(0);}
    }

    Timer{
        id:tstop
        interval: 200
        onTriggered: {camera.stop();close();signalClose()}
    }
    contentItem: Pane{
        id:mp
        background: Rectangle {
            width: mp.width
            height: mp.height
            color: "transparent"
            border.color: mp.Material.background
            border.width: 1
            radius: miradius
        }
        padding: 10
        Item {
            anchors.fill: parent
            Camera {
                id: camera
                imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceAuto
                focus {
                    focusMode: CameraFocus.FocusContinuous
                    focusPointMode: CameraFocus.FocusPointAuto
                }
            }
            VideoOutput {
                id:videoOutput
                //anchors.fill: parent
                width: parent.width<parent.height?parent.width:parent.height
                height: width
               // anchors{right:parent.right;bottom:parent.bottom}
                anchors{horizontalCenter: parent.horizontalCenter;bottom:parent.bottom}
                //anchors.centerIn: parent
                autoOrientation: true
                source: camera
                //orientation: camera.orientation
                fillMode: VideoOutput.PreserveAspectCrop
                Component.onCompleted: {
                    videoOutput.hoff();
                }

                onHeightChanged: {
                    videoOutput.hoff();
                }

                function hoff(){
                    if(height<(dpisReal*40)){
                        if(parent.width>width){
                            anchors.horizontalCenterOffset=(parent.width - width)/2;
                        }else{
                            anchors.horizontalCenterOffset=0;
                        }
                    }else{
                        anchors.horizontalCenterOffset=0;
                    }

                }

                filters: [ zxingFilter ]
                Rectangle {
                    id: captureZone
                    color: mainroot.Material.accent//"green"
                    opacity: 0.3
                    width: (parent.width / 5)*3
                    height: (parent.height / 5)*3
                    anchors.centerIn: parent
                    radius: 4
                }
                Repeater {
                    model: camera.focus.focusZones

                    Rectangle {
                        border {
                            width: 2
                            color: status == Camera.FocusAreaFocused ? "green" : "white"
                        }
                        color: "transparent"
                        opacity: 0.5

                        // Map from the relative, normalized frame coordinates
                        property variant mappedRect: videoOutput.mapNormalizedRectToItem(area);

                        x: mappedRect.x
                        y: mappedRect.y
                        width: mappedRect.width
                        height: mappedRect.height
                    }
                }
                Text {
                    text: "QZXing v2.3"
                    color: mainroot.Material.accent
                    anchors{right: parent.right;rightMargin: 4;bottom: parent.bottom;bottomMargin: 2}
                }

            }
            QZXingFilter {
                id: zxingFilter
                decoder {
                    enabledDecoders: enableDeco
                    tryHarder:true
                    onTagFound: {
                        signalTagFound(tag);
                        closing();
                    }
                }
                captureRect: {
                    // setup bindings
                    videoOutput.contentRect;
                    videoOutput.sourceRect;
                    return videoOutput.mapRectToSource(videoOutput.mapNormalizedRectToItem(Qt.rect(
                                                                                               0.2, 0.2, 0.6, 0.6
                                                                                               )));
                }

            }
            InputComboBoxCube{
                id:ilistcameras
                enabled:false
               // width: parent.width/2
                anchors{top: parent.top;left: parent.left}
                label: qsTr("Available Cameras:")
                //model: listCamerasNames
                boolOnDesk: true
                onIndexChanged: {
                    if(listCameras.length > 1){
                        camera.deviceId = listCameras[index].deviceId;
                    }
                }
            }

        }

    }

}
