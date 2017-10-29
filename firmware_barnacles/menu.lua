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
local presentationMode=0 --0-info, 1-menu

function M.init_OLED() --Set up the u8glib lib
    if hasOled then
        i2c.setup(0, sda, scl, i2c.SLOW)
        disp = u8g.ssd1306_128x64_i2c(sla)
        disp:setFont(u8g.font_6x10)
        disp:setFontRefHeightExtendedText()
        disp:setDefaultForegroundColor()
--        disp:setFontPosTop()
    end
end

function getPropOrDefault(itv)
--    print(itv.label)
    local val = nil
    if itv.prop~=nil then
        val = loadstring('return '..itv.prop)()
    end
    if val==nil then
        val = itv.value
    end
    return val
end

function M.showMenu()
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
        local val = getPropOrDefault(itv)
        if val~=nil then
            if itv.type=='toggle' and itv.labels~=nil then
                print('itv.value', val)
                line=line..': '..(val and itv.labels[1] or itv.labels[2])
            else
                line=line..': '..tostring(val)
            end
        end
        table.insert(lines, line)
    end

    --show in OLED
    disp:firstPage()
    disp:setFont(u8g.font_6x10)
    repeat
        disp:drawStr(0, 10, '@'..(menu_page.label~=nil and menu_page.label or 'MENU'))
        for itn, line in pairs(lines) do
            disp:drawStr(1, itn*10+13, line)
        end

    until disp:nextPage() == false

end

function M.topMenu()
    path={}
    M.showMenu()
end

function M.setstruct(struct)
    menu_struct = struct
    path={}
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
        local val=getPropOrDefault(menuItem)
        val=val+(shift*(menuItem.increment~=nil and menuItem.increment or 1) )
        val=math.min(val,menuItem.max)
        val=math.max(val,menuItem.min)
        loadstring(menuItem.prop..'='..val)()
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
            presentationMode=0
            M.show()
        else
            curLinePos = table.remove(path)
        end
    elseif (itv.type==nil) then
        path[#path + 1] = curLinePos
        curLinePos = 1
    elseif itv.type=='save' then
        M.saveProps()
    elseif (itv.type=='func') then
        loadstring(itv.eval)()
    elseif (itv.type=='range') then
        shiftMode=1
    elseif (itv.type=='toggle') then
        local val=getPropOrDefault(itv)
        val = not val
        loadstring(itv.prop..'='..tostring(val))()
    elseif (itv.type=='enum') then
        local val=getPropOrDefault(itv)
        print('enum value', val)
        local found=false
        for k, v in pairs(itv.values) do
            print('comparing',val, v)
            if v == val then
                print('found at '..k)
                found=true
                if k<#itv.values then
                    val=itv.values[k+1]
                else
                    val=itv.values[1]
                end
                break
            end
        end
        if not found then
           val = itv.values[1]
        end
--        print(itv.prop..'=\''..tostring(val)..'\'')
        loadstring(itv.prop..'=\''..tostring(val)..'\'')()
---------------------- here
    elseif (itv.type=='exit') then
        presentationMode=0
        M.show()
    else

    end

end

function M.menuItemClick()
    shiftMode=0
end

function M.loadProps()

end


function addFromPage(props, menuPage)
    for _, item in pairs(menuPage.items) do
        if item.prop~=nil and item.transient~=true then
            local val=getPropOrDefault(item)
            if item.type=='range' or item.type=='toggle' then
                table.insert(props, item.prop..'='..tostring(val))
            else
                table.insert(props, item.prop..'=\''..val..'\'')
            end

        elseif item.items~=nil then
            addFromPage(props, item)
        else

        end
    end
end

function M.saveProps()
    local props = {}
    addFromPage(props, menu_struct)
    file.open("config.lua", "w+")
    for _, prop in pairs(props) do
        print(prop)
        file.writeline(prop)
    end
    file.close()
end



local myrotary=require('myrotary')
myrotary.init(0,5,6,7,
    function(shift)
        if presentationMode==1 then 
            if shiftMode==0 then
                M.navigationShift(shift)
            else
                M.menuItemShift(shift)
            end
        end    
    end,
    function()
        if presentationMode==0 then 
            presentationMode=1
            M.show()
        else    
            print("presentationMode:1")
            if shiftMode==0 then
                M.navigationClick()
            else
                M.menuItemClick()
            end
            M.show()
        end    
    end
)

function M.show()
   if presentationMode==0 then
        M.showInfo()
    else
        M.showMenu()
    end    
end

function M.showInfo()
    local lines=getInfoLines()
    disp:firstPage()
    disp:setFont(u8g.font_10x20)
    repeat
        for itn, line in pairs(lines) do
            disp:drawStr(0, itn*20, line)
        end
    until disp:nextPage() == false
end
-- random helpers

M.init_OLED()

return M
