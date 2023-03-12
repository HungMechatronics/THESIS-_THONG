function [podsort,rectCenter,nodePosLookUp,nodeStorageArray] = drawLayout()
%% OUTPUT DEFINITION
% podsort: sorting pods under Nodes ( belongs to rectCenter )
% rectCenter : all the (x,y) position of each PODS.
% nodePosLookUp : 2D diagram to look up (x,y) position inside "nodeStorageArray" by using (row,column).
% nodeStorageArray : store all (x,y) dimensions of every Nodes in the layout.

%% WAREHOUSE PROPERTIES
clear
clc
% Line (x : horizontal , y: vertical )
% Properties for calculating
l = 115000; w = 58200 ;                                                     % length and width of the Warehouse ( in mm ).
wsLength = 4000 ;                                                           % length of the WorkStation ( in mm ).
wsWidth = 2000;                                                             % width of the WorkStation ( in mm ).                                     
aisWidth = 1800 ;                                                           % width of each Aisle.
firstPointX = 5500 - aisWidth + 1500;  % custom number                      % first "x" coordinate of the Node from the left.
firstPointY = wsWidth + aisWidth/2 - aisWidth + 1500;                       % first "y" coordinate of the Node from the bottom. 
podWidth = 1000 ;                                                           % an edge of a square Pod.
numVerAis = 15;                                                             % number of Aisle in vertical ( except 1st left ).
numHorAis = 13;                                                             % number of Aisle in horizontal. 

% Custom design aisle
secondAisleX = firstPointX + aisWidth;
lastAisleX = secondAisleX + numVerAis*(aisWidth+5*podWidth) + aisWidth;
secondAisleY = firstPointY + aisWidth;
lastAisleY =  secondAisleY + (aisWidth+2*podWidth)*numHorAis + aisWidth; 


% Properties for drawing
axis([-1000 l+1000 -1000 w+1000]);                                          % length and width of the display window
line_weight = 0.5;                                                          % drawing line weight

% Global variables
global verLine horLine;

%% DRAW BOUNDERIES FOR LAYOUT & WAREHOUSE ( DRAWING PURPOSE ONLY )
% draw Horizontal boundary
line([1 l],[1 1],'color',[.7 .7 .7],'LineWidth',2);
line([1 l],[w w],'color',[.7 .7 .7],'LineWidth',2);

% draw Vertical boundary
line([1 1],[1 (w/2-2500)],'color',[.7 .7 .7],'LineWidth',2);
line([1 1],[(w/2+2500) w],'color',[.7 .7 .7],'LineWidth',2);
line([l l],[1 w],'color',[.7 .7 .7],'LineWidth',2);

% draw the Entrance Line
line( [0 firstPointX], [w/2 w/2],'color','r','LineWidth',line_weight);

% draw the Outside Boundary of the Warehouse
line( [firstPointX firstPointX], [firstPointY lastAisleY],'color',[.7 .7 .7],'LineWidth',line_weight); % 1st left vertical
line( [firstPointX lastAisleX],[firstPointY firstPointY],'color',[.7 .7 .7],'LineWidth',line_weight); % 1st bot horizontal
line( [secondAisleX secondAisleX], [firstPointY lastAisleY],'color',[.7 .7 .7],'LineWidth',line_weight); % 2nd left vertical
line( [firstPointX lastAisleX],[secondAisleY secondAisleY],'color',[.7 .7 .7],'LineWidth',line_weight); % 2nd bot horizontal
line( [lastAisleX lastAisleX], [firstPointY lastAisleY],'color',[.7 .7 .7],'LineWidth',line_weight); % last right vertical
line( [firstPointX lastAisleX], [lastAisleY lastAisleY],'color',[.7 .7 .7],'LineWidth',line_weight); % 2nd left vertical


%% WORKSTATION CHARACTERISTICS
% % from now, the workstation can be shortened by WS
% % create the 2 Below WS
step = (105000)/3;                                                         % Distance between the WS (in mm). 
for i = 0:1
    % draw the workstation
    a = step*(i+1)+(wsLength+200)*i-400;
    str = '#B2BEB5';
    convertcolor = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
    rectangle('Position',[a 0 wsLength wsWidth],'FaceColor',convertcolor,'EdgeColor',convertcolor);
     
