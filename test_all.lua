unit = require('luaunit')

mydns=require('modules/mydns')

function testMyDns_b64Code()
    unit.assertEquals(mydns.b64Code('Test message to encode'),'todo')
end

os.exit( unit.LuaUnit.run() )
