import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import QtQuick.Controls.Material

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
    property string currentState: "focus";

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

    Rectangle {
        id: centerRect
        width: timerDisplay.width + 10
        height: timerDisplay.height + 10
        color: "black"
        opacity: 0.6
        radius: 10
        anchors.centerIn: parent

        Text {
            id: timerDisplay
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: 40
            text: formatTime(timeRemaining)
        }
    }

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: centerRect.top
        anchors.bottomMargin: 30
        spacing: 5

        StateButton {
            id: focusButton
            text: "Focus"
            enabled: true
            radius: 5
            anchors {
                topMargin: 40
            }
            onClicked: {
                Material.background = "black"
                shortBreakButton.enabled = longBreakButton.enabled = true;
                currentState = "focus";

                timeRemaining = 60 * 25;
                stopTimer();
            }
        }

        StateButton {
            id: shortBreakButton
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

        StateButton {
            id: longBreakButton
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

    CircleButton {
        radius: 30
        id: startButton
        width: 60
        height: 60
        text: timerRunning ? "\u23F8" : "\u25B6"
        font.pixelSize: timerRunning ? 24 : 16 // Pause symbol is a bit small
        anchors {
            top: centerRect.bottom
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            toggleTimer();
        }

    }

    CircleButton {
        id: restartButton
        radius: 25
        width: 50
        height: 50
        text: "\u21BA"
        font.pixelSize: 16
        enabled: false
        anchors {
            right: startButton.left
            rightMargin: 20
            verticalCenter: startButton.verticalCenter
        }
        onEnabledChanged: {
            var fadeAnimation = Qt.createQmlObject('import QtQuick 2.15; NumberAnimation { target: skipButton; property: "opacity"; duration: 500 }', skipButton);
            fadeAnimation.from = enabled ? 0.0 : 1.0; // Start from half opacity when enabling, full when disabling
            fadeAnimation.to = enabled ? 1.0 : 0.0; // End at full opacity when enabling, half when disabling
            fadeAnimation.start();
        }
    }

    CircleButton {
        id: skipButton
        radius: 25
        width: 50
        height: 50
        text: "\u23E9"
        enabled: false
        font.pixelSize: 16
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
