function type = frontCorruptCheck(corruptWindow,t_in,t_out,A1_Row,A1_Col,B1_Row,B1_Col,time2turn,current_type)
    %% CREATE SOME DEFAULT TYPE:
    collision_type = current_type;
    disp('Currupt window:');disp(corruptWindow)
    %% CHECK ALL WINDOWS THAT HAVE AGV HEAD-2-HEAD:
    for i = 1:size(corruptWindow,1)
    % AGV1 vao doan duong sau AGV2
       if ( (t_in <= corruptWindow(i,6)   && t_out >= corruptWindow(i,6))  || ...
            (t_in >= corruptWindow(i,6)   && t_in <= corruptWindow(i,7))  )          
           collision_type = 1;
           disp('Va cham doi dau');
       end
    end
    
    %% RETURN THE TYPE:
    type = collision_type;
end