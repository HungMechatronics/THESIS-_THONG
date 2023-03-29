classdef agvClass 
% Using OOP to optimize the usage
    %% COMMON VARIABLES
    properties
        % PROPERTIES DEFINE IN ROW & COLUMN MEASUREMENT
        positionX  % col        
        positionY  % row
        goalX % col
        goalY % row
        
        % PROPERTIES FOR AGV BASIC INFORMATION
        beta
        velocity = 1300;        
        agvName
        wsName
        colorface
        
        % PROPERTIES IN mm
        coordinateX
        coordinateY
        wsStaReturnX = 0;
        wsStaReturnY = 0;
        slowDownY 
        slowDownX
        slowInlineX
        slowInlineY
        
        % FLAG 
        rotFlag = 0;
        findPathFlag = 1;
        manualFlag = 0;
        currentMission = 0;
        currentRoad  = 1 ; % The road on total journey
        waitingFlag = 0;
        inlineFlag % remove in the future
        tempIndex = 0;
        
        % PROPERTIES IN s-second ( TIME )
        timeSlowDown
        timeSlowDownIL
        freeTime = 0;
        waitingTime = 0 ;
        noneWorkingTime
        
        % OUTPUT RESULT PROPERTIES
        finalScore
        totalDistance = 0;
        
        % GOODS MANAGING
        goodHolding = 0;
        Agoods = 0;
        Bgoods = 0;
        Cgoods = 0;
        Dgoods = 0;
        
    end
    %% FIXED PROPERTIES OF AGV ( LENGTH - WIDTH )
    properties 
        l=1000 ;
        w=800; 
        h = sqrt(1000^2+800^2)/2;
        alp = acosd(800/sqrt(800^2+1000^2)); 
    end
    %% ARRAY PROPERTIES FOR UPDATE AGV
    properties
       rot = [];
       direc = 'N';
       goal = [];
       goalLine;
       distanceCost = [];
       deleteOrdLine = []
    end
    
    methods
%% CONSTRUCT METHOD
        function obj = agvClass(positionX,positionY,beta,agvName)
            % input start node & angle
            obj.positionX = positionX; % col
            obj.positionY = positionY; % row
            obj.beta = beta;
            obj.agvName = agvName;
        end
