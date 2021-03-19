--[[
1. Checks if the player is within a set distance of the LEZ. If more than this distance, decrease the
frequency of checking the distance to the LEZ.
2. If within a set distance of the LEZ, print a warning message to the player that they are getting close
to the LEZ, and that they may be fined if they enter it. Increase the fequency of checking the player
position.
3. If the player has entered the LEZ, tell the server script that this player has entered.
4. If the player had entered, tell the player they have entered, and display a message telling
them how much they have been fined.
5. Check if the player is still in the LEZ. If they have left, display message telling them they
have left.
]]

function lez_boundary_points(lez_no)
    -- helper function to return LEZ boundary points based on LEZ ID input

    if lez_no == 1 then
        local bndry = {vector3(80.48241, -1012.356, 19.16149),vector3(161.0536, -790.5829, 31.01685),vector3(316.6822, -835.5611, 29.09352),vector3(239.1377, -1068.672, 29.07787)}
        return bndry
    elseif lez_no == 2 then -- same as lez_no = 1 for now
        local bndry = {vector3(80.48241, -1012.356, 19.16149),vector3(161.0536, -790.5829, 31.01685),vector3(316.6822, -835.5611, 29.09352),vector3(239.1377, -1068.672, 29.07787)}
        return bndry
    else
        error("Invalid LEZ number selection")
    end
end

function inside_lez_check(plyr,lez_no)
    --[[Function that checks if a player is inside a specific LEZ.
    Works by tracing a ray in the SW direction from the player and counting the number of
    intersections with the LEZ polygon verteces.]]

    -- Get the relevant boundary points
    local lez_sides = lez_boundary_points(lez_no)

    -- Quick check if player is flying above the LEZ
    if plyr[3] > lez_sides[1][3]+30 then
        return false

    -- Otherwise do the full check
    else
        -- Define the player's pos as point A
        local A = {plyr[1],plyr[2]}

        -- Check in a SW direction (arbitary), defining a point B far from the player
        local B = {plyr[1]-10000,plyr[2]-10000}

        -- Now test each side of the LEZ for an intersection
        local no_sides = #lez_sides

        -- Counter for no interesects between AB and the LEZ boundary
        local no_crossings = 0

        -- Loop over each side
        for i=1,no_sides do

            -- Table index for point D. Wraps around to first point if
            -- required.
            local index = (i)%(no_sides) + 1

            -- Define points C and D as those of the side being examined
            local C = {lez_sides[i][1],lez_sides[i][2]}
            local D = {lez_sides[index][1],lez_sides[index][2]}

            -- Find gradient of AB and CD
            local slope_AB = (A[2]-B[2])/(A[1]-B[1])
            local slope_CD = (C[2]-D[2])/(C[1]-D[1])

            -- Find intersection point between AB and CD, infinite length lines
            local intersect_x = ( (slope_AB*A[1])-(A[2])-(slope_CD*C[1])+(C[2]) )/(slope_AB - slope_CD)--( (slope_AB * A[1]) - A[2]) / ( (C[2] - (slope_CD*C[1])) * (slope_AB - slope_CD) )
            local intersect_y = A[2] + (slope_AB * (intersect_x - A[1]))

            -- Now work out the corners of the smallest possible box between AB and CD line segments 
            -- locate smallest RHS, and largest LHS x coord
            local rhs_1 = math.max(A[1],B[1])
            local rhs_2 = math.max(C[1],D[1])
            local min_rhs_x = math.min(rhs_1,rhs_2)
            local lhs_1 = math.min(A[1],B[1])
            local lhs_2 = math.min(C[1],D[1])
            local max_lhs_x = math.max(lhs_1,lhs_2)

            -- locate smallest top, and largest bottom y coord
            local top_1 = math.max(A[1],B[1])
            local top_2 = math.max(C[1],D[1])
            local min_top_y = math.min(top_1,top_2)
            local bot_1 = math.min(A[2],B[2])
            local bot_2 = math.min(C[2],D[2])
            local max_bot_y = math.max(bot_1,bot_2)

            -- Now check if the intersection points lands inside this box, if so, incrememnt counter by 1
            if ( (intersect_x < min_rhs_x) and (intersect_x > max_lhs_x) and (intersect_y > max_bot_y) and (intersect_y < min_top_y)) then
                no_crossings  = no_crossings + 1
            end

        end

        if (no_crossings % 2 == 0) then
            return false
        else
            return true
        end

    end

end

function is_player_in_lez(plyr,actve)
    -- Takes the player position and a list of active LEZ IDs
    -- Checks if player is in any active LEZ

    -- LEZ the player is in
    local lez = 0

    -- Is the player in an LEZ
    local in_lez = false

    -- Loop over each active LEZ, break if in one (no need to check others)
    for i, lez_id in ipairs(actve)
    do

        in_lez = inside_lez_check(plyr,lez_id)

        -- If player in LEZ, don't bother checking the others
        if in_lez then
            lez = lez_id
            break
        end

    end

    return in_lez, lez

end

