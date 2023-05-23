 function [type,time] = chaseCorruptCheck(NodebY,NodebX,NodedY,NodedX,t_in,t_out,corruptWindow,time_AGV1_turn,current_type,current_wait)
    % Check if current AGV is going behind any other AGV.
corruptType = current_type;
waitingTime = current_wait;
time_2_travel_2_roads = 2.5;
least_time_collision = 1.5;                                                % Chasing should be short.

for i = 1: size(corruptWindow,1)
    %%% IF AGV-2 ( AGV that already plan the journey ) is turning - set a
    %%% wait time to 3-5s
    time_AGV2_turn = 0;
    if corruptWindow(i,1)~= corruptWindow(i,8) && corruptWindow(i,2)~= corruptWindow(i,9)
        time_AGV2_turn = 3;
    end
    %%% IF AGV_1 IS CHASING AGV_02
    if t_in >= corruptWindow(i,6)
%         if abs(t_out-corruptWindow(i,7)) <= least_time_collision
%             corruptType = 1;
%             corruptType = 3;
%             waitingTime = time_2_travel_2_roads;

        if abs(t_in-corruptWindow(i,6)) <= least_time_collision + time_AGV2_turn               % 21/05/2023
%         if abs(t_out-corruptWindow(i,7)) <= least_time_collision + time_AGV2_turn
            corruptType = 3;
            waitingTime = time_2_travel_2_roads + time_AGV2_turn;
        end
    %%% IF AGV_2 IS CHASING AGV_1:
    else
        if abs(t_in-corruptWindow(i,6)) <= least_time_collision + time_AGV1_turn
%         if abs(t_out-corruptWindow(i,7)) <= least_time_collision + time_AGV1_turn
            corruptType = 1;
        end
    end
end

%% END FUNCTION:
type = corruptType;
time = waitingTime;
end