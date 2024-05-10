function [SAFE_LRUD]  =  get_SAFE_LRUD(mesh_ , show_mesh)  

%  re calculate wih the id values assuming width unchanged from original
%  may need the outside nodes 
%  
show_text = 0;

[min_x_val ,~] =      min(mesh_.nd.pos(:,1))   ;
[max_x_val ,~] =      max(mesh_.nd.pos(:,1))   ;
[min_y_val ,~] =      min(mesh_.nd.pos(:,2))   ;
[max_y_val ,~] =      max(mesh_.nd.pos(:,2))   ;

%  width_  = 
%  trans_val_y 
%  trans_val_x 

% New Part jim 2023  for worn wires
% -------------------------------------------
width_ = max_x_val - min_x_val  ;
Trans_x  =   (max_x_val + min_x_val)/2;
Trans_y  =   max_y_val - width_/2 ;

L_ideal_point = [min_x_val,Trans_y];
R_ideal_point = [max_x_val,Trans_y];
U_ideal_point = [Trans_x,max_y_val];
D_ideal_point = [Trans_x,min_y_val];
% -------------------------------------------
% New Part jim 2023  for worn wires



[L_dist_to_ideal,L_node ] =  min((((mesh_.nd.pos(:,1))- L_ideal_point(1)).^2 + (mesh_.nd.pos(:,2)- L_ideal_point(2)).^2).^0.5);
[R_dist_to_ideal,R_node ] =  min((((mesh_.nd.pos(:,1))- R_ideal_point(1)).^2 + (mesh_.nd.pos(:,2)- R_ideal_point(2)).^2).^0.5);
[U_dist_to_ideal,U_node ] =  min((((mesh_.nd.pos(:,1))- U_ideal_point(1)).^2 + (mesh_.nd.pos(:,2)- U_ideal_point(2)).^2).^0.5);
[D_dist_to_ideal,D_node ] =  min((((mesh_.nd.pos(:,1))- D_ideal_point(1)).^2 + (mesh_.nd.pos(:,2)- D_ideal_point(2)).^2).^0.5);

SAFE_LRUD         =  [L_node,R_node,U_node,D_node]  ; 

if show_text == 1
disp(['L node, R node, U node, D node (nos in the hist file)   =  '  ,   num2str(L_node),', ', num2str(R_node),', ',num2str(U_node),', ',num2str(D_node)'.'])  
disp(['Transducer order: ',num2str(U_node),', ' num2str(R_node),', ',num2str(D_node),',', num2str(L_node),'.']   )
end % if show_text == 1



if show_mesh    == 1
figure
fv.Vertices   = mesh_.nd.pos;
fv.Faces      = mesh_.el.nds ;
patch(fv, 'FaceColor', 'c');
axis equal;
axis off;
hold on
plot([min_x_val*1.2,max_x_val*1.2],[0,0])
plot([0,0],[min_y_val*1.2,max_y_val*1.2])

plot(mesh_.nd.pos(L_node,1) , mesh_.nd.pos(L_node,2),'ro','markersize',20)
plot(mesh_.nd.pos(R_node,1) , mesh_.nd.pos(R_node,2),'ro','markersize',20)
plot(mesh_.nd.pos(U_node,1) , mesh_.nd.pos(U_node,2),'ro','markersize',20)
plot(mesh_.nd.pos(D_node,1) , mesh_.nd.pos(D_node,2),'ro','markersize',20)

plot (L_ideal_point(1),L_ideal_point(2),'kx','markersize',20)
plot (R_ideal_point(1),R_ideal_point(2),'kx','markersize',20)
plot (U_ideal_point(1),U_ideal_point(2),'kx','markersize',20)
plot (D_ideal_point(1),D_ideal_point(2),'kx','markersize',20)

end % if show_mesh    == 1
%disp(['Left node: ',  num2str(L_node),'(',num2str(L_dist_to_ideal*1000),'mm, SAFE_node: ',num2str(L_node),')'])
%disp(['Right node:',  num2str(R_node),'(',num2str(R_dist_to_ideal*1000),'mm, SAFE_node: ',num2str(R_node),')'])
%disp(['Up node:   ',  num2str(U_node),'(',num2str(U_dist_to_ideal*1000),'mm, SAFE_node: ',num2str(U_node),')'])
%disp(['Down node: ',  num2str(D_node),'(',num2str(D_dist_to_ideal*1000),'mm, SAFE_node: ',num2str(D_node),')'])


end  %function [SAFE_LRUD]  =  get_SAFE_LRUD_points(reshaped_proc_data,show_mesh) 