%% GET CURRENT PATH USING A* ALGORITHM       
        function obj = getcurrentPath(obj,goalX,goalY,fig)
        global stor nodeArray ;
        global podStatic podStatus podShow emptyPod
        lastDir = obj.direc(end);            
        x = obj.positionX;
        y = obj.positionY;
        x1 = goalX; % col
        y1 = goalY; % row
        centX = obj.coordinateX;
        centY = obj.coordinateY;
        
        % IF AGV IS ON THE "GET POD" MISSION
        % IF AGV ALREADY HIT THE GOAL
        % THEN: empty the position of pod
        %       set current mission to "RETURN POD TO WORKSTATION
        if x == x1 && y == y1 && obj.currentMission == 1
            podStatic(goalY,goalX) = 0;           
            [goalPod(1,2),goalPod(1,1)] = convNode2Pod([goalY,goalX]);
            a = find(podStatus(:,1) == goalPod(1,2) & podStatus(:,2) == goalPod(1,1),1);
            podStatus(a,7) = 0;   
            obj.currentMission = 2;
            obj.goalX = obj.wsStaReturnX;                                  
            obj.goalY = obj.wsStaReturnY;  
            obj.findPathFlag = 1;
            obj.waitingTime = 3;

            % Visible pod has been taken 
            setpod = find(podShow(:,3)==0,1);
            podShow(setpod,3) = 1;
            podShow(setpod,1) = centX; podShow(setpod,2) = centY;
            h2 = sqrt(1000^2+1000^2)/2;
            x = [ (centX+h2*cosd(45));centX+h2*cosd(180-(45));
            centX+h2*cosd(180+(45));centX+h2*cosd(-(45))];
            y = [ (centY+h2*sind(45));centY+h2*sind(180-(45));
            centY+h2*sind(180+(45));centY+h2*sind(-(45))];
            vertex = [x(1,1) y(1,1);x(2,1) y(2,1);x(3,1) y(3,1);x(4,1) y(4,1)];
            face = [1 2 3 4];
            set(emptyPod(setpod,1),'faces',face,'vertices',vertex,'FaceColor',[0.75 0.75 0.75]); 
            emptyPod(setpod,1).Visible = 'on';
        else    
            [finalFscore,finalGoal,obj,distCost] = aStarSearch(x,y,x1,y1,stor,1,obj.currentMission,obj.agvName);
            % row,col -> x,y
            obj.distanceCost = distCost;
            obj.finalScore = finalFscore;
            
        if(finalGoal(1,1) ~= double(inf(1,1)))
            for i = 1:size(finalGoal,1)
                sGoal_ = stor(finalGoal(i,1),finalGoal(i,2));
                tempgoal(size(finalGoal,1)-i+1,:) = [nodeArray(sGoal_,1),nodeArray(sGoal_,2)];
            end                           
            
            %   Display line in axes_wh         
            obj.goalLine = line(fig,tempgoal(:,1),tempgoal(:,2),'LineWidth',3,'Color','r');                      
            obj.coordinateX = double(tempgoal(1,1));
            obj.coordinateY = double(tempgoal(1,2));
            goalLine_ = obj.goalLine ;
            
            switch obj.agvName
                case 1 
                    color = 'r';
                case 2
                    color = 'g';
                case 3 
                    color = 'b';
                case 4 
                    color = 'c';                
                case 5 
                    color = 'm';      
                case 6 
                    color = 'k';                       
                case 7 
                    color = 'w';                   
                case 8
                    color = [0.9290 0.6940 0.1250];
                case 9
                    color = [0.4940 0.1840 0.5560];
                case 10
                    color = [0.4660 0.6740 0.1880];
                case 11
                    color = [0 0.4470 0.7410];
                case 12
                    color = [0.6350 0.0780 0.1840];
                case 13
                    color = [0.8500 0.3250 0.0980];                                        
                otherwise
                    color = 'y';
            end
            goalLine_.Color = color;
            char direct = [];

            for i = 1:size(tempgoal,1)-1
                if(tempgoal(i+1,1) > tempgoal(i,1))
                    direct(i) ='E'; % wrong direction :))
                elseif(tempgoal(i+1,2)> tempgoal(i,2))
                    direct(i) ='N';
                elseif(tempgoal(i+1,1) < tempgoal(i,1))
                    direct(i) ='W';
                elseif(tempgoal(i+1,2)< tempgoal(i,2))
                    direct(i) ='S';
                end
            end 
            
%             if direct(1)=='W' || direct(1) =='E'
%                 beta1 = 90;
%             else
%                 beta1 = 0; 
%             end
%             rota(1,:) = [0 0];

            if (lastDir-direct(1)) == 9 || (lastDir-direct(1)) == -4 || (lastDir-direct(1)) == -14
                rota(1,:) = [1 90];
            elseif (lastDir-direct(1)) == -9 || (lastDir-direct(1)) == 4 || (lastDir-direct(1)) == 14
                rota(1,:) = [1 -90];
            elseif abs(lastDir-direct(1)) == 5 || abs(lastDir-direct(1)) == 18
                rota(1,:) = [1 -180];                
            else
                rota(1,:) = [0 0];
            end
                          
            % Find rotation function 
            for i = 2: size(direct,2)
                if (direct(i-1)-direct(i)) == 9 || (direct(i-1)-direct(i)) == -4 || (direct(i-1)-direct(i)) == -14
                    rota(i,:) = [1 -90];
                elseif (direct(i-1)-direct(i)) == -9 || (direct(i-1)-direct(i)) == 4 || (direct(i-1)-direct(i)) == 14
                    rota(i,:) = [1 90];
                elseif abs(direct(i-1)-direct(i)) == 5 || abs(direct(i-1)-direct(i)) == 18
                    rota(i,:) = [1 -180];
                else
                    rota(i,:) = [0 0];
                end
            end 
            
