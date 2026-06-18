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
    property string customFormat: pluginData.customFormat || "d 'days' H 'hours' m 'minutes' L"
    property string customShortFormat: pluginData.customShortFormat || "d'd' H'h' m'm'"

    property real value: 0
    property real remainingMs: NaN

    function isCustomUnit() {
        return unit === "custom" || unit === "daysHoursMinutes"
    }

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
        case "custom": divisor = 1000 * 60; break
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

    function effectiveLabel() {
        return remainingMs < 0 ? "overdue" : (label && label.trim().length > 0 ? label.trim() : "remaining")
    }

    function pad(valueToPad, width) {
        let text = String(Math.floor(Math.abs(valueToPad)))
        while (text.length < width)
            text = "0" + text
        return text
    }

    function durationParts() {
        const absMs = Math.abs(remainingMs)
        const totalSeconds = Math.floor(absMs / 1000)
        const totalMinutes = Math.floor(totalSeconds / 60)
        const totalHours = Math.floor(totalMinutes / 60)
        const totalDays = Math.floor(totalHours / 24)

        return {
            seconds: totalSeconds - totalMinutes * 60,
            minutes: totalMinutes - totalHours * 60,
            hours: totalHours - totalDays * 24,
            days: totalDays,
            weeks: Math.floor(totalDays / 7),
            months: Math.floor(totalDays / 30.44),
            totalSeconds: totalSeconds,
            totalMinutes: totalMinutes,
            totalHours: totalHours
        }
    }

    function formatToken(token, parts) {
        switch (token) {
        case "dd": return pad(parts.days, 2)
        case "d": return String(parts.days)
        case "ww": return pad(parts.weeks, 2)
        case "w": return String(parts.weeks)
        case "MM": return pad(parts.months, 2)
        case "M": return String(parts.months)
        case "HH": return pad(parts.hours, 2)
        case "H": return String(parts.hours)
        case "mm": return pad(parts.minutes, 2)
        case "m": return String(parts.minutes)
        case "ss": return pad(parts.seconds, 2)
        case "s": return String(parts.seconds)
        case "hh": return pad(parts.totalHours, 2)
        case "h": return String(parts.totalHours)
        case "tt": return pad(parts.totalMinutes, 2)
        case "t": return String(parts.totalMinutes)
        case "L": return effectiveLabel()
        case "X": return remainingMs < 0 ? "-" : ""
        case "x": return remainingMs < 0 ? "!" : ""
        default: return token
        }
    }

    function customFormatTokens() {
        return ["dd", "ww", "MM", "HH", "mm", "ss", "hh", "tt", "d", "w", "M", "H", "m", "s", "h", "t", "L", "X", "x"]
    }

    function formatDuration(formatString, fallbackFormat) {
        if (isNaN(remainingMs))
            return targetTimestamp ? "Invalid date" : "No date set"

        const parts = durationParts()
        const tokens = customFormatTokens()
        const fmt = formatString && formatString.trim().length > 0 ? formatString : fallbackFormat
        let out = ""
        let literal = false
        let i = 0

        while (i < fmt.length) {
            const ch = fmt.charAt(i)
            if (ch === "'") {
                if (i + 1 < fmt.length && fmt.charAt(i + 1) === "'") {
                    out += "'"
                    i += 2
                    continue
                }
                literal = !literal
                i += 1
                continue
            }

            if (literal) {
                out += ch
                i += 1
                continue
            }

            let matched = false
            for (let t = 0; t < tokens.length; t += 1) {
                const token = tokens[t]
                if (fmt.substr(i, token.length) === token) {
                    out += formatToken(token, parts)
                    i += token.length
                    matched = true
                    break
                }
            }

            if (!matched) {
                out += ch
                i += 1
            }
        }

        return out
    }

    function formatUsesSeconds(formatString) {
        if (!formatString)
            return false

        let literal = false
        let i = 0
        while (i < formatString.length) {
            const ch = formatString.charAt(i)
            if (ch === "'") {
                if (i + 1 < formatString.length && formatString.charAt(i + 1) === "'") {
                    i += 2
                    continue
                }
                literal = !literal
                i += 1
                continue
            }
            if (!literal && ch === "s")
                return true
            i += 1
        }
        return false
    }

    function displayText() {
        if (isCustomUnit())
            return formatDuration(customFormat, "d 'days' H 'hours' m 'minutes' L")
        if (isNaN(value))
            return targetTimestamp ? "Invalid date" : "No date set"
        const absValue = Math.abs(value)
        const display = absValue % 1 === 0 ? absValue.toFixed(0) : absValue.toFixed(1)
        const pluralUnit = absValue === 1 ? unit.slice(0, -1) : unit
        return display + " " + pluralUnit + " " + effectiveLabel()
    }

    function shortUnit() {
        switch (unit) {
        case "hours": return "h"
        case "days": return "d"
        case "weeks": return "w"
        case "months": return "mo"
        default: return "d"
        }
    }

    function displayTextShort() {
        if (isCustomUnit())
            return formatDuration(customShortFormat, customFormat || "d'd' H'h' m'm'")
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
    onCustomFormatChanged: recalc()
    onCustomShortFormatChanged: recalc()

    Timer {
        interval: {
            switch (root.unit) {
            case "hours": return 1000 * 60 * 6        // 0.1 hour
            case "custom": return (root.formatUsesSeconds(root.customFormat) || root.formatUsesSeconds(root.customShortFormat)) ? 1000 : 1000 * 60
            case "daysHoursMinutes": return 1000 * 60 // legacy value from v1.0.2
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
