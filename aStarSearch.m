   function [finalFscore,OptimalPath,obj,road]=aStarSearch(StartX,StartY,GoalX,GoalY,MAP,Connecting_Distance,agvStatus,agvName,lastDir)

global nodeArray nodeArr podStatic agvStatic time_window T agvArray stor;


%% VARIABLES
% Slow down positions
agvArray(agvName,1).slowDownY = [];                                        % waiting position X
agvArray(agvName,1).slowDownX = [];                                        % waiting postion Y
agvArray(agvName,1).timeSlowDown = [];                                     % time to wait
slowDownStorage = [0 0 0];                                                 % [row,column,time_2_wait]
exist = 0;

% 03_05_2023
tempStopArray = [0 0 0 0 0];
t_in_out_coop = [0 0 0 0 0 0];   % [node_in node_out t_in t_out]
% Other variables
finalFscore = 0;
checkWindow = [];
dista = [];

% Clear all time window that contain current AGV status.
clearWindow = find(time_window(:,5) == double(agvName));
if isempty(clearWindow) ~=1
    time_window(clearWindow,:) = [];
end
  

%% PRE-DEFINE VALUES
% Pre-defined some matrices size and values.
[Height,Width]=size(MAP); %Height and width of matrix
GScore=zeros(Height,Width);                                                % Matrix keeping track of G-scores  
Hn=double(zeros(Height,Width));                                            % Matrix keeping track of H-scores 
FScore=double(inf(Height,Width));                                          % Matrix keeping track of F-scores (only open list)
OpenMAT=double(zeros(Height,Width));                                       % Matrix keeping track of Open-list
ClosedMAT=double(zeros(Height,Width));                                     % Matrix keeping track of Close-list
tOUT = double(zeros(Height,Width));
tIN = double(zeros(Height,Width));

tempStop=double(zeros(Height,Width)); 

% When AGV is bring the pods back to WS or vise verse.
% => All the pods is occupied in the close matrice.
if agvStatus == 2 || agvStatus == 4 
    ClosedMAT(podStatic==1) = 1;                                           %Adding object-cells to closed matrix                                      
end

ClosedMAT(agvStatic==1) = 1;                                             % Set all the position of AGV to 1.

% Tracking parents matrices => To extract back route.
ParentX=double(zeros(Height,Width));                                       % Matrix keeping track of X position of parent
ParentY=double(zeros(Height,Width));                                       % Matrix keeping track of Y position of parent

%% Setting up matrices representing neighboors to be investigated
NeighboorCheck = [ 0 1 0; 1 0 1; 0 1 0];
% Find neighbors that can move 
[row, col] = find(NeighboorCheck==1);
% Convert to normal x,y
Neighboors=[row col]-(Connecting_Distance+1)  ; 
N_Neighboors=size(col,1);
    
%% Creating Heuristic-matrix based on distance to nearest  goal node
RegisteredGoals =[GoalX GoalY];
Nodesfound=size(RegisteredGoals,1); % Numbers of Node need to find .

for k=1:size(MAP,1)
    for j=1:size(MAP,2)
        if MAP(k,j) ~= 0
        % Mat is [ x-xc , y-yc ] array 
        Mat=RegisteredGoals-(repmat([j k],(Nodesfound),1));
        % Manhattan distance .
        Distance= sum(abs(Mat));
        Hn(k,j)=Distance/(1.3); % t = s/v
        end
    end
end
%% INITIALIZE START-NODE WITH F-VALUE AND OPEN FIRST NODE
    % F = G + H , H : the distance from current to goal.
    % F(1) = H , G(1) = 0
FScore(StartY,StartX)   = Hn(StartY,StartX);  
OpenMAT(StartY,StartX)  = 1;   
temp_index = 1;

