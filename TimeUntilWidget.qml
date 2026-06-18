import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root
    property var popoutService: null

    layerNamespacePlugin: "timeUntil"

    // settings from pluginData
    property string targetTimestamp: pluginData.targetTimestamp || ""
    property string unit: pluginData.unit || "days"
    property string label: pluginData.label || ""

    property real value: 0
    property real remainingMs: NaN

    function recalc() {
        if (!targetTimestamp) {
            value = NaN
            remainingMs = NaN
            return
        }

        const target = new Date(targetTimestamp.replace("T", " "))
        if (isNaN(target.getTime())) {
            value = NaN
            remainingMs = NaN
            return
        }
        const now = new Date()
        remainingMs = target.getTime() - now.getTime()

        let divisor
        switch (unit) {
        case "hours": divisor = 1000 * 60 * 60; break
        case "days": divisor = 1000 * 60 * 60 * 24; break
        case "weeks": divisor = 1000 * 60 * 60 * 24 * 7; break
        case "months": divisor = 1000 * 60 * 60 * 24 * 30.44; break
        case "daysHoursMinutes": divisor = 1000 * 60; break
        default: divisor = 1000 * 60 * 60 * 24
        }

        if (remainingMs < 0) {
            const raw = Math.abs(remainingMs) / divisor
            value = -(Math.round(raw * 10) / 10)
            return
        }

        const raw = remainingMs / divisor
        value = Math.round(raw * 10) / 10
    }

    function pluralize(count, singular, plural) {
        return count === 1 ? singular : plural
    }

    function breakdownText(shortFormat) {
        if (isNaN(remainingMs)) {
            if (shortFormat)
                return targetTimestamp ? "!date" : "—"
            return targetTimestamp ? "Invalid date" : "No date set"
        }

        let totalMinutes = Math.floor(Math.abs(remainingMs) / (1000 * 60))
        const days = Math.floor(totalMinutes / (60 * 24))
        totalMinutes = totalMinutes - days * 60 * 24
        const hours = Math.floor(totalMinutes / 60)
        const minutes = totalMinutes - hours * 60

        if (shortFormat) {
            const suffix = remainingMs < 0 ? "!" : ""
            return days + "d " + hours + "h " + minutes + "m" + suffix
        }

        const effectiveLabel = remainingMs < 0 ? "overdue" : (label && label.trim().length > 0 ? label.trim() : "remaining")
        return days + " " + pluralize(days, "day", "days") + " "
            + hours + " " + pluralize(hours, "hour", "hours") + " "
            + minutes + " " + pluralize(minutes, "minute", "minutes") + " "
            + effectiveLabel
    }

    function displayText() {
        if (unit === "daysHoursMinutes")
            return breakdownText(false)
        if (isNaN(value))
            return targetTimestamp ? "Invalid date" : "No date set"
        const absValue = Math.abs(value)
        const effectiveLabel = value < 0 ? "overdue" : (label && label.trim().length > 0 ? label.trim() : "remaining")
        const display = absValue % 1 === 0 ? absValue.toFixed(0) : absValue.toFixed(1)
        const pluralUnit = absValue === 1 ? unit.slice(0, -1) : unit
        return display + " " + pluralUnit + " " + effectiveLabel
    }

    function shortUnit() {
        switch (unit) {
        case "hours": return "h"
        case "days": return "d"
        case "weeks": return "w"
        case "months": return "mo"
        case "daysHoursMinutes": return "m"
        default: return "d"
        }
    }

    function displayTextShort() {
        if (unit === "daysHoursMinutes")
            return breakdownText(true)
        if (isNaN(value))
            return targetTimestamp ? "!date" : "—"
        const absValue = Math.abs(value)
        const display = absValue % 1 === 0 ? absValue.toFixed(0) : absValue.toFixed(1)
        const suffix = value < 0 ? "!" : ""
        return display + shortUnit() + suffix
    }

    // Recalculate the remaining time when settings are changed
    onTargetTimestampChanged: recalc()
    onUnitChanged: recalc()
    onLabelChanged: recalc()

    Timer {
        interval: {
            switch (root.unit) {
            case "hours": return 1000 * 60 * 6        // 0.1 hour
            case "daysHoursMinutes": return 1000 * 60 // 1 minute
            case "days": return 1000 * 60 * 60 * 2.4  // 0.1 day
            case "weeks": return 1000 * 60 * 60 * 24  // 1 day
            case "months": return 1000 * 60 * 60 * 24 // 1 day
            default: return 1000 * 60 * 60 * 2.4
            }
        }
        running: true
        repeat: true
        onTriggered: recalc()
    }

    Component.onCompleted: recalc()

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            StyledText {
                text: displayText()
                font.pixelSize: Theme.fontSizeMedium
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            StyledText {
                text: displayTextShort()
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout

            showCloseButton: false

            StyledText {
                width: parent.width
                readonly property string helpText: "Set the target date in DMS Settings > Plugins > Time Until"
                text: !root.targetTimestamp ? helpText : (root.value < 0 ? "Time since " : "Time until ") + root.targetTimestamp
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
    }

    popoutWidth: 250
}