function shortest_dist(p,p1,p2)
    --[[Finds shortest distance (squared) between a point, p, and a 
    line segment with end points p1, p2. This is a LUA version of
    https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
    with the mathematics from:
    http://paulbourke.net/geometry/pointlineplane/]]

    -- Get the x and y of each point
    local x = p[1]
    local y = p[2]
    local x1 = p1[1]
    local y1 = p1[2]
    local x2 = p2[1]
    local y2 = p2[2]

    -- Define dummy variables to make maths tidier
    local A = x - x1
    local B = y - y1
    local C = x2 - x1
    local D = y2 - y1

    -- Basically you project the point P onto the infinte line through P1,P2, and calculate what
    -- percentage of the way along P1,2 you are. If < 0, the closest point is P1. If > 1 it is P2,
    -- and if between 0 and 1 the closest point is the intersection with the tangent
    local dot = A * C + B * D
    local l2 = C * C + D * D
    local pcnt = -1
    if l2 ~= 0.0 then
        pcnt = dot / l2
    end

    -- The closest point x and y coords
    local xx = 0
    local yy = 0

    -- Nearest to endpoint p1
    if pcnt < 0 then
        xx = x1
        yy = y2
    -- Nearest to endpoint p2
    elseif pcnt > 1 then
        xx = x2
        yy = y2
    -- Nearest point is on the line segment between p1 and p2
    else
        xx = x1 + pcnt * C
        yy = y1 + pcnt * D
    end

    -- Now that we know where the closest point is, calculat the distance to this point
    local dx = x - xx
    local dy = y - yy
    return dx * dx + dy * dy

end

function find_dist_to_nearest_lez(plyr,actve)
    -- Takes the player position and a list of active LEZ and Finds
    -- the closest LEZ and the distance to it

    -- Nearest LEZ to player
    local lez = 0

    -- Overall shortest distance to any LEZ
    local overall_shortest = 10000000

    -- Overall closest LEZ
    local closest_lez = 0

    -- Loop over each active LEZ
    for i, lez_id in ipairs(actve)
    do
        -- Get the relevant boundary points
        local lez_sides = lez_boundary_points(lez_id)

        -- Get the number of sides to this LEZ
        local no_sides = #lez_sides

        -- Shortest dist from player to this LEZ boundary
        local shortest_dist_to_lez = 10000000

        -- Loop over each side and calculate the shortest dist^2 from player to the side
        for i=1,no_sides
        do
            -- Table index for point p2. Wraps around to first point if required
            local index = (i)%(no_sides) + 1

            -- Define points p1 and p2 as those of the side being examined
            local p1 = {lez_sides[i][1],lez_sides[i][2]}
            local p2 = {lez_sides[index][1],lez_sides[index][2]}

            -- Get shortest ^ 2 dist
            local dist = shortest_dist(plyr,p1,p2)

            if dist < shortest_dist_to_lez then
                shortest_dist_to_lez = dist
            end

        end

        -- Now that we have the shortest distance to this LEZ, compare with the shortest distance to previous LEZ
        if shortest_dist_to_lez < overall_shortest then
            overall_shortest = shortest_dist_to_lez
            closest_lez = lez_id
        end

    end

    -- We now know the nearst LEZ and the square distance to it. Return the ID and the distance
    return closest_lez, math.sqrt(overall_shortest)
end

Citizen.CreateThread(function()

    -- Choose which LEZs you want active
    local active_lez = {1,2}

    -- Distance to nearest LEZ in which proximity warning will be shown (not yet used)
    local lez_warning_dist = 100

    -- Is the player in an LEZ
    local in_lez = false

    -- Which LEZ is the player in? 0 if not in an LEZ
    local lez_id = 0

    -- Check if player has just entered an LEZ
    local just_entered = false

    -- LEZ that the player was last in
    local recent_lez = 0

    -- Bulk of code
    while(true)
    do
        -- Get player position
        local player_ped = GetPlayerPed(-1)
        local player_pos = GetEntityCoords(player_ped)

        -- Check if player is in an LEZ
        in_lez, lez_id = is_player_in_lez(player_pos,active_lez)

        -- If in LEZ
        if in_lez then

            -- Check if player has just entered
            if not just_entered then
                TriggerEvent('chatMessage', '[LEZ]', {255,0,0}, 'You have just entered a LEZ.')

                -- Tell server a player has just enetered this LEZ so they can be charged: TBA

                -- Update that the player has just entered the LEZ. Remains true until the player has left the LEZ
                -- in order to prevent continually telling the server the player is still in the LEZ (pointless communication)
                just_entered = true

                -- Record which LEZ the player has just entered, so that when they leave
                -- this LEZ, the LEZ ID can still be passed to the server
                recent_lez = lez_id
            end

            -- Wait a while (30s) before checking again
            Citizen.Wait(30*1000)

        -- If player not in LEZ, check again after 1s
        else

            -- Check if the player has just left an LEZ.
            -- Ignore if recenet LEZ is 0 i.e. spawned outside an LEZ

            if ( (just_entered) and (recent_lez > 0)) then
                TriggerEvent('chatMessage', '[LEZ]', {255,0,0}, 'You have left the LEZ.')

                -- Tell the server a player has just left the LEZ: TBA

                -- Update that the player has just left the LEZ. Remains false until the player has entered the LEZ
                -- in order to prevent continually telling the server the player is still outside the LEZ (pointless communication)
                just_entered = false

            end

            -- Find the closest LEZ and the distance to it
            local closest_lez
            local dist_to_closest

            closest_lez, dist_to_closest = find_dist_to_nearest_lez(player_pos,active_lez)

            if dist_to_closest < lez_warning_dist then
                TriggerEvent('chatMessage', '[LEZ]', {255,0,0}, 'Warning, you are within less than 100m of LEZ '..tostring(closest_lez)..', you will be charged if you enter.')

                -- Close to an active LEZ, so increase check frequency (5s)
                Citizen.Wait(5*1000)

            else

                TriggerEvent('chatMessage', '[LEZ]', {255,0,0}, 'You are more than 100m from an LEZ.')

                -- Not clsoe to an LEZ, so check after a longer wait (60s)
                Citizen.Wait(60*1000)

            end

        end

    end

end)




-- Define the LEZ boundary

-- legion square LEZ corners
-- sw : (80.48241, -1012.356, 19.16149)
-- nw : (161.0536, -790.5829, 31.01685)
-- ne : (316.6822, -835.5611, 29.09352)
-- se : (239.1377, -1068.672, 29.07787)