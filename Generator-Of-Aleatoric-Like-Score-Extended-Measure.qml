//==========================================================================================
//  Generator-Of_Aleatoric-Like-Score-Extended-Measure
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//===========================================================================================


import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import MuseScore 3.0

MuseScore {
    menuPath: "Plugins.Generator-of-aleatoric-like-score-extended-measure"
    description: "This plugin generate random score based on the choices provided by user"
    version: "1.0"
    pluginType: "dialog"
    width: 1600
    height: 350

    function getRandomInt(max) {
        return Math.floor(Math.random() * max);
    }

    function getRandomIdx(arr) {
        if (arr.length === 0) {
            return undefined; 
        }
        return arr[Math.floor(Math.random() * arr.length)];
    }

    function shuffleArray(array) {
        for (var i = array.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
        return array;
    }

    function getRandomPermutation(array, length) {
        var result = [];

        while (result.length < length) {
            var shuffled = shuffleArray(array).slice(0);
            result = result.concat(shuffled);
        }

        return result.slice(0, length);
    }

    function getRandomNumberRange(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    function getNumbersInRange(rangeString) {
        var range = rangeString.split('-');
        var start = parseInt(range[0], 10);
        var end = parseInt(range[1], 10);
        var numbersInRange = [];

        for (var i = start; i <= end; i++) {
            numbersInRange.push(i);
        }
        return numbersInRange;
    }

    function getRandNum(range) {
        return Math.floor(Math.random() * range);
    }

    function getNextElementDuration(cursor) {
        cursor.next();
        return cursor.element.duration.numerator;
    }

    function getRandDenominator() {
        var denominators = [1, 2, 4, 8, 16, 32];
        var randomIndex = Math.floor(Math.random() * denominators.length);
        return denominators[randomIndex];
    }

    function getPitches(arr, duration, pitchesToAdd) {
        while (pitchesToAdd.length < duration) {
            var result = getRandomIdx(arr);
            var found = false;
            for (var i = 0; i < pitchesToAdd.length; i++) {
                if (pitchesToAdd[i] === result) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                pitchesToAdd.push(result);
            }
        }
        return pitchesToAdd;
    }

    function runIt() {
        var cursor = curScore.newCursor();
        var elementObj = [];
        var objData = [];
        cursor.rewind(2);
        var endTick = cursor.tick;
        cursor.rewind(1);

        while (cursor.tick < endTick) {
            if (cursor.element.type === 93) {
                if (cursor.element.duration.denominator && cursor.element.notes[0].tieForward) {
                    if (cursor.element.notes.length === 1) {
                        console.log("SingleNoteTie");
                        objData.push({
                            elementNumerator: cursor.element.duration.numerator + getNextElementDuration(cursor),
                            elementDenominator: cursor.element.duration.denominator,
                            pitch: cursor.element.notes[0].pitch,
                            idx: getRandNum(1000)
                        });
                    } else if (cursor.element.notes.length > 1) {
                        console.log("ChordTie");
                        objData.push({
                            elementNumerator: cursor.element.duration.numerator + getNextElementDuration(cursor),
                            elementDenominator: cursor.element.duration.denominator,
                            pitch: cursor.element.notes,
                            idx: getRandNum(1000)
                        });
                    }
                } else if (!cursor.element.notes[0].tieForward && cursor.element.type === 93) {
                    if (cursor.element.notes.length === 1) {
                        console.log("SingleNOteNoTie");
                        objData.push({
                            elementNumerator: cursor.element.duration.numerator,
                            elementDenominator: cursor.element.duration.denominator,
                            pitch: cursor.element.notes[0].pitch,
                            idx: getRandNum(1000)
                        });
                    } else if (cursor.element.notes.length > 1) {
                        console.log("ChordTie");
                        objData.push({
                            elementNumerator: cursor.element.duration.numerator,
                            elementDenominator: cursor.element.duration.denominator,
                            pitch: cursor.element.notes,
                            idx: getRandNum(1000)
                        });
                    }
                }
            }

            if (cursor.element.type === 25) {
                console.log("beforeRest", cursor.tick);
                objData.push({
                    elementNumerator: cursor.element.duration.numerator,
                    elementDenominator: cursor.element.duration.denominator,
                    pitch: "no-pitch",
                    idx: getRandNum(1000)
                });
            }
            cursor.next();
        }

        cursor.nextMeasure();

        function displayingNotes(newObjData, randomRhythm, range) {
            

            for (var i = 0; i < newObjData.length; i++) {
                var pitchesToAdd = [];
                if (newObjData[i].pitch.length === 8) { //pause
                    cursor.setDuration(newObjData[i].elementNumerator, randomRhythm ? getRandDenominator() : newObjData[i].elementDenominator);
                    curScore.startCmd();
                    cursor.addRest();
                    curScore.endCmd();
                } else if (newObjData[i].pitch.length === undefined) { //one note
                    cursor.setDuration(newObjData[i].elementNumerator, randomRhythm ? getRandDenominator() : newObjData[i].elementDenominator);
                    curScore.startCmd();
                    cursor.addNote(range ? range[getRandNum(range.length)] : newObjData[i].pitch);
                    curScore.endCmd();
                } else if (newObjData[i].pitch.length > 1 && newObjData[i].pitch.length < 8) { // chord
                    var tick = cursor.tick;
                    cursor.setDuration(newObjData[i].elementNumerator, randomRhythm ? getRandDenominator() : newObjData[i].elementDenominator);
                    if (range) {
                        var finalPitches = getPitches(range, newObjData[i].pitch.length, pitchesToAdd);
                        console.log("finalPitches", finalPitches)
                    }
                    for (var j = 0; j < newObjData[i].pitch.length; j++) {
                        cursor.rewindToTick(tick);
                        if (j === 0) {
                            curScore.startCmd();
                            cursor.addNote(range ? finalPitches[j] : newObjData[i].pitch[j].pitch);
                            curScore.endCmd();
                        } else {
                            curScore.startCmd();
                            cursor.addNote(range ? finalPitches[j] : newObjData[i].pitch[j].pitch, true);
                            curScore.endCmd();
                        }
                    }
                }
            }
        }

        if (repetition.checked) {
            var numOfRepetition =  parseInt(repetitionNumberPermut.text);

             var newObjData  = getRandomPermutation(objData, numOfRepetition)

            var randomRhythm = false;
            displayingNotes(newObjData, randomRhythm);

        } else if (changedRhythmBtn.checked) {
            var repetitions = parseInt(changedRhythm.text);
            var newObjData = [];

            for (var i = 0; i < repetitions; i++) {
                newObjData.push(objData[i % objData.length]);
            }

            displayingNotes(newObjData, true);

        } else if (withRepetition.checked) {
            var repetitions = parseInt(repetitionNumber.text);
            var newObjData = [];

            for (var i = 0; i < repetitions; i++) {
                var randomIndex = Math.floor(Math.random() * objData.length);
                newObjData.push(objData[randomIndex]);
            }

            displayingNotes(newObjData, false);
        } else if (keepRhythm.checked) {
            var repetitions = parseInt(rhythmSameRepetition.text);
            var newObjData = [];
            var range = getNumbersInRange(pitchRange.text);

            for (var i = 0; i < repetitions; i++) {
                newObjData.push(objData[i % objData.length]);
            }

            displayingNotes(newObjData, false, range);
        }
    }
    Rectangle {
        anchors.fill: parent
        color: "#454545"

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        padding: 25
        spacing: 20
        id: row

        RadioButton {
            id: changedRhythmBtn
            checked: true
            text: qsTr("Generate random rhythm keep pitch")
            padding: 15

            TextField {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: changedRhythmBtn.bottom
                id: changedRhythm
                placeholderText: "Number of notes"
            }
            contentItem: Text {
                text: changedRhythmBtn.text
                verticalAlignment: Text.AlignVCenter
                leftPadding: changedRhythmBtn.indicator.width + changedRhythmBtn.spacing
                color: "white"
                opacity: changedRhythmBtn.hovered ? 0.8:1
            }
        }

        RadioButton {
            id: repetition
            text: qsTr("Reorder elements randomly (permutation)")
            padding: 15

            TextField {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: repetition.bottom
                id: repetitionNumberPermut
                placeholderText: "Number of notes"
            }
            contentItem: Text {
                text: repetition.text
                verticalAlignment: Text.AlignVCenter
                leftPadding: repetition.indicator.width + repetition.spacing
                color: "white"
                opacity: repetition.hovered ? 0.8:1
            }
        }

        RadioButton {
            id: withRepetition
            text: qsTr("Reorder elements randomly (uniform probability)")
            padding: 15

            TextField {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: withRepetition.bottom
                id: repetitionNumber
                placeholderText: "Number of notes"
            }
            contentItem: Text {
                text: withRepetition.text
                verticalAlignment: Text.AlignVCenter
                leftPadding: withRepetition.indicator.width + withRepetition.spacing
                color: "white"
                opacity: withRepetition.hovered ? 0.8:1
            }
        }

        RadioButton {
            id: keepRhythm
            text: qsTr("Generate random pitch keep rhythm")
            padding: 15

            TextField {
                anchors.top: keepRhythm.bottom
                id: pitchRange
                placeholderText: "Range of pitch e.g 60-70"
            }

            TextField {
                anchors.left: pitchRange.right
                anchors.top: parent.bottom
                id: rhythmSameRepetition
                placeholderText: "Number of notes"
            }
            contentItem: Text {
                text: keepRhythm.text
                verticalAlignment: Text.AlignVCenter
                leftPadding: keepRhythm.indicator.width + keepRhythm.spacing
                color: "white"
                opacity: keepRhythm.hovered ? 0.8:1
            }
        }
    }

    Button {
         anchors.horizontalCenter: parent.horizontalCenter
        anchors.centerIn: parent
        onClicked: runIt()
        text: "Submit"
        highlighted: true
    }
    }

    onRun: {
        var cursor = curScore.newCursor();
        cursor.rewind(0);
        cursor.measure.timesigActual = fraction(100, 1);
        cursor.nextMeasure();
        cursor.measure.timesigActual = fraction(100, 1);
    }
}
