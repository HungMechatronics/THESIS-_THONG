function [type,time] = stopCorruptCheck (t_in,inputWindow)
    % inputWindow: input data of current road A->B.
    % t_in: the time to enter the road.
    %% CREATE SOME DEFAULT TYPE.
    collision_type  = 0;
    waiting_time    = 0; 
    
    %% CHECK ALL WINDOWS THAT HAVE AGV THAT STOP.
    for i = 1:size(inputWindow,1)
        % If current AGV enter the ROAD after AGV on time_window
        % BUT it would get out of the ROAD before AGV on time_window
        if t_in >= inputWindow(i,6) && t_in <= inputWindow(i,7)
           collision_type = 3;                                             % Collision type: 3 - stop to wait at WS.                                                       
           waiting_time = inputWindow(i,7) - t_in;                         % Add time to wait. 
           disp('Collision type: STOP!');
        end
    end
    
    %% RETURN THE TYPE AND TIME TO WAIT.
    time = waiting_time;
    type = collision_type;
end