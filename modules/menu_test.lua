
menu=require('menu')
menu.setstruct({
    items = {
        {label='..'},
        {
            { label = '..' },
            label = 'info',
            items = {
                { label = '..' },
                { label = 'Battery', type='inline_func', eval='adc.read(0)' },
                { label = 'Heap', type='inline_func', eval='node.heap()' },
                { label = 'Tick', type='inline_func', eval='tmr.now()' }
            }
        }, {
            --2
            label = 'control',
            items = {
                { label = '..' },
                { label = 'Power', type='enum', values={'On', 'Off'} },
                { label = 'Polarity', type='enum', values={'forward', 'reverse'} },
                { label = 'Reboot', type='func', eval='node.restart()' }
            }
        }, {
            --3
            label = 'settings',
            items = {
                { label = '..' },
                {
                    label = 'electrical',
                    items = {
                        { label = '..' },
                        { label = 'intensity', type='range', min=1, max=10, increment=1 },
                        { label = 'LowBat', type='range', min=11, max=14, increment=1 },
                        { label = 'HighBat', type='range', min=11, max=14, increment=1 },
                        { label = 'PowerCycle', type='range', min=1, max=600, increment=1  }
                    }
                },
                {
                    label = 'WiFi',
                    items = {
                        { label = '..' },
                        { label = 'SSID' , type='string'},
                        { label = 'Pswd' , type='string'},
                        { label = 'b/g/n' , type='enum', values={'b', 'g', 'n'}},
                        { label = 'channel', type='range', min=1, max=14 }
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
