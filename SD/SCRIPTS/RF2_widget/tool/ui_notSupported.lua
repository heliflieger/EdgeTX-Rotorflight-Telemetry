local function factory(i18n)
    -- Fallback-Texte, falls Übersetzungen fehlen
    local text1 = (i18n and i18n.radioNotSupported) or "*Radio not supported!"
    local text2 = (i18n and i18n.needGraphicalRadio) or "*Need graphical radio"

    local function run(event)
        lcd.clear()
        lcd.drawText(CENTER, 15, text1, MIDSIZE)
        lcd.drawText(CENTER, 35, text2, MIDSIZE)

        if event == EVT_VIRTUAL_EXIT then
            return 1 -- A non-zero value exits the tool
        end

        return 0
    end
    return run
end

return factory