%             obj.beta = beta1;
            obj.rot = rota;
            obj.direc = direct;
            obj.goal = tempgoal; 
            obj.goalX = x1;
            obj.goalY = y1;
            obj.findPathFlag = 0; 
        else
            obj.waitingTime = 5;
            obj.findPathFlag = 1;
        end
        end
    end
%% UPDATE AGV        
    function obj = updateAGV(obj,t_stamp,agvPatch,fig)
%%%%%% IF THERE IS NOT PATH FINDING
       if obj.findPathFlag ==1  
            obj = getcurrentPath(obj,obj.goalX ,obj.goalY,fig);                    
       end   

       global podStatic podStatus nodeArray stor time_window wsStatus T agvArray emptyPod podShow manualFrame totalgood;
       global lineOfWS1 lineOfWS2 lineOfWS3 lineOfWS4 lineOfWS5 wsOrdLine
       centX = obj.coordinateX;
       centY = obj.coordinateY;
       beta1 = obj.beta;
       direct = obj.direc;
       curRoad = obj.currentRoad;
       goal_ = obj.goal;
       rota = obj.rot;
       temp = obj.tempIndex;
       alp1 = obj.alp;
       h1 = obj.h;
       k = agvPatch;
       v = obj.velocity;
       nextNodeFlag = 0;
       Mission = obj.currentMission;
       wsX = obj.wsStaReturnX;
       wsY = obj.wsStaReturnY;
               
%%%%%% IF AGV CURRENT IN THE LINE
      if obj.inlineFlag == 1
          if( goal_(curRoad,1)==obj.slowInlineX && goal_(curRoad,2)==obj.slowInlineY )
              obj.waitingTime = obj.timeSlowDownIL;
              obj.inlineFlag = 0;
              obj.slowInlineX = [];
              obj.slowInlineY = [];
          end
      end
               
               
%%%%%%% FIND SLOW DOWN POSITION
      if obj.waitingTime == 0
        if (~isempty(obj.timeSlowDown) == 1 && ~isempty(obj.slowDownY) == 1)
           if( goal_(curRoad+1,1)==nodeArray(stor(obj.slowDownY(end,1),obj.slowDownX(end,1)),1) && goal_(curRoad+1,2)==nodeArray(stor(obj.slowDownY(end,1),obj.slowDownX(end,1)),2))
               obj.waitingTime = obj.timeSlowDown(end,1);
               obj.waitingFlag = 1;
           end
        end
      end

%%%%%%% AGV IS CURRENT IN THE MISSION
    if obj.currentMission ~= 0                                             % AGV is doing a TASK.
       % CHECK IF AGV IS IN THE LOAD-OUT POSITION -> WAITING
        if obj.waitingFlag == 1
%             if Mission == 3 && curRoad == 3 
            if Mission == 3 && curRoad == 1 
                if obj.wsName == 1 || obj.wsName == 2 || obj.wsName == 3
%                 obj.waitingTime = 1 + (obj.goodHolding-1)*8; 
                obj.waitingTime = 2; 
                else
%                 obj.waitingTime = 1 + (obj.goodHolding-1)*8; 
                obj.waitingTime = 2; 
                end
                obj.waitingFlag = 0;
            end
        end

%% IN CASE AGV IS NOT IN A WAITING SITUATION
        if obj.waitingTime == 0                                            % Not at waiting positions.