%     % draw to entrance to WS.
%     line([ 4.5*aisWidth+20.5*podWidth+firstPointX+(5.5*aisWidth+29.5*podWidth)*i  4.5*aisWidth+20.5*podWidth+firstPointX+(5.5*aisWidth+29.5*podWidth)*i ],   [aisWidth/2 firstPointY],'color','b','LineWidth',line_weight);
%     line([4.5*aisWidth+20.5*podWidth+firstPointX+(5.5*aisWidth+29.5*podWidth)*i  4.5*aisWidth+20.5*podWidth+firstPointX+(6*aisWidth+29*podWidth)*i+2*podWidth ],   [aisWidth/2 aisWidth/2],'color','b','LineWidth',line_weight);
%     line( [4.5*aisWidth+20.5*podWidth+firstPointX+(6*aisWidth+29*podWidth)*i+2*podWidth 4.5*aisWidth+20.5*podWidth+firstPointX+(6*aisWidth+29*podWidth)*i+2*podWidth],   [aisWidth/2 wsWidth+aisWidth/2],'color','b','LineWidth',line_weight);       
%     
%     % get the "x,y" position of each Node of the entrance for WS ( anti-clock wise )
%     nodeWS(i*2+1,:) = [4.5*aisWidth+20.5*podWidth+firstPointX+(5.5*aisWidth+29.5*podWidth)*i , aisWidth/2 ];
%     nodeWS(i*2+2,:) = [4.5*aisWidth+20.5*podWidth+firstPointX+(6*aisWidth+29*podWidth)*i+2*podWidth  , aisWidth/2 ];
end
% 
% create the 3 Upper WS
step = (l-4500)/4;
for i = 0:2     
    a = step*(i+1)+wsLength-5000;                                                   % Distance between the WS (in mm). 
    str2 = '#B2BEB5';
    convertcolor2 = sscanf(str2(2:end),'%2x%2x%2x',[1 3])/255;
    rectangle('Position',[a w-wsWidth wsLength wsWidth],'FaceColor',convertcolor2,'EdgeColor',convertcolor);
    
%     line( [firstPointX+3.5*aisWidth+17.5*podWidth+(4*aisWidth+19*podWidth)*i firstPointX+3.5*aisWidth+17.5*podWidth+(4*aisWidth+19*podWidth)*i],              [w-aisWidth/2 firstPointY+(aisWidth+2*podWidth)*numHorAis],'color','b','LineWidth',line_weight);
%     line( [firstPointX+3.5*aisWidth+17.5*podWidth+(4*aisWidth+19*podWidth)*i firstPointX+3.5*aisWidth+17.5*podWidth+(4*aisWidth+19*podWidth)*i+2*podWidth],         [w-aisWidth/2 w-aisWidth/2],'color','b','LineWidth',line_weight);
%     line( [firstPointX+3.5*aisWidth+17.5*podWidth+(4*aisWidth+19*podWidth)*i+2*podWidth , firstPointX+3.5*aisWidth+17.5*podWidth+(4*aisWidth+19*podWidth)*i+2*podWidth],  [w-aisWidth/2 firstPointY+(aisWidth+2*podWidth)*numHorAis],'color','b','LineWidth',line_weight);
%     
%     % get the "x,y" position of each Node of the entrance for WS ( clock wise) 
%     nodeWS(i*2+1+4,:) = [firstPointX+3.5*aisWidth+17.5*podWidth+(4*aisWidth+19*podWidth)*i , w-aisWidth/2];
%     nodeWS(i*2+2+4,:) = [firstPointX+3.5*aisWidth+17.5*podWidth+(4*aisWidth+19*podWidth)*i+2*podWidth , w-aisWidth/2 ];
end


%% WAREHOUSE INNER LAYOUT CREATION
% create an Array to store 2 head Nodes of Vertical aisle
verAisle(1,:) = [firstPointX firstPointY];                                  % first point (x,y) of 1st left Vertical aisle.
verAisle(2,:) = [firstPointX lastAisleY];                                   % last point (x,y) of 1st left Vertical aisle.
verAisle(3,:) = [secondAisleX lastAisleY];
verAisle(4,:) = [secondAisleX firstPointY];

