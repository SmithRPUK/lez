The LEZ, or 'Low Emission Zone', is a means of detering traffic from entering central metropolitan areas, with the objective being to reduce air pollution in a dense urban area.
An example of this can be found in London UK.

This resource tracks whether or not the player is in a vehicle. If the player is in a vehicle, the player's position is checked against 1 or more pre-defined polygons representing
the boundary of the LEZs, as defined in the config file. If a player enters a LEZ, they are warned that they have entered and are being charged. The resource checks if the player is
still in the LEZ by a set time interval, with the player notified as they leave the zone.

The resource only conducts these checks if the player is in a vehicle, meaning that if a player parks their car in a LEZ, then walks out of it, they will not be charged again when
they walk back inside to pick up their car. The player player is only notified they have left if they drive out of the LEZ.

A proximity check is conducted, wherein if the player is close to an LEZ, the check frequency increases, as it is assumed that they will soon enter the zone. This proximity distance
is also configurable. If the player is outside of this set range, the checking frequency is decreased, as it is assumed they are unlikely to enter any time soon. This is a client
only feature, as integration with your server's systems for charging the player will be specific to your server. There are comments in the code for when it would be appropriate
to talk to the server.

The resource is further robust by checking that the player is not flying above the zone, and is infact driving through it, as to avoid charging any aircraft flying overhead.
