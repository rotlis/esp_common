
menu=require('menu')
menu.setstruct({
    items = {
        {label='..'},
        {
            { label = '..' },
            label = 'info',
            items = {
                { label = '..' },
                { label = 'Battery voltage', type='func', value=todo },
                { label = 'Free Memory', type='func', value=todo },
                { label = 'Tick', type='func', value=todo }
            }
        }, {
            --2
            label = 'control',
            items = {
                { label = '..' },
                { label = 'Power', type='enum', values={'On', 'Off'} },
                { label = 'Polarity', type='enum', values={'forward', 'reverse'} }
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