%%%%%%%% AGV LINEAR MOVEMENT - UPDATE AGV EACH 0.1S BASED ON THE DIRECTIONS [N,W,S,E]
            if rota(curRoad,1) ~= 1                                        % AGV not in the rotation place.
              if Mission ~=3   % only check the goal 
                if( direct(curRoad) == 'N')
                    centY = centY + v*t_stamp;
                    if centY >= goal_(curRoad+1,2)+20
                        nextNodeFlag = 1;
                        centY = goal_(curRoad+1,2); % added code
                        % Add distance 
                        obj.totalDistance = obj.totalDistance + obj.distanceCost(curRoad);
                    end
                    
                elseif( direct(curRoad) == 'S')
                    centY = centY - v*t_stamp;
                    if centY <= goal_(curRoad+1,2) - 20
                        nextNodeFlag = 1;
                        centY = goal_(curRoad+1,2); 
                        % Add distance 
                        obj.totalDistance = obj.totalDistance + obj.distanceCost(curRoad);
                    end
                    
                elseif( direct(curRoad) == 'E')
                    centX = centX + v*t_stamp;
                    if centX >= goal_(curRoad+1,1) + 20
                        nextNodeFlag = 1;
                        centX = goal_(curRoad+1,1); % added code
                        % Add distance 
                        obj.totalDistance = obj.totalDistance + obj.distanceCost(curRoad);
                    end        
                elseif( direct(curRoad) == 'W')   
                    centX = centX - v*t_stamp;
                    if centX <= goal_(curRoad+1,1) - 20
                        nextNodeFlag = 1;
                        centX = goal_(curRoad+1,1); % added code
                        % Add distance 
                        obj.totalDistance = obj.totalDistance + obj.distanceCost(curRoad);
                    end        
                end
             end
                
%%%%%%%% MOVE TO ANOTHER NODE FLAG
                if nextNodeFlag == 1
                   obj.currentRoad = curRoad+1;
                end
              
%%%%%%%% DISPLAY AGV WITH OR WITHOUT PODS
           % display AGV with out PODS.
           if Mission == 1 || Mission == 0                                 
                
                x = [ (centX+h1*cosd(alp1+beta1));centX+h1*cosd(180-(alp1+beta1));
                centX+h1*cosd(180+(alp1+beta1));centX+h1*cosd(-(alp1+beta1))];
                y = [ (centY+h1*sind(alp1+beta1));centY+h1*sind(180-(alp1+beta1));
                centY+h1*sind(180+(alp1+beta1));centY+h1*sind(-(alp1+beta1))];
            
                vertex = [x(1,1) y(1,1);x(2,1) y(2,1);x(3,1) y(3,1);x(4,1) y(4,1)];               
                face = [1 2 3 4];
                set(k,'faces',face,'vertices',vertex,'FaceColor',obj.colorface); 
           % display AGV with PODS.  
           else
                h2 = sqrt(1000^2+1000^2)/2;
                x = [ (centX+h2*cosd(45));centX+h2*cosd(180-(45));
                centX+h2*cosd(180+(45));centX+h2*cosd(-(45))];
                y = [ (centY+h2*sind(45));centY+h2*sind(180-(45));
                centY+h2*sind(180+(45));centY+h2*sind(-(45))];
                vertex = [x(1,1) y(1,1);x(2,1) y(2,1);x(3,1) y(3,1);x(4,1) y(4,1)];               
                face = [1 2 3 4];
                set(k,'faces',face,'vertices',vertex,'FaceColor',[0.9290 0.6940 0.1250]); 
            end

%%%%%%%% AGV ROTATION MOVEMENT
            elseif rota(curRoad,1) == 1                                    % AGV is now in the rotation place.
                t = 3 ;                                                    % rotation time in second ( based on THESIS)
                rotAngle = rota(curRoad,2);                                % the total angle to rotate.
                rotStep = rotAngle/(t/t_stamp);                            % divide to each 0.1s angle.
                
                if abs(temp)<abs(rotAngle)  
                    rotate(k,[0 0 1],rotStep,[centX,centY,1]);                     
                    temp = temp + rotStep;
                    obj.tempIndex = temp;
                else 
                    obj.rot(curRoad,:) = [0 0];
                    beta1 = beta1 + rotAngle;
                    obj.tempIndex = 0;
                end  
            end