for i = 1:numVerAis
      % display all Vertical aisles ( not including the 1st left )
      line( [(secondAisleX)+i*(aisWidth+5*podWidth) (secondAisleX)+i*(aisWidth+5*podWidth)], [firstPointY lastAisleY],'color',[.7 .7 .7],'LineWidth',line_weight);
      
      % sorting the aisles as zig-zag => the drawing won't get wrong.
      if(mod(i,2)==0)
      verAisle(i*2+4,:) = [secondAisleX+i*(aisWidth+5*podWidth) firstPointY]  ;
      verAisle(i*2+3,:) = [secondAisleX+i*(aisWidth+5*podWidth) lastAisleY] ;
        if (i == numVerAis)
            verAisle(end+1,:) = [lastAisleX firstPointY]  ;         % Add node for last right pod.
            verAisle(end+1,:) = [lastAisleX lastAisleY] ;
        end
      else
      verAisle(i*2+3,:) = [secondAisleX+i*(aisWidth+5*podWidth) firstPointY]  ;
      verAisle(i*2+4,:) = [secondAisleX+i*(aisWidth+5*podWidth) lastAisleY] ;     
        if (i == numVerAis)
            verAisle(end+1,:) = [lastAisleX lastAisleY] ;
            verAisle(end+1,:) = [lastAisleX firstPointY]  ;
        end
      end
end

% create an Array to store 2 head Nodes of Horizontal aisle
horAisle(1,:) = [firstPointX firstPointY];                                  % first point (x,y) of 1st left Horizontal aisle.
horAisle(2,:) = [lastAisleX firstPointY];                                   % last point (x,y) of 1st left Horizontal aisle.
horAisle(4,:) = [firstPointX secondAisleY];                                 % first point (x,y) of 2nd left Horizontal aisle.
horAisle(3,:) = [lastAisleX secondAisleY];                                  % last point (x,y) of 2nd left Horizontal aisle.

for i = 1:numHorAis
    % display all Horizontal aisles ( not including the 1st bottom )
    line( [firstPointX lastAisleX],[secondAisleY+i*(aisWidth+2*podWidth) secondAisleY+i*(aisWidth+2*podWidth)],'color',[.7 .7 .7],'LineWidth',line_weight);
    
    % sorting the aisles as zig-zag => the drawing won't get wrong
    if(mod(i,2)==0)
    horAisle(i*2+4,:) = [firstPointX secondAisleY+i*(aisWidth+2*podWidth)]  ;
    horAisle(i*2+3,:) = [lastAisleX secondAisleY+i*(aisWidth+2*podWidth)] ; 
        if (i == numHorAis)
            horAisle(end+1,:) = [firstPointX lastAisleY]  ;                 % Add node for last right pod.
            horAisle(end+1,:) = [lastAisleX lastAisleY] ;
        end
    else
    horAisle(i*2+3,:) = [firstPointX secondAisleY+i*(aisWidth+2*podWidth)]  ;
    horAisle(i*2+4,:) = [lastAisleX secondAisleY+i*(aisWidth+2*podWidth)] ; 
        if (i == numHorAis)
            horAisle(end+1,:) = [lastAisleX lastAisleY]  ;                  % Add node for last right pod.
            horAisle(end+1,:) = [firstPointX lastAisleY] ;
        end
    end
end
    
%% PRE-DEFINED LOCAL VARIABLES FOR COUNTING 
X(1,1) = 0;         
Y(1,1) = 0;
podIndex = 1 ;
rowSeqIndex= 0;
colSeqIndex = 0;

%% PODS CALCULATING & SORTING
for count_y = 1:numHorAis                                                   % JUMP STEP IN HORIZONTAL.
    
    if count_y == numHorAis
       colSeqIndex = 0;
    end
    
