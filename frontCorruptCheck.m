function type = frontCorruptCheck(corruptWindow,t_in,t_out,A1_Row,A1_Col,B1_Row,B1_Col,time2turn)
    %% CREATE SOME DEFAULT TYPE:
    collision_type = 0;
    
    %% CHECK ALL WINDOWS THAT HAVE AGV HEAD-2-HEAD:
    for i = 1:size(corruptWindow,1)
    % AGV_1 come in sooner OR AGV_1 come in later THEN AGV_2,3,4 come in.
    % AND 
    % next node of AGV_1 is next node of AGV_2,3,4 or vice verse.
       if ( (t_in <= corruptWindow(i,6)   && t_out >= corruptWindow(i,6))  || (t_in >= corruptWindow(i,6)   && t_in <= corruptWindow(i,7))) && ...
          ( (B1_Row == corruptWindow(i,1) && B1_Col == corruptWindow(i,2)) || (A1_Row == corruptWindow(i,3) && A1_Col == corruptWindow(i,4)))           
           collision_type = 1;
%            disp('Va cham doi dau');
           
%        elseif (t_out >= corruptWindow(i,6) && t_out <= corruptWindow(i,7) &&  B1_Row == corruptWindow(i,1) && B1_Col == corruptWindow(i,2)) || ...
%        (corruptWindow(i,7) >= t_in && corruptWindow(i,7) <= t_out         &&  A1_Row == corruptWindow(i,3) && A1_Col == corruptWindow(i,4))
%            collision_type = 1;
%            disp('Va cham doi dau');
       end
    end
    
    %% RETURN THE TYPE:
    type = collision_type;
end