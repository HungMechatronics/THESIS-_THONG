function [type,time] = crossCollisionCheck(NodeaY,NodeaX,NodebY,NodebX,NodedY,NodedX,t_in,t_out,corruptWindow,time_AGV1_turn,current_type,current_wait)
%% GLOBAL SET-UP & DEFINITION
    % Giai quyet va cham giao lo
    % Node a : past node , b : current Node , c : next node 
    % Case 1 : Va cham nguoc chieu
    global time_window;
    type = current_type;
    time = current_wait;
    % Nhuong cho AGV co duong di quyen uu tien
    time_2_travel_2_roads = 5;
    least_time_collision = 1;
    
%% START CHECKING EACH CASES: 
    for i = 1:size(corruptWindow,1)
    % FIND THE NEXT PATH
    nextRoad = find(time_window(:,1)==corruptWindow(i,3) & time_window(:,2)==corruptWindow(i,4) & time_window(:,3)== corruptWindow(i,8) & time_window(:,4)== corruptWindow(i,9) & time_window(:,5)== corruptWindow(i,5),1);
    timeOutprior = time_window(nextRoad,7);
%     if ~isempty(timeOutprior)==1
%         disp(timeOutprior);
%     end

%% SPECIAL CASES :
%%% IF AGV-2 ( AGV that already plan the journey ) is at the finish point.
% => Chua xet thoi gian dung

%     if corruptWindow(i,8) == corruptWindow(i,3) && corruptWindow(i,9) == corruptWindow(i,4)
%         type = 1;  % set the type to front-corruption.
%         disp('Diem cuoi cung');
%         return;
%     end

%%% IF AGV-2 ( AGV that already plan the journey ) is turning - set a
%%% wait time to 3-5s
    time_AGV2_turn = 0;
    if corruptWindow(i,1)~= corruptWindow(i,8) && corruptWindow(i,2)~= corruptWindow(i,9)
        time_AGV2_turn = 3;
    end
    
%% CASES WHEN: 
%% AGV TRAVEL BUT NOT "f" CASE
    % A2 ~= D1 and D2 ~= A1
    if (corruptWindow(i,1) ~= NodedY || corruptWindow(i,2) ~= NodedX) && ...
       (NodeaY ~= corruptWindow(i,8) || NodeaX ~= corruptWindow(i,9))
        
%%% DIFFERENT DIRECTION AFTER THE INTERSECT  
    % D1 ~= D2 => Khac huong sau va cham
        if (NodedY~= corruptWindow(i,8) || NodedX~= corruptWindow(i,9))  % d1 ~= d2            
            
%             if corruptWindow(i,8) == corruptWindow(i,3) && corruptWindow(i,9) == corruptWindow(i,4)
%                 % Neu AGV2 den dich
%                 type = 1;
%                 disp('Diem cuoi cung');
%                 return;
%             end
    
    % IF there is a slightly collision when crossing the intersect
    % => Wait for AGV_2 to cross first (since AGV_1 is planned after)
            if ( abs(t_out-corruptWindow(i,7)) <= (time_2_travel_2_roads))  
%             if ( abs(t_out-corruptWindow(i,7)) <= (time_2_travel_2_roads))           
                type = 3;
                time = time_2_travel_2_roads;
    % IF there is a turning of one or another AGV
    % => Wait for AGV_2 to turn and cross first( since AGV_1 is planned after)
            elseif ( abs(t_out-corruptWindow(i,7)) <= (time_AGV2_turn+time_2_travel_2_roads)) 
%             elseif ( abs(t_out-corruptWindow(i,7)) <= (time_AGV2_turn+time_2_travel_2_roads)) 
                type = 3;  
                time = time_AGV2_turn + time_2_travel_2_roads;
            end
            
%%% SAME DIRECTION AFTER THE INTERSECT 
    % D1 == D2 => Cung huong sau va cham
        elseif (NodedY==corruptWindow(i,8) && NodedX==corruptWindow(i,9))
            
%            if corruptWindow(i,8) == corruptWindow(i,3) && corruptWindow(i,9) == corruptWindow(i,4)
%                % Neu la diem cuoi cung : b = d
%                type = 1;               
%                disp('Diem cuoi cung');
%                return;
%            end                 
    
    % IF AGV_2 go streight and AGV_1 need to turn 
            if ( abs(t_out-(corruptWindow(i,7))) <= (time_2_travel_2_roads))
%             if ( abs(t_out-(corruptWindow(i,7))) <= (time_2_travel_2_roads))                 
                type = 3; % slow down 
                time = (time_2_travel_2_roads);
                
    % IF AGV_2 need to turn and AGV_1 go streight or turn
            elseif ( abs(t_out-(corruptWindow(i,7))) <= (time_2_travel_2_roads+time_AGV2_turn))
%             elseif ( abs(t_out-(corruptWindow(i,7))) <= (time_2_travel_2_roads+time_AGV2_turn))             
                type = 3; % slow down 
                time = (time_2_travel_2_roads + time_AGV2_turn);
            end
        end
%% AGV TRAVEL "f" CASE       
    else 
%         if corruptWindow(i,8) == corruptWindow(i,3) && corruptWindow(i,9) == corruptWindow(i,4)
%            % Neu la diem cuoi cung : b = d
%            type = 1;               
%            disp('Diem cuoi cung');
%            return;
%         end  

%%% AGV_2 turn into AGV_1 path:
    % A1 == D2 
        if NodeaY == corruptWindow(i,8) && NodeaX == corruptWindow(i,9)
            if(abs(t_out-(corruptWindow(i,7))) <= (time_2_travel_2_roads+time_AGV2_turn))
                type = 1;
                return;
            end               
%%% AGV_1 turn into AGV_2 path
    % D1 == A2 
        elseif NodedY == corruptWindow(i,1) && NodedX == corruptWindow(i,2)
            if(abs(t_out-(corruptWindow(i,7))) <= (time_2_travel_2_roads+time_AGV2_turn+time_AGV1_turn))
%             if(abs(t_out-(corruptWindow(i,7))) <= (time_2_travel_2_roads+time_AGV2_turn+time_AGV1_turn))
               type = 3; % slow down 
               time = time_2_travel_2_roads + time_AGV2_turn + time_AGV1_turn; 
            end
        end
    end        
    end
end