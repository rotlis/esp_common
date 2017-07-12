local M = {};

local uartAppender=function(m)
    print(m)
end

local appenders={uartAppender}

function M.log(m)
    for _,appender in pairs(appenders) do
        appender(m)
    end
end

function M.addAppender(appender)
   table.insert(appenders, appender)
end

return M
