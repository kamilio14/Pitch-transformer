//==========================================================================================
//  Pitch-Transformer
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
    menuPath: "Plugins.Pitch-Transformer"
    description: "This plugin transforms pitch in three ways selected by user"
    version: "1.0"
    pluginType: "dialog"
    width: 700
    height: 350

    onRun: {
        console.log("hello world")
    }

    function getRandomInt(max) {
        return Math.floor(Math.random() * max);
    }

    function calcNumOfChangedNotes(notes, fieldOfText) {
        return Math.floor(fieldOfText / 100 * notes);
    }

    function countAllElements(allElements, track) {
        var numOfNotes = [];
        var cursorTwo = curScore.newCursor();
        cursorTwo.rewind(2);
        var endTick = cursorTwo.tick;
        cursorTwo.rewind(1);
        cursorTwo.track = track;

        while (cursorTwo.tick < endTick) {
            if (cursorTwo.element.type === 93) {
                if (cursorTwo.element.notes[0].tieForward) {
                    numOfNotes.push(1);
                    cursorTwo.next();
                    cursorTwo.next();
                } else {
                    numOfNotes.push(1);
                    cursorTwo.next();
                }
            } else {
                if (allElements) {
                    numOfNotes.push(1);
                    cursorTwo.next();
                } else {
                    cursorTwo.next();
                }
            }
        }
        return numOfNotes;
    }

    function getRandomMatrix(length, count) {
        var newArr = [];
        for (var i = 0; i < length - count; i++) {
            newArr.push(0);
        }

        for (var k = 0; k < count; k++) {
            newArr.push(1);
        }

        newArr.sort(function(a, b) {
            return Math.random() - 0.5;
        });

        return newArr;
    }

    function getNextElementDuration(cursor) {
        return cursor.element.duration.numerator;
    }

    function adjustElement(cursor, duration, type, count, randMatrix, countInterval, pattern, permutationMatrix) {
        if (type === 93) {
            var hasTieForward = cursor.element.notes[0].tieForward;

            if (randMatrix[count] === 1) {
                curScore.startCmd();

                if (hasTieForward) {
                    cursor.setDuration(duration.numerator + getNextElementDuration(cursor), duration.denominator);
                } else {
                    cursor.setDuration(duration.numerator, duration.denominator);
                }

                if (uniformProbability.checked) {
                    cursor.addNote(cursor.element.notes[0].pitch + Number(expandRange(textField.text)));
                } else if (repeatedPattern.checked) {
                    cursor.addNote(cursor.element.notes[0].pitch + Number(pattern[countInterval]));
                } else if (permutation.checked) {
                    cursor.addNote(cursor.element.notes[0].pitch + Number(permutationMatrix[countInterval]));
                }
                curScore.endCmd();
            } else if (randMatrix[count] === 0) {
                curScore.startCmd();

                if (hasTieForward) {
                    cursor.setDuration(duration.numerator + getNextElementDuration(cursor), duration.denominator);
                } else {
                    cursor.setDuration(duration.numerator, duration.denominator);
                }

                cursor.addNote(cursor.element.notes[0].pitch);

                curScore.endCmd();
            }
        } else if (type === 25) {
            curScore.startCmd();
            cursor.setDuration(duration.numerator, duration.denominator);
            cursor.addRest();
            curScore.endCmd();
        }
    }

    function getArray(percentages, intervals, numberOfNotesToChange) {
        var arrPercentages = percentages.split(',').map(function(item) {
            return Number(item);
        });

        var arrIntervals = intervals.split(',').map(function(item) {
            return Number(item);
        });

        var newArr = [];
        var inPush = 0;

        for (var i = 0; i < arrPercentages.length; i++) {
            var arrPercentage = arrPercentages[i];
            var arrInterval = arrIntervals[i];

            var count = Math.floor((arrPercentage / 100) * numberOfNotesToChange);

            for (var j = 0; j < count; j++) {
                newArr.push(inPush);
            }

            inPush = inPush + 1;
        }

        while (newArr.length < numberOfNotesToChange) {
            newArr.push(0);
        }

        return newArr;
    }

    function selectRandInterval(intervals) {
        var arrOfIntervals = intervals.split(',').map(function(item) {
            return Number(item);
        });

        var randNum = Math.floor(Math.random() * arrOfIntervals.length);

        return arrOfIntervals[randNum];
    }

    function expandRange(input) {
        var resultArray = [];
        var insideParenthesis = input.split(',').map(function(item) {
            item = item.trim();
            if (item.startsWith("(") && item.endsWith(")")) {
                return item;
            } else {
                resultArray.push(item);
            }
        }).filter(function(item) {
            return item !== undefined;
        });

        for (var i = 0; i < insideParenthesis.length; i++) {
            var parts = insideParenthesis[i].slice(1, -1).split(' ');
            var start = parseInt(parts[0], 10);
            var end = parseInt(parts[1], 10);

            for (var j = 0; j < end - start + 1; j++) {
                resultArray.push(start + j);
            }
        }

        var randNum = Math.floor(Math.random() * resultArray.length);
        return resultArray[randNum];
    }

    function expandRange2(input) {
        var resultArray = [];
        var insideParenthesis = input.split(',').map(function(item) {
            item = item.trim();
            if (item.startsWith("(") && item.endsWith(")")) {
                return item;
            } else {
                resultArray.push(item);
            }
        }).filter(function(item) {
            return item !== undefined;
        });

        for (var i = 0; i < insideParenthesis.length; i++) {
            var parts = insideParenthesis[i].slice(1, -1).split(' ');
            var start = parseInt(parts[0], 10);
            var end = parseInt(parts[1], 10);

            for (var j = 0; j < end - start + 1; j++) {
                resultArray.push(start + j);
            }
        }

        return resultArray;
    }

    function getPaternMatrix(lengthOfNotesToChange) {
        var matrixToShuffle = expandRange2(textField.text);
        var newArr = [];
        for (var i = 0; i < lengthOfNotesToChange; i++) {
            newArr.push(matrixToShuffle[i % matrixToShuffle.length]);
        }
        return newArr;
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

    function runIt() {
        var els = curScore.selection.elements;
        var tracks = [];

        for (var i in els) {
            if (!tracks.some(function(x) { return x == els[i].track; })) {
                tracks.push(els[i].track);
            }
        }

        for (var j = 0; j < tracks.length; j++) {
            var cursor = curScore.newCursor();
            cursor.rewind(1);
            cursor.track = tracks[j];

            var count = 0;
            var countInterval = 0;

            var arrOfIntervals = textField.text.split(',').map(function(item) {
                return Number(item);
            });

            var numNotes = countAllElements(false, tracks[j]).length;
            var numAllElements = countAllElements(true, tracks[j]).length;

            var changedNotes = calcNumOfChangedNotes(numNotes, textField1.text);
            var permutationMatrix = getRandomPermutation(expandRange2(textField.text), changedNotes);
            var patternMatrix = getPaternMatrix(changedNotes);
            var randMatrix = getRandomMatrix(numNotes, changedNotes);

            for (var i = 0; i < numAllElements; i++) {
                adjustElement(cursor, cursor.element.duration, cursor.element.type, count, randMatrix, countInterval, patternMatrix, permutationMatrix);

                if (randMatrix[count] === 1 && cursor.element.type === 93) {
                    countInterval = countInterval + 1;
                }

                if (cursor.element.type === 93) {
                    count = count + 1;
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#454545"
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            id: horizontalLayout
            anchors.topMargin: 20
            padding: 30
            TextField {
                id: textField
                placeholderText: qsTr("Desired intervals (e.g. (-10 -5), 0, 0, 0, 5, 6, (-1 5))")
            }

            TextField {
                id: textField1
                placeholderText: "Percentage of notes transposed (e.g. 50)"
            }
        }

        ButtonGroup {
            buttons: column.children
        }

        Row {
            id: column
            anchors.top: horizontalLayout.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 50

            RadioButton {
                id: uniformProbability
                checked: true
                text: qsTr("Uniform Probability")
                padding: 15
                contentItem: Text {
                    text: uniformProbability.text
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: uniformProbability.indicator.width + uniformProbability.spacing
                    color: "white"
                    opacity: uniformProbability.hovered ? 0.8:1
                }
            }

            RadioButton {
                id: repeatedPattern
                text: qsTr("Repeated Pattern")
                padding: 15
                contentItem: Text {
                    text: repeatedPattern.text
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: repeatedPattern.indicator.width + repeatedPattern.spacing
                    color: "white"
                    opacity: repeatedPattern.hovered ? 0.8:1
                }
            }

            RadioButton {
                id: permutation
                text: qsTr("Permutation")
                padding: 15
                contentItem: Text {
                    text: permutation.text
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: permutation.indicator.width + permutation.spacing
                    color: "white"
                    opacity: permutation.hovered ? 0.8:1
                }
            }
        }

        Button {
            anchors.top: column.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: runIt()
            text: "Submit"
            highlighted: true
        }
    }
}