%% CREATE A LOOP TO FIND A-STAR AND DEALING WITH TIME WINDOW.
% IMPORTANT: Code will break when path found or when no path exist
while true 
%%% First find the min F value in the MAP ( always find the cheapest path
    MINopenFSCORE=min(min(FScore)); % find min F
    % Fail condition: If there aren't any min F - all of them is infinite
    % then break the path.
    if MINopenFSCORE==inf
        OptimalPath= inf ;
        RECONSTRUCTPATH=0;  
        break
    end
        
%%% UPDATE CURRENT POSITION X,Y ( WHERE ARE THEY EXAMINING ? )
    [CurrentY,CurrentX]=find(FScore==MINopenFSCORE);
    CurrentY=CurrentY(1);
    CurrentX=CurrentX(1);
    
%%% CHECK IF WE ALREADY REACH THE GOAL -> START RE-CONSTRUCT THE PATH.
    if (CurrentY==GoalY) && (CurrentX==GoalX)
        RECONSTRUCTPATH=1;
        break
    end
    
%%% MOVE NODE FROM OPEN-LIST TO CLOSE-LIST 
    OpenMAT(CurrentY,CurrentX)= 0 ;                                        % We are NOW consider this position.
    FScore(CurrentY,CurrentX)=inf;
    ClosedMAT(CurrentY,CurrentX)=1;
    now =  MAP(CurrentY ,CurrentX);                                       % Node hien tai
    time_2_turn = 0;                                                       % Variable to store time to turn.
    
%% CHECK NEIGHBORS
    intersect_window_1 = [];                                               % empty the collision window
    for p=1:N_Neighboors
        i=Neighboors(p,1);                                                 % Y
        j=Neighboors(p,2);                                                 % X
        corruptType = 0;                                                   % Reset collision type.
        turn_in_first = 0;
        time2wait = 0;
     %%% Boundary condition -> Make sure it is limited by MAP size.
        if CurrentY+i<1||CurrentY+i>Height||CurrentX+j<1||CurrentX+j>Width
            continue
        end
        
    %%% Define some variables
        next = MAP(CurrentY+i,CurrentX+j);                                 % Next Node - on searching
        nextY = CurrentY+i;
        nextX = CurrentX+j;
        pastY = double(ParentY(CurrentY,CurrentX));
        pastX = double(ParentX(CurrentY,CurrentX));
        
    %%% Calculate the time to next Node - travel_time = distance/average_velocity.
        travel_time = (abs(nodeArray(now,1)-nodeArray(next,1))+ abs(nodeArray(now,2)-nodeArray(next,2)))/1300 ; 

%%% Only create previous value when there is.
%%% IS NODEARRAY CORRECT, OR WE HAVE TO USE STOR ? - CORRECT
%%% NodeArr(x,1) = COT HIEN TAI
%%% NodeArr(x,2) = HANG HIEN TAI
%%% TRY TO USE : CORDINATE_X , CORDINATE_Y
    %%% NOTE: The usage of tenp_index might be wrong => NOW turn into NEXT
    %%% ( 27 -04 -2023 );
    %%% various beta to cover => example : -360
%         if temp_index == 1
%             if ( (mod(agvArray(agvName,1).beta,360) == 0) &&...
%                  (agvArray(agvName,1).coordinateX==nodeArr(next,1)) && (agvArray(agvName,1).coordinateY < nodeArr(next,2)) ) ||...
%                ( ((mod(agvArray(agvName,1).beta,360) == 90) || (mod(agvArray(agvName,1).beta,360) == -270)) &&... 
%                  (agvArray(agvName,1).coordinateY==nodeArr(next,2)) && (agvArray(agvName,1).coordinateX < nodeArr(next,1)) ) ||... 
%                ( ((mod(agvArray(agvName,1).beta,360) == -180) || (mod(agvArray(agvName,1).beta,360) == 180)) &&...
%                  (agvArray(agvName,1).coordinateX==nodeArr(next,1)) && (agvArray(agvName,1).coordinateY > nodeArr(next,2)) ) ||...
%                ( ((mod(agvArray(agvName,1).beta,360) == -90) || (mod(agvArray(agvName,1).beta,360) == 270)) &&... 
%                  (agvArray(agvName,1).coordinateY==nodeArr(next,2)) && (agvArray(agvName,1).coordinateX > nodeArr(next,1)))
%                 turn_in_first = 0;
%     %%% TURN 180
%             elseif ( (mod(agvArray(agvName,1).beta,360) == 0) && ...
%                     ( agvArray(agvName,1).coordinateX == nodeArr(next ,1) )&&( agvArray(agvName,1).coordinateY > nodeArr(next,2))) ||...
%                    ( ((mod(agvArray(agvName,1).beta,360) == -180) || (mod(agvArray(agvName,1).beta,360) == 180)) &&...
%                     ( agvArray(agvName,1).coordinateX ==nodeArr(next,1)) && ( agvArray(agvName,1).coordinateY < nodeArr(next,2))) ||...
%                    ( ((mod(agvArray(agvName,1).beta,360) == -90) || (mod(agvArray(agvName,1).beta,360) == 270)) &&...
%                     (agvArray(agvName,1).coordinateY==nodeArr(next,2)) && (agvArray(agvName,1).coordinateX < nodeArr(next,1))) ||...
%                    ( ((mod(agvArray(agvName,1).beta,360) == 90) || (mod(agvArray(agvName,1).beta,360) == -270)) &&... 
%                     (agvArray(agvName,1).coordinateY==nodeArr(next,2)) && (agvArray(agvName,1).coordinateX > nodeArr(next,1)))
%                 turn_in_first = 6;
%             else
%                 turn_in_first = 3;
%             end
           
    %%% ( 14 -05 -2023 );
    %%% various beta to cover => example : -360
        if temp_index == 1
            if ( (lastDir == 'N' || isempty(lastDir)) &&...
                 (agvArray(agvName,1).coordinateX==nodeArr(next,1)) && (agvArray(agvName,1).coordinateY < nodeArr(next,2)) ) ||...
               ( (lastDir == 'E') &&... 
                 (agvArray(agvName,1).coordinateY==nodeArr(next,2)) && (agvArray(agvName,1).coordinateX < nodeArr(next,1)) ) ||... 
               ( (lastDir == 'S') &&...
                 (agvArray(agvName,1).coordinateX==nodeArr(next,1)) && (agvArray(agvName,1).coordinateY > nodeArr(next,2)) ) ||...
               ( (lastDir == 'W') &&... 
                 (agvArray(agvName,1).coordinateY==nodeArr(next,2)) && (agvArray(agvName,1).coordinateX > nodeArr(next,1)))
                turn_in_first = 0;
    %%% TURN 180
            elseif ( (lastDir == 'N' || isempty(lastDir)) && ...
                    ( agvArray(agvName,1).coordinateX == nodeArr(next ,1) )&&( agvArray(agvName,1).coordinateY > nodeArr(next,2))) ||...
                   ( (lastDir == 'S') &&...
                    ( agvArray(agvName,1).coordinateX ==nodeArr(next,1)) && ( agvArray(agvName,1).coordinateY < nodeArr(next,2))) ||...
                   ( (lastDir == 'W') &&...
                    (agvArray(agvName,1).coordinateY==nodeArr(next,2)) && (agvArray(agvName,1).coordinateX < nodeArr(next,1))) ||...
                   ( (lastDir == 'E') &&... 
                    (agvArray(agvName,1).coordinateY==nodeArr(next,2)) && (agvArray(agvName,1).coordinateX > nodeArr(next,1)))
                turn_in_first = 6;
            else
                turn_in_first = 3;
            end
            
%             disp('With AGV:'); disp(agvArray(agvName,1).agvName);
%             disp('Angle:');disp((mod(agvArray(agvName,1).beta,360)));
%             disp('And: ');  disp(agvArray(agvName,1).coordinateY); disp(nodeArr(next,2));
%             disp('And: ');  disp(agvArray(agvName,1).coordinateX); disp(nodeArr(next,1));
%             disp('We have: '); disp(turn_in_first);
        elseif temp_index >= 2                                                 
            past = MAP(ParentY(CurrentY,CurrentX),ParentX(CurrentY,CurrentX));
            
        %%% Check if there is a turning point => another AGV have to wait for turning point.
            if( ( (nodeArr(now,1) == nodeArr(next,1)) && (nodeArr(next,1) == nodeArr(past,1)) ) ||...
                ( (nodeArr(now,2) == nodeArr(next,2)) && (nodeArr(next,2) == nodeArr(past,2)) ))
                time_2_turn = 0;
            else                  
                time_2_turn = 3;
            end
            
    %%% INTERSECTION COLLISION CHECK 
         
        %%% INTERSECTION CASE:
            % old: check window_3
              % 1. A1 ~= A2
              % 2. B1 == B2
%             intersect_window_1 = find((time_window(:,3) == double(CurrentY) & time_window(:,4) == double(CurrentX)) & (time_window(:,1) ~= double(ParentY(CurrentY,CurrentX)) | time_window(:,2)~=double(ParentX(CurrentY,CurrentX)))); 
            intersect_window_1 = find((time_window(:,1) ~= double(pastY) | time_window(:,2) ~= double(pastX)) & ...
                                (time_window(:,3) == double(CurrentY)    & time_window(:,4) == double(CurrentX))) ; 
            % old: check window_9
%             intersect_window_2 = find(time_window(:,3) == double(CurrentY+i) & time_window(:,4) == double(CurrentX+j) & time_window(:,1) ~= double(CurrentY) | time_window(:,2) ~= double(CurrentX));
%             intersect_window_2 = find(time_window(:,3) == double(CurrentY+i) & time_window(:,4) == double(CurrentX+j) & ...
%                                  time_window(:,1) ~= double(CurrentY) | time_window(:,2) ~= double(CurrentX));
        end 
        
    %%% GET TIME IN AND TIME OUT of currentAGV IF they go in this way. 
        % T_in change when checking each neighbor => T_in show is the last
        % one.
%         t_in  = T + GScore(CurrentY,CurrentX) + turn_in_first;
%         t_out = T + GScore(CurrentY,CurrentX) + turn_in_first + travel_time + time_2_turn ;
%         t_out_cross = t_in;
        
        % 19/05/2023
        t_in  = T + GScore(CurrentY,CurrentX) + turn_in_first + time_2_turn;
        t_out = t_in + travel_time ;

    %%% FIND AGV THAT TRAVELS THE SAME ROAD.
        % old: checkWindow_1,_2 are same road sign
        % A1 = A2 && B1 = B2
        sameroad_window_1 = find(time_window(:,1) == double(CurrentY) & time_window(:,2) == double(CurrentX) & time_window(:,3) == double(nextY) & time_window(:,4) == double(nextX)); 
        % A1 = B2 && B1 = A2
        sameroad_window_2 = find(time_window(:,3) == double(CurrentY) & time_window(:,4) == double(CurrentX) & time_window(:,1) == double(nextY) & time_window(:,2) == double(nextX)); 

    %%% FIND POSITION THAT AGV WILL STOP OR TURN
        % old: checkWindow_7 is stop sign
        % B1 == B2 && B1 == D2
        stop_window_1  = find(time_window(:,3) == double(nextY) & time_window(:,4) == double(nextX) & time_window(:,8) == double(nextY) & time_window(:,9) == double(nextX)); 

%% TYPE OF COLLISION:
    %   TYPE 1: Head-2-head collision .
    %   TYPE 2: NOT DEFINE YET.
    %   TYPE 3: AGV stop/turn collision ( at WS ).
    %% / CHECK FOR HEAD-TO-HEAD COLLISION !!
    if corruptType~=1
    if ( ~isempty(sameroad_window_2)==1 )
        head_2_head_frame = sameroad_window_2;
%             head_2_head_frame  = cat(1,sameroad_window_1,sameroad_window_2);
        head_2_head_Window = time_window(head_2_head_frame,:);         % Sort out the time_window.
        corruptType = frontCorruptCheck(head_2_head_Window,t_in,t_out,CurrentY,CurrentX,CurrentY+i,CurrentX+j,time_2_turn,corruptType);
    end
    end
        
    %% / CHECK FOR STOP/TURN COLLISION FIRST !!
        if corruptType~=1
        if ~isempty(stop_window_1) == 1
           stopWindow = time_window(stop_window_1,:); 
           [corruptType,time2wait] = stopCorruptCheck(t_in,t_out,stopWindow,corruptType,time2wait);
        end
        end
%     %% / CHECK FOR INTERSECTION COLLISION !! 
%         if corruptType~=1
%         if ~isempty(intersect_window_1) == 1
%             cross_Window = time_window(intersect_window_1,:);
%             % New edit 15-05-2023
% %             [corruptType,time2wait] = crossCollisionCheck(pastY,pastX,CurrentY,CurrentX,nextY,nextX,t_in,t_out,cross_Window,time_2_turn,corruptType,time2wait);
%             [corruptType,time2wait] = crossCollisionCheck(pastY,pastX,CurrentY,CurrentX,nextY,nextX,t_in,t_in,cross_Window,time_2_turn,corruptType,time2wait);
%         end 
%         end
    %% / CHECK FOR CHASING COLLISION !!
        if corruptType~=1
        if ~isempty(sameroad_window_1) == 1
            chaseWindow = time_window(sameroad_window_1,:);
            [corruptType,time2wait] = chaseCorruptCheck(CurrentY,CurrentX,CurrentY+i,CurrentX+j,t_in,t_out,chaseWindow,time_2_turn,corruptType,time2wait);
        end
        end
        %% / CHECK FOR INTERSECTION COLLISION !! 
        if corruptType~=1
        if ~isempty(intersect_window_1) == 1
            cross_Window = time_window(intersect_window_1,:);
            % New edit 15-05-2023
%             [corruptType,time2wait] = crossCollisionCheck(pastY,pastX,CurrentY,CurrentX,nextY,nextX,t_in,t_out,cross_Window,time_2_turn,corruptType,time2wait);
            [corruptType,time2wait] = crossCollisionCheck(pastY,pastX,CurrentY,CurrentX,nextY,nextX,t_in,t_in,cross_Window,time_2_turn,corruptType,time2wait);
        end 
        end
%     %% / CHECK FOR HEAD-TO-HEAD COLLISION !!
%         if corruptType~=1
%         if ( ~isempty(sameroad_window_2)==1 )
%             head_2_head_frame = sameroad_window_2;
% %             head_2_head_frame  = cat(1,sameroad_window_1,sameroad_window_2);
%             head_2_head_Window = time_window(head_2_head_frame,:);         % Sort out the time_window.
%             corruptType = frontCorruptCheck(head_2_head_Window,t_in,t_out,CurrentY,CurrentX,CurrentY+i,CurrentX+j,time_2_turn,corruptType);
%         end
%         end
    %% / Update t_out for waiting case
%       t_out = t_out + time2wait;

    % 19/05/2023
        t_in = t_in + time2wait;
        t_out = t_in + travel_time;

%% ACTIONS AFTER DEFINE THE COLLISION TYPE:   
%         if corruptType ~= 0
%             disp(corruptType);
%         end
        if corruptType == 1
%             GScore(CurrentY,CurrentX) = 10000;
            tentative_gScore = inf; %21/05/2023
%             tentative_gScore = 10000;
            ClosedMAT(CurrentY+i,CurrentX+j) = 1;
        elseif corruptType == 2
            tentative_gScore = inf; %21/05/2023
%             tentative_gScore = 10000;
            ClosedMAT(CurrentY+i,CurrentX+j) = 1;
        elseif corruptType == 3
            tentative_gScore = GScore(CurrentY,CurrentX) + travel_time + time_2_turn + turn_in_first + time2wait;
        else
            tentative_gScore = GScore(CurrentY,CurrentX) + travel_time + time_2_turn + turn_in_first;             
        end
        
        Flag=1;
        
%% AFTER SOLVING THE COLLISION - START CALCULATING SCORE !!
        if(ClosedMAT(CurrentY+i,CurrentX+j)==0) %Neiboor is open             
            if Flag==1                                

                % Put free neighbors on the OpenList
                if OpenMAT(CurrentY+i,CurrentX+j)==0
                   OpenMAT(CurrentY+i,CurrentX+j)=1;  
                   
                % Check for the min gScore of neighbors 
                elseif tentative_gScore >= GScore(CurrentY+i,CurrentX+j)
                    continue                                    
                end
                
                if (corruptType == 3)

                    
                    if exist == 0
                        
%                         stopPosition = [double(ParentY(CurrentY,CurrentX)) double(ParentX(CurrentY,CurrentX)) double(CurrentY) double(CurrentX) time2wait];
                        stopPosition = [double(CurrentY) double(CurrentX) double(CurrentY+i) double(CurrentX+j) time2wait];
                        tempStopArray = cat(1,tempStopArray,stopPosition);
                    end
                end    
                
%                 agvArray(agvName,1).totalDistance =  agvArray(agvName,1).totalDistance + travel_time;
                ParentX(CurrentY+i,CurrentX+j)=CurrentX;
                ParentY(CurrentY+i,CurrentX+j)=CurrentY;               
                tIN(CurrentY,CurrentX) = t_in;
                tOUT(CurrentY+i,CurrentX+j) = t_out;
                % new code 19/05/2023
                temp_coop = [CurrentY,CurrentX,CurrentY+i,CurrentX+j,t_in,t_out];
                t_in_out_coop = cat(1,t_in_out_coop,temp_coop);
                
%                 tOUT(CurrentY,CurrentX) = t_out; 
                GScore(CurrentY+i,CurrentX+j) = tentative_gScore;
                FScore(CurrentY+i,CurrentX+j)= tentative_gScore + Hn(CurrentY+i,CurrentX+j); % final fScore 
            end
            
%%% IF NEIGHBOR IS NOT OPEN:
        elseif (ClosedMAT(CurrentY+i,CurrentX+j)==1)
            if GScore(CurrentY+i,CurrentX+j) > tentative_gScore
               ClosedMAT(CurrentY+i,CurrentX+j) = 0;
               OpenMAT(CurrentY+i,CurrentX+j) = 1;
            end
        end        
    end         
    temp_index = temp_index +1;
end

%% RE-CREATE THE SHORTEST PATH ( BY EXTRACTING BACK THE PARENT )
k=2;
if RECONSTRUCTPATH
    OptimalPath(1,:)=[CurrentY CurrentX];
    while RECONSTRUCTPATH    
%%% RE-CONSTRUCT from the last node to the first node.
    if (((CurrentX== StartX)) &&(CurrentY==StartY))
        break      
    else
    % Dummy value 
    CurrentY1 = CurrentY;
    CurrentX1 = CurrentX;
    % Get past value
    CurrentXDummy=ParentX(CurrentY,CurrentX);
    CurrentY=ParentY(CurrentY,CurrentX);
    CurrentX=CurrentXDummy;
    OptimalPath(k,:)=[CurrentY CurrentX];
%%% CHECK THIS TEMP_WINDOW
    % 19/05/2023
    trace_back = find(t_in_out_coop(:,1)==CurrentY  & t_in_out_coop(:,2)==CurrentX &...
                      t_in_out_coop(:,3)==CurrentY1 & t_in_out_coop(:,4)==CurrentX1);
    trace_back_01 = find(t_in_out_coop(:,1)==ParentY(CurrentY,CurrentX)  & t_in_out_coop(:,2)==ParentX(CurrentY,CurrentX) &...
                      t_in_out_coop(:,3)==CurrentY & t_in_out_coop(:,4)==CurrentX);
                  
    % bull shit things on 19/05/2023
    if t_in_out_coop(trace_back,5) ~= t_in_out_coop(trace_back_01,6)
        t_in_out_coop(trace_back_01,6) = t_in_out_coop(trace_back,5);
    end
    
    if k == 2
        % 23/05/2023
        if agvArray(agvName,1).currentMission == 1 || agvArray(agvName,1).currentMission == 4
            time_at_end = 3;
        elseif agvArray(agvName,1).currentMission == 2
            time_at_end = 5;
        end
        % add a tolerance for lifting pods around 5 seconds
        temp_window =[ OptimalPath(k,1),OptimalPath(k,2),OptimalPath(k-1,1),OptimalPath(k-1,2),agvName,t_in_out_coop(trace_back,5),t_in_out_coop(trace_back,6)+time_at_end ,OptimalPath(k-1,1),OptimalPath(k-1,2),agvStatus];
%         temp_window =[ OptimalPath(k,1),OptimalPath(k,2),OptimalPath(k-1,1),OptimalPath(k-1,2),agvName,tIN(CurrentY,CurrentX),tOUT(CurrentY1,CurrentX1)+5,OptimalPath(k-1,1),OptimalPath(k-1,2),agvStatus];
    else
        temp_window =[ OptimalPath(k,1),OptimalPath(k,2),OptimalPath(k-1,1),OptimalPath(k-1,2),agvName,t_in_out_coop(trace_back,5),t_in_out_coop(trace_back,6),OptimalPath(k-2,1),OptimalPath(k-2,2),agvStatus];
%         temp_window =[ OptimalPath(k,1),OptimalPath(k,2),OptimalPath(k-1,1),OptimalPath(k-1,2),agvName,tIN(CurrentY,CurrentX),tOUT(CurrentY1,CurrentX1),OptimalPath(k-2,1),OptimalPath(k-2,2),agvStatus];
    end
        
    time_window = cat(1,time_window,temp_window); 
    now = MAP(OptimalPath(k,1),OptimalPath(k,2));
    next = MAP(OptimalPath(k-1,1),OptimalPath(k-1,2));
    % Add in first
%     dista = abs(nodeArray(now,1)-nodeArray(next,1)) + abs(nodeArray(now,2)-nodeArray(next,2));
%     agvArray(agvName,1).totalDistance =  agvArray(agvName,1).totalDistance + dista/1000;
    % Add in later
    dista(k-1) = (abs(nodeArray(now,1)-nodeArray(next,1)) + abs(nodeArray(now,2)-nodeArray(next,2)))/1000;
    % Update all the parent path.
    k=k+1;
    
%%% 15/04/2023
%     if tempStop(CurrentY1,CurrentX1) > 0
%         temp = [CurrentY1,CurrentX1,tempStop(CurrentY1,CurrentX1)];
%         slowDownStorage = cat(1,slowDownStorage,temp);
%     end
%     

%%% 13/05/2023
%     disp(CurrentY);disp(CurrentX);
%     disp(CurrentY1);disp(CurrentX1); 
    % Find if there is a stopping point.
    isStoping = find( tempStopArray(:,1) == double(CurrentY) & tempStopArray(:,2) == double(CurrentX) &...
                tempStopArray(:,3) == double(CurrentY1) & tempStopArray(:,4) == double(CurrentX1));
    
    if ~isempty(isStoping) == 1
        % 19/05/2023 -> Check again.
        disp(tempStopArray)
        disp(tempStopArray(isStoping,:))
        temp = [CurrentY,CurrentX,max(tempStopArray(isStoping,5))];
%         temp = [CurrentY1,CurrentX1,max(tempStopArray(isStoping,5))];
        slowDownStorage = cat(1,slowDownStorage,temp);
        isStoping = [];
    end 
    end 
    end
end

% slowDownStorage
% OptimalPath
% disp(OptimalPath);
if OptimalPath ~= double(inf(1,1))
    if ~isempty(slowDownStorage) == 1    
        for i = 1:size(slowDownStorage,1)
            temp2 = find(OptimalPath(:,1) == slowDownStorage(i,1) &  OptimalPath(:,2) == slowDownStorage(i,2));
        %         temp2
            if ~isempty(temp2) == 1
                agvArray(agvName,1).slowDownY = cat(1,agvArray(agvName,1).slowDownY,OptimalPath(temp2,1));
                agvArray(agvName,1).slowDownX = cat(1,agvArray(agvName,1).slowDownX,OptimalPath(temp2,2));
                agvArray(agvName,1).timeSlowDown = cat(1,agvArray(agvName,1).timeSlowDown,slowDownStorage(i,3));
        %             break;
            end
        end       
    end
end
disp(agvArray(agvName,1).slowDownY);
disp(agvArray(agvName,1).slowDownX);
disp(agvArray(agvName,1).timeSlowDown);

obj = agvArray(agvName,1);
% finalFscore = FScore(OptimalPath(1,1),OptimalPath(1,2));
if ~isempty(checkWindow)
    finalFscore = checkWindow;
end
% disp(finalFscore);
road = dista ;
% dista
end