% EXPLANATION FOR THE ALGORITHM: There are 10 pods in a batch, which will be
% numbered from 1->10 with 1 is the left-bottom and 10 is the right-top.
%
%   |6 |7 |8 |9 |10|       |6 |7 |8 |9 |10|
%   |1 |2 |3 |4 |5 |  ---> |1 |2 |3 |4 |5 | --->
%    
    for count_x = 1:numVerAis                                              % JUMP STEP IN VERTICAL.
        for i = 1:2                                                        % set the left-bottom Pod ( of each Batch ) to 1.
            for j = 1:5                                                    % count the Pod from 1->5 , 6->10.
                
            % CALCULATING ALGORITHM:
                % get coordinate of the left-bottom corner of each Pod
                LeftBotCorner_X = (secondAisleX+aisWidth/2) + (5*podWidth+aisWidth)*(count_x-1) + (j-1)*podWidth;       % calculate "x" coordinate of the left-bottom corner of each Pod.
                LeftBotCorner_Y = (secondAisleY+aisWidth/2) + (2*podWidth+aisWidth)*(count_y-1) + (i-1)*podWidth;     % calculate "y" coordinate of the left-bottom corner of each Pod.
                % get coordinate of the Center-point of each Pod
                rectCenter(podIndex,1) = LeftBotCorner_X + podWidth/2;                       % calculate "x" coordinate of the Center-point of each Pod.
                rectCenter(podIndex,2) = LeftBotCorner_Y + podWidth/2;                      % calculate "y" coordinate of the Center-point of each Pod
               
                % store the corner "x" "y" to display the Pods
                X(podIndex,1) = double(LeftBotCorner_X); 
                Y(podIndex,1) = double(LeftBotCorner_Y);
                
            % SORTING ALGORITHM:
                % sorting the lines ( under the Pods ) zig-zag "Horizontal".
                % => drawing and creating Node won't get wrong.
                %
                %   1 - - - - - - - - - - > 2
                %   4 < - - - - - - - - - - 3
                %   1 - - - - - - - - - - > 2
                %
                %   rowSeqIndex: +1 to jump from "1" to another "1"
                
                if ( rectCenter(podIndex,1) == (secondAisleX + aisWidth/2 + podWidth/2))         % sorting the node in the 1st left vertical aisle.       
                    if i == 1                                              % 1-4-5-8-9...
                    podStor(rowSeqIndex*4+1,:) = [ firstPointX , rectCenter(podIndex,2) ];
                    else
                    podStor(rowSeqIndex*4+4,:) = [ firstPointX , rectCenter(podIndex,2) ];
                    end

                elseif rectCenter(podIndex,1) == (secondAisleX + aisWidth/2 + podWidth/2) + (numVerAis*(aisWidth+5*podWidth)-podWidth-aisWidth)  
                                                                           % sorting the node in the last vertical aisle.                    
                    if i == 1                                              % 2-3-6-7-10-11-...
                    podStor(rowSeqIndex*4+2,:) = [ lastAisleX , rectCenter(podIndex,2)];
                    else
                    podStor(rowSeqIndex*4+3,:) = [ lastAisleX , rectCenter(podIndex,2)];   
                    end
                end
                
                % sorting the lines ( under the Pods ) zig-zag "Vertical".
                % => drawing and creating Node won't get wrong.
                %
                %       2 -> 3    6         10            2
                %       /\   |    /\       /\ |           /\
                %       |    |    |        |  |           |
                %       |   \/    |        | \/           |
                %       1    4 -> 5  ....  9-11       --> 1
                %
                %   colSeqIndex: +1 to jump from "1" to another "1".
                
                switch j                     
                    case 1                                                 % sorting the Node in position 1 & 2
                       if count_y == 1
                           podStor1(colSeqIndex*11+1,:) = [ rectCenter(podIndex,1) , firstPointY ];                         
                       elseif count_y == numHorAis
                           podStor1(colSeqIndex*11+2,:) = [ rectCenter(podIndex,1) , lastAisleY ];
                       end
                    case 2                                                 % sorting the Node in position 3 & 4
                       if count_y == 1
                           podStor1(colSeqIndex*11+4,:) = [ rectCenter(podIndex,1) , firstPointY ];
                       elseif count_y == numHorAis
                           podStor1(colSeqIndex*11+3,:) = [ rectCenter(podIndex,1) , lastAisleY ];
                       end
                    case 3                                                 % sorting the Node in position 5 & 6
                       if count_y == 1
                           podStor1(colSeqIndex*11+5,:) = [ rectCenter(podIndex,1) , firstPointY ];
                       elseif count_y == numHorAis
                           podStor1(colSeqIndex*11+6,:) = [ rectCenter(podIndex,1) , lastAisleY ];
                       end
                    case 4                                                 % sorting the Node in position 7 & 8
                       if count_y == 1
                           podStor1(colSeqIndex*11+8,:) = [ rectCenter(podIndex,1) , firstPointY ];
                       elseif count_y == numHorAis
                           podStor1(colSeqIndex*11+7,:) = [ rectCenter(podIndex,1) , lastAisleY ];
                       end
                    case 5                                                 % sorting the Node in position 9 & 10
                       if count_y == 1
                           podStor1(colSeqIndex*11+9,:) = [ rectCenter(podIndex,1) , firstPointY ];
                           podStor1(colSeqIndex*11+11,:) = [ rectCenter(podIndex,1) , firstPointY ];
                       elseif count_y == numHorAis
                           podStor1(colSeqIndex*11+10,:) = [ rectCenter(podIndex,1) , lastAisleY ];
                       end
                    otherwise 
                end
                % increasing the index counter for Pod's variable
                podIndex = podIndex + 1;                                
            end
        end 
        % increasing the index to move to the next "11 cycle".
        colSeqIndex = colSeqIndex + 1 ; 
    end
    % increasing the index to move to the next "4 cycle".
    rowSeqIndex = rowSeqIndex + 1;
