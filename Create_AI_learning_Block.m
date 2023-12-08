function AI_Block  = Create_AI_learning_Block(NumNeighbors_,mode_pairs_to_Use, all_modes,Labels_,tag_label_index)
%NumNeighbors_ = 3;
%mode_pairs_to_Use = [3,6,8,9,14,16];


%P_W_D = pwd;
%cd('P:\GITHUBS\Liams_algos')  % will need to change on a different  computer 
%[file_ , path_]  =  uigetfile('*.*','Select the Block_data set');
%dummy =  open(strcat(path_,file_));
%Block_DATA = dummy.Block_DATA;

mode_block_2d = reshape(all_modes,16,length(all_modes))';
Data_mat = mode_block_2d(:,mode_pairs_to_Use);
tags_ = Labels_(tag_label_index)';
AI_Block = fitcknn(Data_mat,tags_,"Standardize",true,'NumNeighbors',NumNeighbors_ ,'Distance','cityblock');

 
% save([path_,'AI_Block',file_(11:end-4),'_NN_',num2str(NumNeighbors_),'_mat'],'AI_Block')
% cd(P_W_D)
% save using the blockdata name in the file name and the NumNeighbors_ in
% there too 
end %function AI_Block  = Create_AI_learning_Block()
