function   predict_a_test_result(normalising_mode_index,mode_pairs_to_Use)

% predict_a_test_result(1,[8,9,14,16])
% predict_a_test_result(1,[3,6,8,9,14,16])   ----  standard run
% mode_pairs_to_Use = [3,6,8,9,14,16];       %  %  this will be an input argument 
% normalisation_mode_pair =  1               %  %  (1,1) this will be an input argument
mode_pairs=  [1,1;1,2;1,3;1,4;2,1;2,2;2,3;2,4;3,1;3,2;3,3;3,4;4,1;4,2;4,3;4,4];
labels = {'1-1','1-2','1-3','1-4','2-1','2-2','2-3','2-4','3-1','3-2','3-3','3-4','4-1','4-2','4-3','4-4'}; 
normalising_mode_pair =  mode_pairs(normalising_mode_index,:);
NumNeighbors = 3 ;
std_bar_size = 1;
show_tag_mean_mode_plots = 0 ;

P_W_D = pwd ;

%  load a block data set 
cd('C:\Users\Dev\OneDrive\shared from tti test\AIDATA')
[file_,path_]=uigetfile();
dummy =  open(strcat(path_,file_));
cd(P_W_D)
%dummy =  open('P:\GITHUBS\Liams_algos\Learning_block_1\Block_data_45_PP_2_L8_DV.mat');
Block_DATA = dummy.Block_DATA;

Labels_ = Block_DATA.Labels_;
tag_label_index = Block_DATA.tag_label_index;

norm_crack_mode_ = normalse_crack_modes(Block_DATA.crack_mode_,normalising_mode_pair);

for index = 1:length(Labels_)
%disp(['Tag = ',Labels_{index} ,'.'])
tag_indicies                   = find(tag_label_index == index);
tag_modes_ =   norm_crack_mode_(:,:,tag_indicies);
mean_temp = mean(tag_modes_ , 3) ;
mean_tag_modes_{index}         = mean_temp;
std_temp = std(tag_modes_,0,3)  ;
std_tag_modes_{index}          = std_temp;

Block_DATA.mean_tag_modes_ = mean_tag_modes_;
Block_DATA.std_tag_modes_  = std_tag_modes_;

if show_tag_mean_mode_plots == 1
interp_data = get_interp_data(mean_tag_modes_{index},50);
plot_interp_data(interp_data,[Labels_{index},':: mean values(normalised to 1-1)'],0.8)
interp_data = get_interp_data(std_temp./mean_temp,50);
plot_interp_data(interp_data,[Labels_{index},':: std over mean   '],0.8)
end %if show_tag_mean_mode_plots == 1
end %for index = 1:length(Labels_)

%  this will be done on the fly
%  this will be done on the fly
%dummy =  open(strcat(path_2,file_2));
%dummy =  open('P:\GITHUBS\Liams_algos\Learning_block_1\AI_Block_45_PP_2_L16_DV_NN_3_mat.mat');
%dummy =  open('P:\GITHUBS\Liams_algos\Learning_block_2\AI_Block_45_PP_6_L48_DV_NN_3_mat.mat');
% AI_Block = dummy.AI_Block;

AI_Block  = Create_AI_learning_Block(NumNeighbors,mode_pairs_to_Use, norm_crack_mode_,Block_DATA.Labels_, Block_DATA.tag_label_index );

[spec_vals,file_name] =  Get_mode_values_from_a_test(Block_DATA.Peak_method, Block_DATA.Percentage_Peak);

SV_crack_mode = spec_vals.crack_mode;
SV_crack_mode = SV_crack_mode./SV_crack_mode(normalising_mode_pair(1),normalising_mode_pair(2));
spec_vals_temp = reshape(SV_crack_mode, 1 , numel(SV_crack_mode));

[return_tag,score_,node_] = predict(AI_Block , spec_vals_temp(mode_pairs_to_Use));
[Score_vals]   = do_mean_std_plot(spec_vals_temp,Block_DATA,mode_pairs_to_Use,labels,std_bar_size);
[score_table , predict_tag]    = get_tag_scores (Score_vals,labels,mode_pairs_to_Use,Block_DATA.Labels_);

disp('-----------------------------------------------------------------')
disp(file_name)
disp('-----------------------------------------------------------------')
disp(['Peak location: ',num2str(spec_vals.Peak_loc),' mm.'])
disp('-----------------------------------------------------------------')
disp('-----------------------------------------------------------------')
display_Block_data_stats(Block_DATA);
disp('-----------------------------------------------------------------')
disp(['normalising_mode_pair: ',num2str(normalising_mode_pair(1)),'/',num2str(normalising_mode_pair(2)),'.'])
disp('-----------------------------------------------------------------')
disp(['The AI predicts that this results is:   ', return_tag{1} ,' .'])
disp('-----------------------------------------------------------------')
disp('-----------------------------------------------------------------')
disp(['The statistical analysis predicts that the result is:   ',  predict_tag ,' .'])
disp('-----------------------------------------------------------------')
disp('-----------------------------------------------------------------')
disp('Dist from mean for each mode pair')
disp('-----------------------------------------------------------------')
disp(score_table)
disp('-----------------------------------------------------------------')
disp('-----------------------------------------------------------------')

%if show_tag_mean_mode_plots == 1
%for index= 1: length(Block_DATA.Labels_)
%interp_data = get_interp_data(Block_DATA.mean_tag_modes_{index},50);
%plot_interp_data(interp_data,[Block_DATA.Labels_{index},':: BLOCK mean values(normalised to 1-1)'],0.8)
%end  % for index= 1: length(Block_DATA.Labels_)
%end %if show_tag_mean_mode_plots == 1


