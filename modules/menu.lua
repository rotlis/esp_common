local M = {};


local sda = 1 -- SDA Pin
local scl = 2 -- SCL Pin
local sla = 0x3C

local hasOled=true

local path = {}
local curLinePos = 1
local menu_struct

local menu_page


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

    --show in OLED
    disp:firstPage()
    repeat
        disp:drawStr(0, 0, '@'..(menu_page.label~=nil and menu_page.label or 'MENU'))
        for itn, itv in pairs(menu_page.items) do
            disp:drawStr(1, itn*10+6, (itn==curLinePos and '>' or '') .. itv.label)
        end

    until disp:nextPage() == false

end


function M.setstruct(struct)
    menu_struct = struct
    M.showMenu(path)
end

local myrotary=require('myrotary')
myrotary.init(0,5,6,7,
    function(shift)
        curLinePos = curLinePos + shift
        curLinePos = math.max(curLinePos, 1)
        curLinePos = math.min(curLinePos, #menu_page.items)
        M.showMenu(path)
    end,
    function()
        if (curLinePos == 1) then
            if (#path==0) then
                print('exit')
            else
                curLinePos = table.remove(path)
            end
        elseif (menu_page.items[curLinePos].type==nil) then
                path[#path + 1] = curLinePos
                curLinePos = 1
        else
                print('Function-----------------')
        end
        M.showMenu(path)
    end
)

M.init_OLED()


return M
