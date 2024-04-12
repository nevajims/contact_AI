function convert_old_Blocks

% Select the file

% Get the unique labels

% Save the file

P_W_D = pwd ;
cd('P:\GITHUBS\AIDATA\Learning_block_2')
[file_,path_]=uigetfile();
Block_file = [path_,file_];

dummy = open(Block_file);
Block_DATA = dummy.Block_DATA;

Block_DATA.File_labels          = Block_DATA.Labels_ ; 
Block_DATA.File_label_index     = Block_DATA.tag_label_index;

[Block_DATA.Labels_,Block_DATA.tag_label_index] = create_Unique_labels(Block_DATA.Labels_,Block_DATA.tag_label_index);

save([file_(1:end-4) ,'_UpD.mat'],'Block_DATA')

cd(P_W_D)

end %function convert_old_Blocks
