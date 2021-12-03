TextEntries = {
    --{Entry_ID, Entry_Text},
    {"CBB_ALERT_OPEN_OUTSIDE_MENU", "Press ~INPUT_ENTER~ to open the ~y~Blood Bowl~s~ menu."},
}

AddEventHandler('bloodBowl.GenerateTextEntries', function(_customEntries)
    local tbl = TextEntries
    if type(_customEntries) == "table" then
        tbl = _customEntries
    end
    for i,k in pairs(tbl) do
        AddTextEntry(k[1], k[2])
    end
end)