end  

%% ALL NODE CREATION
% CALCULATING ALGORITHM: Using function polyxpoly to create the nodes that intersect (faster).
[x4,y4] = polyxpoly(verAisle(:,1),verAisle(:,2),horAisle(:,1),horAisle(:,2),'unique');      % "x" and "y" at the crossroads ( ngã tư ).
[x5,y5] = polyxpoly(horAisle(:,1),horAisle(:,2),podStor1(:,1),podStor1(:,2),'unique');  % "x" and "y" at the Pods lines intersect Horizontal aisle.
[x6,y6] = polyxpoly(verAisle(:,1),verAisle(:,2),podStor(:,1),podStor(:,2),'unique');    % "x" and "y" at the Pods lines intersect Vertical aisle.

% Draw lines ( except aisles - which already draw above ).
verLine =line(podStor1(:,1),podStor1(:,2),"LineWidth",0.1,'color',[.7 .7 .7]);
horLine =line(podStor(:,1),podStor(:,2),"LineWidth",0.1,'color',[.7 .7 .7]);
    
%% DISPLAYS PODS & NODES
% Display the pods in rectangles.
wid = ones(size(X))*podWidth; 
hei = ones(size(Y))*podWidth;
pos = [X ,Y ,wid,hei];
displayPods = rectangles(pos);                                              % using rectangles library to draw.

% Combination of Nodes
% nodeStorageArray = cat(1,[x4,y4],[x5,y5],[x6,y6],rectCenter,nodeWS);               % combine all the Nodes.	
nodeStorageArray = cat(1,[x4,y4],[x5,y5],[x6,y6],rectCenter); 
nodeStorageArray = int64(nodeStorageArray);
rectCenter = int64(rectCenter);

% Display Nodes on maps
cirDisplayRadius = ones(1,size(nodeStorageArray,1))*100;
cirDisplayNodes = viscircles(nodeStorageArray,cirDisplayRadius,'Color','r');
cirDisplayNodes.Visible = 'off';                                            % turn Visible to 'on' to see the Nodes => Make sure we cover all the Nodes.

%% SORTING ALL THE NODES INTO A SINGLE MATRIX
% Store all node into a single matrix for A* algorithm.
% ALGORITHM EXPLANATION:
%    Since A* only took the matrix [m,n], so we have to turn the nodes into
%    matrix with m: rows and n: columns.
%
%    (m,1)-------------------------------- (m,n)
%      |                                     |
%      |                                     |
%    (2,1) (2,2)                             |
%    (1,1) (1,2) ------------------------- (1,n)
%
%

