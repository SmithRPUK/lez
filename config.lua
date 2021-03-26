Config = {}

-- LEZ 1 boundary points
Config['lez_1_bndry'] = {vector3(80.48241, -1012.356, 19.16149),vector3(161.0536, -790.5829, 31.01685),
vector3(316.6822, -835.5611, 29.09352),vector3(239.1377, -1068.672, 29.07787)}

-- LEZ 2 boundary points (same as 1 for now)
Config['lez_2_bndry'] = {vector3(80.48241, -1012.356, 19.16149),vector3(161.0536, -790.5829, 31.01685),
vector3(316.6822, -835.5611, 29.09352),vector3(239.1377, -1068.672, 29.07787)}

-- Active LEZs. 1 and 2 by default
Config['active_lez'] = {1,2}

-- Distance from an active LEZ (m) that the player will recieve a proximity alert
Config['lez_warning_dist'] = 100.0

-- Time to wait (s) before checking if the player is in an LEZ, if they are already in an LEZ
Config['in_lez_wait_time'] = 30.0

-- Time to wait (s) before checking if the player is in an LEZ, if they are within lez_warning_dist of an active LEZ
Config['near_lez_wait_time'] = 30.0

-- Time to wait (s) before checking if the player is in an LEZ, if they are more than lez_warning_dist of an active LEZ
Config['far_from_lez_wait_time'] = 30.0

-- Time to wait (s) before checking if the player is in a vehicle
Config['in_vehicle_wait_time'] = 30.0
