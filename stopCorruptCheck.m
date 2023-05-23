function [type,time] = stopCorruptCheck (t_in,t_out,corruptWindow,current_type,current_wait)
    % corruptWindow: input data of current road A->B.
    % t_in: the time to enter the road.
    %% CREATE SOME DEFAULT TYPE.
    collision_type  = current_type;
    waiting_time    = current_wait; 
    time_2_take_goods = 5;
    time_2_travel_2_roads = 2.5;
    %% CHECK ALL WINDOWS THAT HAVE AGV THAT STOP.
    for i = 1:size(corruptWindow,1)
        % If current AGV enter the ROAD after AGV on time_window
        % BUT it would get out of the ROAD before AGV on time_window
        if abs(t_out-corruptWindow(i,7)) <= (time_2_travel_2_roads + time_2_take_goods)
           collision_type = 3;                                             % Collision type: 3 - stop to wait at WS.                                                       
%            waiting_time = time_2_travel_2_roads + time_2_take_goods + abs(t_in-corruptWindow(i,6));       % Add time to wait.
           waiting_time = time_2_take_goods + abs(t_in-corruptWindow(i,6));       % Add time to wait. 
        end
    end
    
    %% RETURN THE TYPE AND TIME TO WAIT.
    time = waiting_time;
    type = collision_type;
end