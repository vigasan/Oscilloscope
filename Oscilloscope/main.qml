import QtQuick 2.12
import QtQuick.Window 2.12
import QtCharts 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

Window
{
    id: rootPage
    visible: true
    width: 800
    height: 480
    color: "black"
    property int range: 1000
    property int refreshPoints: 100

    readonly property int datasource_ADC: 0
    readonly property int datasource_SERIAL: 1

    function resetCurve()
    {
        axisX.min = 0;
        axisX.max = 1000;
        lineSeries.clear();
    }


    Rectangle
    {
        id:rectChart
        width: 703
        height: 403
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        color: "transparent"

        ChartView
        {
            id: chartView
            antialiasing: true
            backgroundColor: "transparent"
            legend.visible: false
            width: parent.width
            height: parent.height
            plotArea: Qt.rect(chartView.x, chartView.y, chartView.width, chartView.height)

            anchors
            {
                fill: parent
                margins: 0
            }

            property bool openGL: true
            property bool openGLSupported: true

            Image
            {
                source: "qrc:images/grid.png"
                anchors.fill: parent

                opacity: 0.5
                z: -1
            }


            onOpenGLChanged:
            {
                if (openGLSupported)
                {
                   console.log("OpenGL")
                   series("signal 1").useOpenGL = openGL;
                   //series("signal 2").useOpenGL = openGL;
                }
            }

            Component.onCompleted:
            {
                if (!series("signal 1").useOpenGL)
                {
                   openGLSupported = false
                   openGL = false
                }
            }

            ValueAxis
            {
                id: axisX
                min: 0
                max: 1000
                color: "darkgray"
                tickCount: 2
            }

            ValueAxis
            {
                id: axisY
                min: 0
                max: 30000//65535//4095
                labelsVisible: true
                color: "gray"
                tickCount: 2
            }

            LineSeries
            {
                id: lineSeries
                name: "signal 1"
                axisX: axisX
                axisY: axisY
                useOpenGL: chartView.openGL
                color: "yellow"
                style: Qt.DotLine
            }
        }
    }

    RangeSlider
    {
        id:control
        anchors.top: parent.top
        anchors.topMargin: 25
        anchors.right: parent.right
        anchors.rightMargin: 30
        orientation: Qt.Vertical
        implicitHeight: 365
        from: 0
        to: 65000
        stepSize: 100
        snapMode: RangeSlider.SnapAlways
        first.value: 0
        second.value: 30000

        background: Rectangle
        {
            id: rect1
            height: control.availableHeight
            width: 8
            color: "gray"
            radius:7
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle
            {
                id: rect2
                width: rect1.width
                y: rect1.y + control.second.visualPosition * rect1.height
                height: (control.first.visualPosition - control.second.visualPosition) * rect1.height
                color: "green"
                radius: 7
            }
        }

        first.onPressedChanged:
        {
            if(first.pressed == false)
            {
                axisY.min = control.first.value;
                yMinAxis.text = control.first.value;
            }
        }
        second.onPressedChanged:
        {
            if(second.pressed == false)
            {
                axisY.max = control.second.value;
                yMaxAxis.text = control.second.value;
            }
        }

    }

    Text
    {
       id: yMaxAxis
       text: "30000"
       anchors.horizontalCenter: control.horizontalCenter
       anchors.bottom: control.top
       color: "white"
       font.pointSize: 15
    }

    Text
    {
       id: yMinAxis
       text: "0"
       anchors.horizontalCenter: control.horizontalCenter
       anchors.top: control.bottom
       color: "white"
       font.pointSize: 15
    }

    Rectangle
    {
        id: rectTimeBase
        height: 63
        width: 650//703
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        color: "transparent"


        GridLayout
        {
            id: grid
            rows: 1
            columns: 5
            anchors.fill: parent

            Rectangle
            {
                id: rectBase0
                color: "transparent"
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.row: 0
                Layout.column: 0

                Rectangle
                {
                    id: circleExt0
                    width: 50
                    height: width
                    radius: width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    color: "transparent"
                    border.width: 2
                    border.color: "green"

                    Rectangle
                    {
                        id: inctrl0
                        width: 34
                        height: width
                        radius: width / 2
                        anchors.centerIn: parent
                        color: "transparent"
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            inctrl0.color = "green";
                            inctrl1.color = "transparent";
                            inctrl2.color = "transparent";
                            inctrl3.color = "transparent";
                            inctrl4.color = "transparent";
                            range = 250;
                        }
                    }
                }

                Text
                {
                   text: "250"
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.left: circleExt0.right
                   anchors.leftMargin: 10
                   color: "white"
                   font.pointSize: 15
                }
            }

            Rectangle
            {
                id: rectBase1
                color: "transparent"
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.row: 0
                Layout.column: 1

                Rectangle
                {
                    id: circleExt1
                    width: 50
                    height: width
                    radius: width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    color: "transparent"
                    border.width: 2
                    border.color: "green"

                    Rectangle
                    {
                        id: inctrl1
                        width: 34
                        height: width
                        radius: width / 2
                        anchors.centerIn: parent
                        color: "transparent"
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            inctrl0.color = "transparent";
                            inctrl1.color = "green";
                            inctrl2.color = "transparent";
                            inctrl3.color = "transparent";
                            inctrl4.color = "transparent";
                            range = 500;
                        }
                    }
                }

                Text
                {
                   text: "500"
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.left: circleExt1.right
                   anchors.leftMargin: 10
                   color: "white"
                   font.pointSize: 15
                }
            }

            Rectangle
            {
                id: rectBase2
                color: "transparent"
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.row: 0
                Layout.column: 2

                Rectangle
                {
                    id: circleExt2
                    width: 50
                    height: width
                    radius: width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    color: "transparent"
                    border.width: 2
                    border.color: "green"

                    Rectangle
                    {
                        id: inctrl2
                        width: 34
                        height: width
                        radius: width / 2
                        anchors.centerIn: parent
                        color: "green"
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            inctrl0.color = "transparent";
                            inctrl1.color = "transparent";
                            inctrl2.color = "green";
                            inctrl3.color = "transparent";
                            inctrl4.color = "transparent";
                            range = 1000;
                        }
                    }
                }

                Text
                {
                   text: "1000"
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.left: circleExt2.right
                   anchors.leftMargin: 10
                   color: "white"
                   font.pointSize: 15
                }
            }

            Rectangle
            {
                id: rectBase3
                color: "transparent"
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.row: 0
                Layout.column: 3

                Rectangle
                {
                    id: circleExt3
                    width: 50
                    height: width
                    radius: width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    color: "transparent"
                    border.width: 2
                    border.color: "green"

                    Rectangle
                    {
                        id: inctrl3
                        width: 34
                        height: width
                        radius: width / 2
                        anchors.centerIn: parent
                        color: "transparent"
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            inctrl0.color = "transparent";
                            inctrl1.color = "transparent";
                            inctrl2.color = "transparent";
                            inctrl3.color = "green";
                            inctrl4.color = "transparent";
                            range = 1500;
                        }
                    }
                }

                Text
                {
                   text: "1500"
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.left: circleExt3.right
                   anchors.leftMargin: 10
                   color: "white"
                   font.pointSize: 15
                }
            }

            Rectangle
            {
                id: rectBase4
                color: "transparent"
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.row: 0
                Layout.column: 4

                Rectangle
                {
                    id: circleExt4
                    width: 50
                    height: width
                    radius: width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    color: "transparent"
                    border.width: 2
                    border.color: "green"

                    Rectangle
                    {
                        id: inctrl4
                        width: 34
                        height: width
                        radius: width / 2
                        anchors.centerIn: parent
                        color: "transparent"
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            inctrl0.color = "transparent";
                            inctrl1.color = "transparent";
                            inctrl2.color = "transparent";
                            inctrl3.color = "transparent";
                            inctrl4.color = "green";
                            range = 2000;
                        }
                    }
                }

                Text
                {
                   text: "2000"
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.left: circleExt4.right
                   anchors.leftMargin: 10
                   color: "white"
                   font.pointSize: 15
                }
            }


        }
    }

    Rectangle
    {
        id: rectDataSource
        height: 63
        width: 130
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.right: parent.right
        anchors.leftMargin: 5
        color: "transparent"


        Rectangle
        {
            id: circleSerial
            width: 24
            height: width
            radius: width / 2
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 10
            color: "transparent"
            border.width: 2
            border.color: "red"

            Rectangle
            {
                id: inCircleSerial
                width: 18
                height: width
                radius: width / 2
                anchors.centerIn: parent
                color: "transparent"
            }

            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    inCircleSerial.color = "red"
                    inCircleI2C.color = "transparent"
                    resetCurve();
                    sampleWorker.setSource(datasource_SERIAL);
                    refreshPoints = 10;
                }
            }
        }

        Text
        {
           text: "SERIAL"
           anchors.verticalCenter: circleSerial.verticalCenter
           anchors.left: circleSerial.right
           anchors.leftMargin: 10
           color: "white"
           font.pointSize: 12
        }

        Rectangle
        {
            id: circleI2C
            width: 24
            height: width
            radius: width / 2
            anchors.top: circleSerial.bottom
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 10
            color: "transparent"
            border.width: 2
            border.color: "red"

            Rectangle
            {
                id: inCircleI2C
                width: 18
                height: width
                radius: width / 2
                anchors.centerIn: parent
                color: "red"
            }

            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    inCircleSerial.color = "transparent"
                    inCircleI2C.color = "red"
                    resetCurve();
                    sampleWorker.setSource(datasource_ADC);
                    refreshPoints = 100;
                }
            }
        }

        Text
        {
           text: "I2C"
           anchors.verticalCenter: circleI2C.verticalCenter
           anchors.left: circleI2C.right
           anchors.leftMargin: 10
           color: "white"
           font.pointSize: 12
        }

    }


    Connections
    {
        target: sampleWorker

        onUpdateCurve:
        {
            if(lineSeries.count > range)
            {
                axisX.max += refreshPoints;
                axisX.min = axisX.max - range;
            }
            dataSource.update(chartView.series(0));
        }
    }
}
