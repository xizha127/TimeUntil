import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    pluginId: "timeUntil"

    StringSetting {
        label: "Target Date (for example, 2027-01-01 21:37)"
        settingKey: "targetTimestamp"
    }

    SelectionSetting {
        settingKey: "unit"
        label: "Time Units"
        options: [
            { label: "Hours", value: "hours" },
            { label: "Days", value: "days" },
            { label: "Custom Format", value: "custom" },
            { label: "Weeks", value: "weeks" },
            { label: "Months", value: "months" }
        ]
        defaultValue: "days"
    }

    StringSetting {
        label: "Custom Format"
        settingKey: "customFormat"
        description: "Used when Time Units is Custom Format. Tokens: d/dd total days, H/HH hours, m/mm minutes, s/ss seconds, w/ww weeks, M/MM months, h/hh total hours, t/tt total minutes, L label, X overdue minus, x overdue bang. Quote literals with single quotes."
        placeholder: "d 'days' H 'hours' m 'minutes' L"
        defaultValue: "d 'days' H 'hours' m 'minutes' L"
    }

    StringSetting {
        label: "Custom Short Format"
        settingKey: "customShortFormat"
        description: "Used for vertical bar display when Time Units is Custom Format. Leave empty to fall back to Custom Format."
        placeholder: "d'd' H'h' m'm'"
        defaultValue: "d'd' H'h' m'm'"
    }

    StringSetting {
        label: "Label (default: \"remaining\")"
        settingKey: "label"
        placeholder: "until my birthday"
    }
}
