menu_struct={
    items = {
        {label='Exit', type='exit'},
        {label='Save', type='save'},
        {
            { label = '..' },
            label = 'Info',
            items = {
                { label = '..' },
                { label = 'Version', type='inline_func', eval='FIRMWARE_VERSION' },
                { label = 'Heap', type='inline_func', eval='node.heap()' },
                { label = 'Tmr', type='inline_func', eval='tmr.now()' },
                { label = 'Rtc', type='inline_func', eval='rtctime.get()' }
            }
        }, {
            --2
            label = 'Control',
            items = {
                { label = '..' },
--                { label = 'ControlMode', type='toggle', labels={'auto', 'manual'}, value=true, prop='control_mode', transient=true },
--                { label = 'ZapOn', type='toggle', value=false, prop='power_flag', transient=true},
--                { label = 'ZapOff', type='toggle', value=false, prop='power_flag', transient=true},
                { label = 'Flip Polarity', type='func', eval='polarityFlip()' },
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
                        { label = 'DutyCycle(%)', type='range', min=0, max=100, increment=5, value=2, prop='duty_cycle' },
                        { label = 'LoBat(mV)', type='range', min=12000, max=13000,  value=12000, increment=100, prop='low_bat' },
                        { label = 'HiBat(mV)', type='range', min=12000, max=14000,  value=12200, increment=100, prop='high_bat' }
--                        { label = 'Polarity(min)', type='range', min=1, max=30, increment=1, value=30, prop='polarity_cycle'  }
                    }
                }
--                ,
--                {
--                    label = 'WiFi',
--                    items = {
--                        { label = '..' },
--                        { label = 'SSID' , type='string'},
--                        { label = 'Pswd' , type='string'},
--                        { label = 'b/g/n' , type='enum', values={'b', 'g', 'n'}, value='', prop='wifi_phymode'},
--                        { label = 'channel', type='range', min=1, max=14, value=1, prop='channel'}
--                    }
--                },
--                {
--                    label = 'SD',
--                    items = {
--                        { label = '..' },
--                        { label = 'Info' , type='func', eval=''},
--                        { label = 'Erase', type='func', eval=''},
--                        { label = 'Format', type='func', eval=''}
--                    }
--                }
            }
        }
    }
}