%%%%%%%%% UPDATE NEW COORDINATE (x,y in mm) 
        obj.coordinateX     =centX;
        obj.coordinateY     =centY;
        obj.beta            =beta1;
        
%% HANDLING THE TASK WHEN AGV GET TO THE GOAL (MOST IMPORTANT PART)
        goalCol = obj.goalX;                                               % extract out the goal column.                  
        goalRow = obj.goalY;                                               % extract out the goal row.
        if(centX == goal_(end,1) && centY == goal_(end,2)) 
            obj.distanceCost = [];
        % MANUAL CASE: 
            if obj.manualFlag == 1
                obj.manualFlag = 0;
%                 deletemanual = find(manualFrame == obj.agvName);
%                 manualFrame(deletemanual) = [];
                obj.currentMission = 0;
                goalline = obj.goalLine;
                goalline.Visible = 'off';
                obj.currentRoad = 1;
                
        % AUTOMATION CASE: 
            else
%%%%%%%% IF : AGV find the PODS position to take the goods - as first mission.
            if Mission == 1                                                
                podStatic(obj.goalY,obj.goalX) = 0;                        % empty the pod position that been taken.
                [goalPod(1,2),goalPod(1,1)] = convNode2Pod([obj.goalY,obj.goalX]);
                                                                           % convert NODE position -> POD position
                a = find(podStatus(:,1) == goalPod(1,2) & podStatus(:,2) == goalPod(1,1),1);
                                                                           % find the pod match.
                podStatus(a,7) = 0;                                        % status of the pod ( is taken ? )
            % TIME WINDOW RESET STORAGE.
                deleteTW = find(time_window(:,5) == double(obj.agvName));
                time_window(deleteTW,:) = [];
                
            % SET-UP FOR NEXT ROAD 
                obj.currentMission = 2;                                    % switch to next mission.
                obj.goalX = wsX;                                           % set the next goal to workstation.
                obj.goalY = wsY;                                           % set the next goal to workstation
                obj.findPathFlag = 1;                                      % set the flag for getCurrentPath() function.
                obj.waitingTime = 3;                                       % wait for 3 seconds to lift the pods.
                
            % VISIBLE THE POD THAT HAD BEEN TAKEN.
                setpod = find(podShow(:,3)==0,1);
                podShow(setpod,3) = 1;
                podShow(setpod,1) = centX; podShow(setpod,2) = centY;
                h2 = sqrt(1000^2+1000^2)/2;
                x = [ (centX+h2*cosd(45));centX+h2*cosd(180-(45));
                centX+h2*cosd(180+(45));centX+h2*cosd(-(45))];
                y = [ (centY+h2*sind(45));centY+h2*sind(180-(45));
                centY+h2*sind(180+(45));centY+h2*sind(-(45))];
                vertex = [x(1,1) y(1,1);x(2,1) y(2,1);x(3,1) y(3,1);x(4,1) y(4,1)];
                face = [1 2 3 4];
                set(emptyPod(setpod,1),'faces',face,'vertices',vertex,'FaceColor',[0.75 0.75 0.75]); 
                emptyPod(setpod,1).Visible = 'on';                         % set another rectangle up on the pod.

%% WAITING WHEN THE AGVS WERE A LINE
%%%%%%%% IF : AGV with Pods already arrived at the WORKSTATION.
            elseif Mission == 2  
