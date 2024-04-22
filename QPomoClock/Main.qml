import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import QtQuick.Controls.Material
import QtMultimedia

Window {
    width: 320
    height: 240
    visible: true
    title: qsTr("QPomoClock")
    property string highlighted_color: "grey"

    SoundEffect {
        id: notificationSound
        source: "bell2.wav"
        loops: 6
    }

    Rectangle {
        anchors.fill: parent
        color: currentState == "focus" ? "dark red" : (currentState == "short break" ? "teal" : "midnight blue")

        Behavior on color {
            ColorAnimation {
                duration: 250 // Adjust the duration as needed
            }
        }
    }

    property int focus_time: 1500  // 25 mins in seconds
    property int short_break_time: 300
    property int long_break_time: 900

    property int timeRemaining: focus_time
    property int sessionCount: 0;
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
                notificationSound.play();
                nextPhase();
            }
        }
    }

    Rectangle {
        id: centerRect
        width: timerDisplay.width + 10
        height: timerDisplay.height + 10
        color: "black"
        opacity: 0.6666
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
                currentState = "focus";

                timeRemaining = 60 * 25;
                stopTimer();
            }

            Material.background: (currentState == "focus") ? highlighted_color : "black"
            opacity: 1.0
        }

        StateButton {
            id: shortBreakButton
            text: "Short break"
            radius: 5
            anchors {
                topMargin: 20
            }
            onClicked: {
                timeRemaining = 60 * 5;
                stopTimer();
                currentState = "short break"
            }

            Material.background: (currentState == "short break") ? highlighted_color : "black"
        }

        StateButton {
            id: longBreakButton
            text: "Long break"
            radius: 5
            anchors {
                topMargin: 20
            }
            onClicked: {
                timeRemaining = 60 * 15;
                stopTimer();
                currentState = "long break"
            }
            Material.background: (currentState == "long break") ? highlighted_color : "black"
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
        enabled: timerRunning
        anchors {
            right: startButton.left
            rightMargin: 20
            verticalCenter: startButton.verticalCenter
        }
        onClicked: {
            stopTimer();
            restartRemainingTime();
        }
    }

    CircleButton {
        id: skipButton
        radius: 25
        width: 50
        height: 50
        text: "\u23E9"
        enabled: true
        font.pixelSize: 16
        anchors {
            left: startButton.right
            leftMargin: 20
            verticalCenter: startButton.verticalCenter
        }
        onClicked: {
            nextPhase();
        }
    }



    function nextPhase() {
        stopTimer();
        if(currentState == "focus") {
            currentState = "short break";
            timeRemaining = short_break_time;
            sessionCount++;
        }
        else if(currentState == "short break") {
            currentState = "long break";
            timeRemaining = long_break_time;
        }
        else if(currentState == "long break") {
            currentState = "focus";
            timeRemaining = focus_time;
        }
    }

    function startTimer() {
        timerRunning = true;
    }

    function stopTimer() {
        timerRunning = false;
    }

    function toggleTimer() {
        if(timerRunning) {
            stopTimer();
        }
        else {
            startTimer();
        }
    }

    function restartRemainingTime() {
        if(currentState == "focus")
            timeRemaining = focus_time;
        else if(currentState == "short break")
            timeRemaining = short_break_time;
        else if(currentState == "long break")
            timeRemaining = long_break_time;
    }

    function formatTime(seconds) {
        var minutes = Math.floor(seconds / 60)
        var seconds = seconds % 60
        return ("0" + minutes).slice(-2) + ":" + ("0" + seconds).slice(-2);
    }
}