% Sort the first row in the bottom
a = find(nodeStorageArray(:,2)== firstPointY);                                                                          
b = [a , nodeStorageArray(a)];
[b,I] = sort(b(:,2));
a = a(I);
nodePosLookUp(1,:) = a;  

% Sort from row 2 -> 41 ( last - 1 )
for j = 1:numHorAis
    for i = 0:2
        % SORTING ALGORITHM: Sorting Nodes into a Matrix
        if i == 0                                                          % if it is belonging to the aisle .
            % SORTING ALGORITHM: Sorting Nodes on aisle lines.
            a = find(nodeStorageArray(:,2)== secondAisleY+(aisWidth+2*podWidth)*(j-1));               
                                                                           % find all the Nodes have "y" equal to aisle's "y" .
            b = [a , nodeStorageArray(a)];
            [b,I] = sort(b(:,2));
            a = a(I);
            nodePosLookUp((j-1)*3+i+2,:) = a;                                       % 

            if j == numHorAis
                a = find(nodeStorageArray(:,2)== secondAisleY +(aisWidth+2*podWidth)*(j));
                b = [a , nodeStorageArray(a)];
                [b,I] = sort(b(:,2));
                a = a(I);
                % When changing the layout , remember to change this
                nodePosLookUp(41,:) = a;                                   % Maximum row is 42 => Row extend then change it .
            end
        
        else                                                               % if it is not belonging to the aisle.
            % SORTING ALGORITHM: Sorting the Nodes intersect of Pods & Aisles.
            a = find(nodeStorageArray(:,2)== secondAisleY+((podWidth+aisWidth)/2)+podWidth*(-1+i)+(aisWidth+2*podWidth)*(j-1)); 
            b = [a , nodeStorageArray(a)];
            [b,I] = sort(b(:,2));
            a = a(I);
            nodePosLookUp((j-1)*3+i+2,:) = a;

            % SORTING ALGORITHM: Sorting the Nodes under the Pods.
            c = find(rectCenter(:,2) == secondAisleY+((podWidth+aisWidth)/2)+podWidth*(-1+i)+(aisWidth+2*podWidth)*(j-1)); 
            d = [c , rectCenter(c)];
            [d,S] = sort(d(:,2));
            c = c(S);
            podsort((j-1)*2+i,:) = c;        
        end
    end
end    

% Sort the last row on the top.
a = find(nodeStorageArray(:,2)== lastAisleY);               
b = [a , nodeStorageArray(a)];
[b,I] = sort(b(:,2));
a = a(I);
nodePosLookUp(end+1,:) = a;

%% CHECKING RESULTS AFTHER SORTING
% viscircles(nodeStorageArray(nodePosLookUp(8,1),:),100,'Color','r');
%% STEP TO CHANGE CURRENT LAYOUT INTO ANOTHER

%% CREATE RECTANGLES FOR RETURN POSITION
rectangle('Position',[nodeStorageArray(nodePosLookUp(1,28),1)-500 nodeStorageArray(nodePosLookUp(1,28),2)-500 1000 1000],'FaceColor','none','EdgeColor','r','LineWidth',1.5);
rectangle('Position',[nodeStorageArray(nodePosLookUp(1,63),1)-500 nodeStorageArray(nodePosLookUp(1,63),2)-500 1000 1000],'FaceColor','none','EdgeColor','r','LineWidth',1.5);
rectangle('Position',[nodeStorageArray(nodePosLookUp(42,21),1)-500 nodeStorageArray(nodePosLookUp(42,21),2)-500 1000 1000],'FaceColor','none','EdgeColor','r','LineWidth',1.5);
rectangle('Position',[nodeStorageArray(nodePosLookUp(42,45),1)-500 nodeStorageArray(nodePosLookUp(42,45),2)-500 1000 1000],'FaceColor','none','EdgeColor','r','LineWidth',1.5);
rectangle('Position',[nodeStorageArray(nodePosLookUp(42,70),1)-500 nodeStorageArray(nodePosLookUp(42,70),2)-500 1000 1000],'FaceColor','none','EdgeColor','r','LineWidth',1.5);

end