interp_data_2 = get_interp_data(spec_vals.crack_mode,50);
plot_interp_data(interp_data_2,'SPECIFIC TEST mode plot',0.8)
cd(P_W_D)
end  % function   predict_a_test_result

%-------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------

function display_Block_data_stats(Block_DATA)
disp('Number of tests for each data set'  )     
for index = 1:length(Block_DATA.Labels_)
disp(['Tag = ', Block_DATA.Labels_{index},'(',num2str(length(find(Block_DATA.tag_label_index==index))),')'])
end %for index = 1:length(Block_DATA.Labels_)
end %function display_Block_data_stats(Block_DATA);

function norm_crack_mode_ = normalse_crack_modes(crack_mode_,normalising_mode_pair)
for index = 1:length(crack_mode_)
norm_crack_mode_(:,:,index) = crack_mode_{index} / crack_mode_{index}(normalising_mode_pair(1),normalising_mode_pair(2));
end %for index = 1:length(crack_mode_)

end% function norm_crack_mode_ = normalse_crack_modes(Block_DATA.crack_mode_,normalising_mode_pair)



function [score_table,predict_tag] = get_tag_scores (Score_vals,labels,mode_pairs_to_Use,Tags_);

score_mat = zeros(length(Score_vals.Means_),length(mode_pairs_to_Use)+1);

%for index = 1 :length(Score_vals.Means_)
%Score_vals.Stds_{index})
%end


for index = 1 :length(Score_vals.Means_)
temp_ =  100 * abs((Score_vals.Means_{index}-Score_vals.spec_vals_ ));
% temp_ =   abs((Score_vals.Means_{index}-Score_vals.spec_vals_ )./Score_vals.Stds_{index});

score_mat(index,:) = [temp_,mean(temp_)];
end %for index = 1 :length(Score_vals.Means_)


columns__ =  [labels(mode_pairs_to_Use),{'Mean'}];

[~ ,Predict_index]  =  min(score_mat(:,end));
predict_tag = Tags_{Predict_index};

   score_table = array2table(score_mat,...
       'VariableNames',columns__,...
       'RowNames',Tags_); 
end %function Tag_scores_    = get_tag_scores (Score_vals);



function [Score_vals]  =  do_mean_std_plot(spec_vals_temp , Block_DATA , mode_pairs_to_Use,labels,std_bar_size  )

figure
val_nos_tmp = 1:16;
xBlanks = zeros(1, length(mode_pairs_to_Use));
axes('XTick', 1: length(mode_pairs_to_Use), 'XLim', [0,length(mode_pairs_to_Use)+1 ], 'XTickLabel', labels(mode_pairs_to_Use));
hold on

for index = 1: length(Block_DATA.Labels_)
mean_temp         =  reshape (Block_DATA.mean_tag_modes_{index},1,numel(Block_DATA.mean_tag_modes_{index}));
SD_temp           =  reshape (Block_DATA.std_tag_modes_{index},1,numel(Block_DATA.std_tag_modes_{index}));


errorbar(val_nos_tmp(1:length(mode_pairs_to_Use)),mean_temp(mode_pairs_to_Use),SD_temp(mode_pairs_to_Use)*std_bar_size,':o')
Means_{index} = mean_temp(mode_pairs_to_Use);
Stds_{index}  = SD_temp(mode_pairs_to_Use);
end %for index = 1: length(Block_DATA.Labels_)

plot(val_nos_tmp(1:length(mode_pairs_to_Use)),spec_vals_temp(mode_pairs_to_Use),'s','markersize',14)

legend([Block_DATA.Labels_,{'TEST'}],'location','EastOutside');
Score_vals.Means_       =  Means_                              ;
Score_vals.Stds_        =  Stds_                               ; 
Score_vals.spec_vals_   =  spec_vals_temp(mode_pairs_to_Use)   ;

end %function do_mean_std_plot(spec_vals,Block_DATA)

function plot_interp_data(interp_data,title_,db_range) 
figure
colormap default;
surf(interp_data);
view(2);
axis equal;
shading flat;
axis off;
caxis([0, db_range]);
colorbar;

title(title_)

    sf = 50 / 4;
    offset = 50 / 50;

modes_temp = [1,2,3,4];

for ii = 1:4
    a = text((ii - 0.5) * sf + 1, - offset + 1, sprintf('%i',modes_temp(ii)));
    set(a, 'HorizontalAlignment', 'center');
    set(a, 'VerticalAlignment', 'top');

    a = text(-offset + 1, (ii - 0.5) * sf + 1, sprintf('%i',modes_temp(ii)));
    set(a, 'HorizontalAlignment', 'right');
    set(a, 'VerticalAlignment', 'middle');

end % for ii = 1:length(options.modes)

end %function plot_interp_data(interp_data,options) 

function interp_data = get_interp_data(slice_data,grid_size_to_plot)
if grid_size_to_plot > 4
    x = linspace(1,4,grid_size_to_plot);
    y = linspace(1,4,grid_size_to_plot);
    [xi, yi] = meshgrid(x, y);
    interp_data = interp2([1:4],[1:4],slice_data,xi,yi);
else
    interp_data = slice_data;
end %if grid_size_to_plot > length(options.modes)

interp_data = [interp_data; zeros(1, size(interp_data, 2)) ]       ;
interp_data = [interp_data, zeros(size(interp_data,1), 1)  ]       ;
end % function interp_data = get_interp_data(slice_data,options,grid_size_to_plot)




