local M = {};


local sda = 1 -- SDA Pin
local scl = 2 -- SCL Pin
local sla = 0x3C

local hasOled=true

local path = {}
local curLinePos = 1
local menu_struct

local menu_page
local shiftMode=0 --0-navigation, 1-menuItem


function M.init_OLED() --Set up the u8glib lib
    if hasOled then
        i2c.setup(0, sda, scl, i2c.SLOW)
        disp = u8g.ssd1306_128x64_i2c(sla)
        disp:setFont(u8g.font_6x10)
        disp:setFontRefHeightExtendedText()
        disp:setDefaultForegroundColor()
        disp:setFontPosTop()
    end
end


function M.showMenu(path)
    --descent
    menu_page = menu_struct
    for _, pn in pairs(path) do
        --        print(pn)
        menu_page = menu_page.items[pn]
    end

    --prepare lines
    local lines={}
    for itn, itv in pairs(menu_page.items) do
        local line=(itn==curLinePos and (shiftMode==0 and '>' or '=') or ' ') .. itv.label
        if itv.type=='inline_func' then
            line=line..': '..loadstring('return '..itv.eval)()
        end
        if itv.value~=nil then
            if itv.type=='toggle' and itv.labels~=nil then
                print('itv.value', itv.value)
                line=line..': '..(itv.value and itv.labels[1] or itv.labels[2])
            else
                line=line..': '..tostring(itv.value)
            end
        end
        table.insert(lines, line)
    end

    --show in OLED
    disp:firstPage()
    disp:drawStr(0, 0, '@'..(menu_page.label~=nil and menu_page.label or 'MENU'))
    repeat
        for itn, line in pairs(lines) do
            disp:drawStr(1, itn*10+6, line)
        end

    until disp:nextPage() == false

end


function M.setstruct(struct)
    menu_struct = struct
    M.showMenu(path)
end

function M.navigationShift(shift)
    curLinePos = curLinePos + shift
    curLinePos = math.max(curLinePos, 1)
    curLinePos = math.min(curLinePos, #menu_page.items)
    M.showMenu(path)
end

function M.menuItemShift(shift)
    local menuItem=menu_page.items[curLinePos]
    if (menuItem.type=='range') then
        menuItem.value=menuItem.value+(shift*(menuItem.increment~=nil and menuItem.increment or 1) )
        menuItem.value=math.min(menuItem.value,menuItem.max)
        menuItem.value=math.max(menuItem.value,menuItem.min)
--    elseif (menuItem.type=='toggle') then
--        menuItem.value=not menuItem.value
    else

    end
    M.showMenu(path)
end

function M.navigationClick()
    local itv=menu_page.items[curLinePos]
    if (curLinePos == 1) then
        if (#path==0) then
            print('exit')
        else
            curLinePos = table.remove(path)
        end
    elseif (itv.type==nil) then
        path[#path + 1] = curLinePos
        curLinePos = 1
    elseif (itv.type=='func') then
        loadstring(itv.eval)()
    elseif (itv.type=='range') then
        shiftMode=1
    elseif (itv.type=='toggle') then
        itv.value = not itv.value
    elseif (itv.type=='enum') then
        for k, v in pairs(itv.values) do
            if v == itv.value then
                if k<#itv.values then
                    itv.value=itv.values[k+1]
                else
                    itv.value=itv.values[1]
                end
                return
            end
        end
        itv.value = itv.values[1]
---------------------- here
    else

    end

end

function M.menuItemClick()
    print("commit value")
    shiftMode=0
end

local myrotary=require('myrotary')
myrotary.init(0,5,6,7,
    function(shift)
        if shiftMode==0 then
            M.navigationShift(shift)
        else
            M.menuItemShift(shift)
        end
    end,
    function()
        if shiftMode==0 then
            M.navigationClick()
        else
            M.menuItemClick()
        end
        M.showMenu(path)
    end
)

M.init_OLED()

-- random helpers


return M