%             %%%% TIME WINDOW
% %                 deleteTW = find(time_window(:,5) == double(obj.agvName));
% %                 time_window(deleteTW,:) = [];
% 
%                 [fpoint_,midpoint_,lastpoint_,obj] = inlineWS(obj.wsName,obj.agvName); 
%                 
                obj.currentMission = 3;  
                timeDelay = 0;
                
      %%%% CHECK AGAIN THE ALGORITHM TO GET NEW GOAL !!
                % new damn code
                obj.distanceCost = [0 0 0];
                obj.waitingFlag = 1;
                obj.totalDistance =  obj.totalDistance + 5;
                
                switch obj.wsName
                    case 1
                            agvArray(obj.agvName,1).goal = nodeArray(stor(42,21),:); 
                    case 2
                            agvArray(obj.agvName,1).goal = nodeArray(stor(42,45),:);
                    case 3
                            agvArray(obj.agvName,1).goal = nodeArray(stor(42,70),:);
                    case 4
                            agvArray(obj.agvName,1).goal = nodeArray(stor(1,28),:);
                    case 5
                            agvArray(obj.agvName,1).goal = nodeArray(stor(1,63),:);
                end
                

%                 wsStatus(obj.wsName,4) = wsStatus(obj.wsName,4) -1 ;
%                 lineOfws = [];
%         % UPDATE AGV is which line for waiting ?
%                 switch obj.wsName
%                     case 1
%                             lineOfws = lineOfWS1;
%                     case 2
%                             lineOfws = lineOfWS2;
%                     case 3
%                             lineOfws = lineOfWS3;
%                     case 4
%                             lineOfws = lineOfWS4;
%                     case 5
%                             lineOfws = lineOfWS5;
%                 end

