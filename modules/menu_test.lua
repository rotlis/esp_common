
menu=require('menu')
menu.setstruct({
    items = {
        {label='..'},
        {
            { label = '..' },
            label = 'Info',
            items = {
                { label = '..' },
                { label = 'Battery', type='inline_func', eval='adc.read(0)' },
                { label = 'Heap', type='inline_func', eval='node.heap()' },
                { label = 'Tick', type='inline_func', eval='tmr.now()' }
            }
        }, {
            --2
            label = 'Control',
            items = {
                { label = '..' },
                { label = 'Power', type='toggle', value=false},
                { label = 'Polarity', type='toggle', labels={'forward', 'reverse'}, value=true },
                { label = 'Reboot', type='func', eval='node.restart()' }
            }
        }, {
            --3
            label = 'Settings',
            items = {
                { label = '..' },
                {
                    label = 'Electrical',
                    items = {
                        { label = '..' },
                        { label = 'Intensity', type='range', min=0, max=10, increment=2, value=4 },
                        { label = 'LowBat', type='range', min=11, max=14,  value=11 },
                        { label = 'HighBat', type='range', min=11, max=14,  value=11 },
                        { label = 'PowerCycle', type='range', min=0, max=600, increment=10, value=0  }
                    }
                },
                {
                    label = 'WiFi',
                    items = {
                        { label = '..' },
                        { label = 'SSID' , type='string'},
                        { label = 'Pswd' , type='string'},
                        { label = 'b/g/n' , type='enum', values={'b', 'g', 'n'}, value=''},
                        { label = 'channel', type='range', min=1, max=14, value=1}
                    }
                },
                {
                    label = 'SD',
                    items = {
                        { label = '..' },
                        { label = 'Info' , type='func', value=todo},
                        { label = 'Erase', type='func', value=todo },
                        { label = 'Format', type='func', vlaue=todo }
                    }
                }
            }
        }
    }
})
