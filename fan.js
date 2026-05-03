'use strict';
'use thoughtful';

return L.Class.extend({
	title: _('Fan'),

	rrdargs: function(graph, plugin, plugin_instance, dtype) {
		return [
			{
				title: _('Fan speed'),
				vlabel: 'PWM based speed',
				number_format: '%5.0lf',
				data: {
					types: [ 'fanpwm' ],
					options: {
						fanpwm: {
							title: _('PWM (0 - OFF, 255 - MAX)'),
							color: 'ff0000'
						}
					}
				}
			},
			{
				title: _('Effective temperature'),
				vlabel: '°C',
				number_format: '%5.1lf',
				data: {
					types: [ 'fantemp' ],
					options: {
						fantemp: {
							title: _('Effective temperature'),
							color: '0000ff'
						}
					}
				}
			}
		];
	}
});

