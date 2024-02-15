import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import QtQuick.Controls.Universal

Window {
    width: 320
    height: 240
    visible: true
    title: qsTr("QPomoClock")

    Rectangle {
        anchors.fill: parent
        color: !focusButton.enabled ? "darkred" : (!shortBreakButton.enabled ? "teal" : "purple")
    }

    property int timeRemaining: 1500 // 25 mins in seconds
    property bool timerRunning: false

    Timer {
        id: timer
        interval: 1000
        running: timerRunning
        repeat: true
        onTriggered: {
            if(timeRemaining > 0) {
                timeRemaining -= 1;
            }
            else {
                stopTimer();
            }
        }
    }

    Text {
        id: timerDisplay
        anchors.centerIn: parent
        font.pixelSize: 40
        text: formatTime(timeRemaining)
    }

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: timerDisplay.top
        anchors.bottomMargin: 40
        spacing: 10

        Rectangle {
            id: buttonStyle
            color: "lightblue" // Background color of the button
            radius: 10 // Adjust this value to control the roundness

            MouseArea {
                anchors.fill: parent
                onClicked: console.log("Button clicked")
            }
        }


        RoundButton {
            id: focusButton
            width: 100
            height: 25
            text: "Focus"
            enabled: false
            radius: 5
            anchors {
                topMargin: 20
            }
            onClicked: {
                shortBreakButton.enabled = longBreakButton.enabled = true;
                enabled = false;

                timeRemaining = 60 * 25;
                stopTimer();
            }
        }

        RoundButton {
            id: shortBreakButton
            width: 100
            height: 25
            text: "Short break"
            radius: 5
            anchors {
                topMargin: 20
            }
            onClicked: {
                focusButton.enabled = longBreakButton.enabled = true;
                enabled = false;

                timeRemaining = 60 * 5;
                stopTimer();
            }
        }

        RoundButton {
            id: longBreakButton
            width: 200
            height: 25
            text: "Long break"
            radius: 5
            anchors {
                topMargin: 20
            }
            onClicked: {
                focusButton.enabled = shortBreakButton.enabled = true;
                enabled = false;
                timeRemaining = 60 * 15;
                stopTimer();
            }
        }
    }

    RoundButton {
        radius: 25
        id: startButton
        width: 50
        height: 50
        text: timerRunning ? "\u23F8" : "\u25B6"
        font.pixelSize: 16
        anchors {
            top: timerDisplay.bottom
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            toggleTimer();
        }
    }

    RoundButton {
        id: restartButton
        radius: 20
        width: 40
        height: 40
        text: "\u21BA"
        font.pixelSize: 14
        enabled: false
        anchors {
            right: startButton.left
            rightMargin: 20
            verticalCenter: startButton.verticalCenter
        }
        onEnabledChanged: {
            var fadeAnimation = Qt.createQmlObject('import QtQuick 2.15; NumberAnimation { target: skipButton; property: "opacity"; duration: 500 }', skipButton);
            fadeAnimation.from = enabled ? 0.1 : 1.0; // Start from half opacity when enabling, full when disabling
            fadeAnimation.to = enabled ? 1.0 : 0.1; // End at full opacity when enabling, half when disabling
            fadeAnimation.start();
        }
    }

    RoundButton {
        id: skipButton
        radius: 20
        width: 40
        height: 40
        text: "\u23E9"
        enabled: false
        font.pixelSize: 14
        anchors {
            left: startButton.right
            leftMargin: 20
            verticalCenter: startButton.verticalCenter
        }
        onEnabledChanged: {
            var fadeAnimation = Qt.createQmlObject('import QtQuick 2.15; NumberAnimation { target: skipButton; property: "opacity"; duration: 500 }', skipButton);
            fadeAnimation.from = enabled ? 0.1 : 1.0; // Start from half opacity when enabling, full when disabling
            fadeAnimation.to = enabled ? 1.0 : 0.1; // End at full opacity when enabling, half when disabling
            fadeAnimation.start();
        }
    }

    function startTimer() {
        timerRunning = true;
        skipButton.enabled = true;
    }

    function stopTimer() {
        timerRunning = false;
        skipButton.enabled = false;
    }

    function toggleTimer() {
        if(timerRunning) {
            stopTimer();
        }
        else {
            startTimer();
        }
    }

    function formatTime(seconds) {
        var minutes = Math.floor(seconds / 60)
        var seconds = seconds % 60
        return ("0" + minutes).slice(-2) + ":" + ("0" + seconds).slice(-2);
    }
}