%                 disp(lineOfws);
%                 if (wsStatus(obj.wsName,3) >= 2) || size(lineOfws,2) >= 2
%                     % Dang co 2 AGV dang lam trong WS
%                     findPoint = find( time_window(:,1) == lastpoint_(1,2) & time_window(:,2) == lastpoint_(1,1) & time_window(:,3) == lastpoint_(1,2) & time_window(:,4) == lastpoint_(1,1),1);
%                     fAGV = time_window(findPoint,5);
%                     if isempty(fAGV) ~=1
%                         timeDelay = agvArray(fAGV,1).waitingTime;
%                     end
%                     % Chua duoc vao
%                     newWin = [fpoint_(1,2),fpoint_(1,1),fpoint_(1,2),fpoint_(1,1),obj.agvName,T,T+timeDelay,fpoint_(1,2),fpoint_(1,1),obj.currentMission];
%                     newWin_2 = [lastpoint_(1,2),lastpoint_(1,1),lastpoint_(1,2),lastpoint_(1,1),obj.agvName,T,T+timeDelay+35,lastpoint_(1,2),lastpoint_(1,1),obj.currentMission];
%                     
%                     % Cho agv thu 1 nhat di chuyen
%                     obj.waitingTime = agvArray(fAGV,1).waitingTime;
%                     time_window = cat(1,time_window,newWin,newWin_2);
% 
%                     % Cho agv thu 2 lay do
%                     obj.timeSlowDownIL = 15; 
%                     wsStatus(obj.wsName,3) = wsStatus(obj.wsName,3)+1;  
%                     
%                     % 24/05
%                     obj.waitingTime = agvArray(lineOfws(1),1).waitingTime;
%                     obj.timeSlowDownIL = 15 + (agvArray(lineOfws(2),1).goodHolding -1)*8;
%                     
%                     % Unchanged code
%                     obj.inlineFlag = 1;
%                     obj.slowInlineX = midpoint_(1,1);
%                     obj.slowInlineY = midpoint_(1,2);
%                     
% %                 elseif (wsStatus(obj.wsName,3) == 1) || size(lineOfws,2) == 1
%                 elseif size(lineOfws,2) == 1
%                     % Dang co 1 AGV trong WS
%                     obj.inlineFlag = 1;
%                     obj.slowInlineX = midpoint_(1,1);
%                     obj.slowInlineY = midpoint_(1,2);
%                     findPoint = find( time_window(:,1) == lastpoint_(1,2) & time_window(:,2) == lastpoint_(1,1) & time_window(:,3) == lastpoint_(1,2) & time_window(:,4) == lastpoint_(1,1),1);
%                     fAGV = time_window(findPoint,5);  
%                     if isempty(fAGV) ~=1
%                         timeDelay = agvArray(fAGV,1).waitingTime;
%                     end
%                     obj.timeSlowDownIL = timeDelay; 
%                     newWin = [fpoint_(1,2),fpoint_(1,1),fpoint_(1,2),fpoint_(1,1),obj.agvName,T,T+3,fpoint_(1,2),fpoint_(1,1),obj.currentMission];
%                     newWin_2 = [lastpoint_(1,2),lastpoint_(1,1),lastpoint_(1,2),lastpoint_(1,1),obj.agvName,T,T+timeDelay+20,lastpoint_(1,2),lastpoint_(1,1),obj.currentMission];                                      
%                     time_window = cat(1,time_window,newWin,newWin_2);
%                     wsStatus(obj.wsName,3) = wsStatus(obj.wsName,3)+1; 
%                     
%                     % Neu vao luc AGV 1 chua lay do                    
%                     if agvArray(lineOfws(1),1).waitingTime >0
%                         obj.timeSlowDownIL = agvArray(lineOfws(1),1).waitingTime;
%                     else
%                         if agvArray(lineOfws(1),1).wsName == 1 || agvArray(lineOfws(1),1).wsName == 2 || agvArray(lineOfws(1),1).wsName == 3
%                             obj.timeSlowDownIL = 15 + (agvArray(lineOfws(1),1).goodHolding -1)*8 + 1.5;   
%                         else
%                             obj.timeSlowDownIL = 20 + (agvArray(lineOfws(1),1).goodHolding -1)*8 + 1.5;    
%                         end
%                     end
%                     
%                 else
%                     wsStatus(obj.wsName,3) = wsStatus(obj.wsName,3)+1;
%                     newWin = [fpoint_(1,2),fpoint_(1,1),fpoint_(1,2),fpoint_(1,1),obj.agvName,T,T+3,fpoint_(1,2),fpoint_(1,1),obj.currentMission];
%                     newWin_2 = [lastpoint_(1,2),lastpoint_(1,1),lastpoint_(1,2),lastpoint_(1,1),obj.agvName,T,T+30,lastpoint_(1,2),lastpoint_(1,1),obj.currentMission];
%                     time_window = cat(1,time_window,newWin,newWin_2);    
%                     
%                 end
% 
%                 % Add AGV to in line
%                 switch obj.wsName
%                     case 1
%                         if size(lineOfWS1) >=1
%                             lineOfWS1 = cat(2,lineOfWS1,obj.agvName);
%                         else
%                             lineOfWS1 = obj.agvName;
%                         end
%                     case 2
%                         if size(lineOfWS2) >=1
%                             lineOfWS2 = cat(2,lineOfWS2,obj.agvName);
%                         else
%                             lineOfWS2 = obj.agvName;
%                         end
%                     case 3
%                         if size(lineOfWS3) >=1
%                             lineOfWS3 = cat(2,lineOfWS3,obj.agvName);
%                         else
%                             lineOfWS3 = obj.agvName;
%                         end
%                     case 4
%                         if size(lineOfWS4) >=1
%                             lineOfWS4 = cat(2,lineOfWS4,obj.agvName);
%                         else
%                             lineOfWS4 = obj.agvName;
%                         end
%                     case 5
%                         if size(lineOfWS5) >=1
%                             lineOfWS5 = cat(2,lineOfWS5,obj.agvName);
%                         else
%                             lineOfWS5 = obj.agvName;
%                         end
%                 end

%%%%%%%% IF : AGV with Pods 
            elseif Mission == 3                
                obj.currentMission = 4;
                wsStatus(obj.wsName,3) = wsStatus(obj.wsName,3)-1;
                deleteTW = find(time_window(:,5) == double(obj.agvName));
                time_window(deleteTW,:) = [];
                obj.findPathFlag = 1;
                totalgood = totalgood + obj.goodHolding;
                obj.goodHolding = 0;                
            % Return Pod function
                emptyPosi = find(podStatus(:,7) == 0 );
                x = centX;
                y = centY;
                for i = 1: size(emptyPosi,1)
                   pod = emptyPosi(i);
                   podx = podStatus(pod,1);
                   pody = podStatus(pod,2);
                   [pody,podx] = convPod2Node([podx pody]);% currently is node position
                   finalPod = stor(pody,podx);
                   
                   minDist(i) = abs(nodeArray(finalPod,1)-x) + abs(nodeArray(finalPod,2)-y);
                   minPod(i,:) = [podx pody];
                end
                a = find(minDist==min(minDist),1); 
                obj.goalX = minPod(a,1);
                obj.goalY = minPod(a,2);
                [goalPod(1,2),goalPod(1,1)] = convNode2Pod([obj.goalY,obj.goalX]);
                a = find(podStatus(:,1) == goalPod(1,2) & podStatus(:,2) == goalPod(1,1),1);
                podStatus(a,7) = 1;  
                
%                 switch obj.wsName
%                     case 1
%                             lineOfWS1(1) = [];
%                     case 2
%                             lineOfWS2(1) = [];
%                     case 3
%                             lineOfWS3(1) = [];
%                     case 4
%                             lineOfWS4(1) = [];
%                     case 5
%                             lineOfWS5(1) = [];
%                 end
                tempArray = wsOrdLine(obj.wsName,:);
                tempArray(obj.deleteOrdLine) = '_';
                wsOrdLine(obj.wsName,:) = tempArray; 
                obj.wsName = 0;
                                
            elseif Mission == 4
                deleteTW = find(time_window(:,5) == double(obj.agvName));
                time_window(deleteTW,:) = [];
                obj.currentMission = 0; 
                setpod = find(podShow(:,3)==1 & podShow(:,1)==centX & podShow(:,2)==centY ,1);
%                 disp('centX'); disp(centX); disp('centY');disp(centY);
%                 disp(setpod);
                emptyPod(setpod,1).Visible = 'off';
                podShow(setpod,:) = [ 0 0 0];
                obj.waitingTime = 3;
                
                [goalPod(1,2),goalPod(1,1)] = convNode2Pod([obj.goalY,obj.goalX]);                
                a = find(podStatus(:,1) == goalPod(1,2) & podStatus(:,2) == goalPod(1,1),1);                 
                % Reorganized the pod
                podStatus(a,3) = obj.Agoods;
                podStatus(a,4) = obj.Bgoods;
                podStatus(a,5) = obj.Cgoods;
                podStatus(a,6) = obj.Dgoods;
                podStatic(obj.goalY,obj.goalX) = 1; 
                % Something wrong - make the A* wrong when giving same
                % direction
%                 podStatus(a,8) = 0;                                
            end
            
            goalLine_ = obj.goalLine;
            goalLine_.Visible = 'off';
            obj.currentRoad = 1;
            end
        end
        obj.positionX = goalCol;
        obj.positionY = goalRow;
        
%% IN CASE AGV IS IN A WAITING SITUATION
        else        
            obj.waitingTime = obj.waitingTime - t_stamp;
            if(obj.waitingTime <=0 )
                obj.waitingTime =0;
                if ~isempty(obj.timeSlowDown) == 1  
                    obj.timeSlowDown(end,:) = [];
                    disp('ClearSlowDown');
                end
                if~isempty(obj.slowDownY) == 1 || ~isempty(obj.slowDownX) == 1
                    obj.slowDownY(end,:) = [];
                    obj.slowDownX(end,:) = []; 
                end
%                 pause(0.05);
            end
        end
        
    else
        obj.coordinateX = centX;
        obj.coordinateY= centY;
        obj.positionX = obj.goalX;
        obj.positionY = obj.goalY;
        obj.beta =beta1;        
    end
    end
    end                                      
end   