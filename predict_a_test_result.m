%
function   predict_a_test_result(varargin)

% use a structure for the variable inputs
% function   predict_a_test_result(normalising_mode_index, std_bar_size, mode_pairs_to_Use ) Nargin = 3  
% predict_a_test_result(1,2,[8,9,14,16])
% function   predict_a_test_result(normalising_mode_index, std_bar_size, mode_pairs_to_Use,search_limits ) Nargin = 4 
% predict_a_test_result(1,2,[8,9,14,16],[0.65,0.9])
% function   predict_a_test_result(normalising_mode_index, std_bar_size, mode_pairs_to_Use,search_limits, DATA_PATH) Nargin = 5 
% function   predict_a_test_result(normalising_mode_index, std_bar_size, mode_pairs_to_Use,search_limits, DATA_PATH, FILE TO PREDICT) Nargin = 6
% predict_a_test_result(1,2,[8,9,14,16],[0.65,0.9],'P:\GITHUBS\AIDATA\Learning_block_2\Block_data_45_PP_4_L48_DV_1.mat','P:\GITHUBS\AIDATA\Learning_block_2\PD_CW_test_Jim_Evans__H4CE$3$_1.mat')
% use vargin and nargin
%nargin
%varargin


% display_plots = [0 0 0 1 0];
% diplay_txt = [1 0 0 0 1 1 1 1 0 0 0 ];

display_plots = [0 0 0 0 0];
diplay_txt = [0 0 0 0 0 0 0 0 0 0 0 ];

if nargin > 2  &&  nargin < 7
normalising_mode_index = varargin{1};
std_bar_size           = varargin{2};  
mode_pairs_to_Use      = varargin{3};  
search_limits  = NaN                ;
DATA_PATH      = NaN                ; 
FILE_TO_PREDICT  = NaN              ;

switch(nargin)
     case(4)
search_limits          = varargin{4};
    case(5)
search_limits          = varargin{4};
DATA_PATH              = varargin{5}; 
    case(6)
search_limits          = varargin{4};
DATA_PATH              = varargin{5}; 
FILE_TO_PREDICT        = varargin{6};   
    otherwise
end %switch(nargin)
else
end % if nargin > 2  &&  nargin < 7

% DATA_PATH




% DONE  ------    Do a log likelyhood prediction using PDF  
% DONE  ------    Do a ranking for "within STD range"  1 / 0  where std range is selected 
% (3)  combine them together to do a full analysis of the data  -  for all the
% tests

% predict_a_test_result(1,[3,6,8,9,14,16])   ----  standard run
% mode_pairs_to_Use = [3,6,8,9,14,16];       %  %  this will be an input argument 



% normalisation_mode_pair =  1               %  %  (1,1) this will be an input argument
mode_pairs=  [1,1;1,2;1,3;1,4;2,1;2,2;2,3;2,4;3,1;3,2;3,3;3,4;4,1;4,2;4,3;4,4];
labels = {'1-1','1-2','1-3','1-4','2-1','2-2','2-3','2-4','3-1','3-2','3-3','3-4','4-1','4-2','4-3','4-4'}; 

normalising_mode_pair =  mode_pairs(normalising_mode_index,:);
NumNeighbors = 3 ;
%std_bar_size = 1.5;
show_tag_mean_mode_plots = 0 ;

if isnan(DATA_PATH)
P_W_D = pwd ;
%  load a block data set 
cd('P:\GITHUBS\AIDATA')
%cd('C:\Users\Dev\OneDrive\shared from tti test\AIDATA')
[file_,path_]=uigetfile();
dummy =  open(strcat(path_,file_));
cd(P_W_D)

else
dummy =  open(strcat(DATA_PATH));
end




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


[spec_vals,file_name] =  Get_mode_values_from_a_test(Block_DATA.Peak_method, Block_DATA.Percentage_Peak , search_limits,FILE_TO_PREDICT,display_plots);


SV_crack_mode = spec_vals.crack_mode;
SV_crack_mode = SV_crack_mode./SV_crack_mode(normalising_mode_pair(1),normalising_mode_pair(2));
spec_vals_temp = reshape(SV_crack_mode, 1 , numel(SV_crack_mode));

[return_tag,score_,node_] = predict(AI_Block , spec_vals_temp(mode_pairs_to_Use));


[Score_vals]   = do_mean_std_plot(spec_vals_temp,Block_DATA,mode_pairs_to_Use,labels,std_bar_size,display_plots);
[score_table,log_lik_table, rank_table, within_range_table,std_dist_table, predict_tag]    = get_tag_scores (Score_vals,labels,mode_pairs_to_Use,Block_DATA.Labels_,std_bar_size);



if diplay_txt(1) ==1
disp('-----------------------------------------------------------------')
disp(file_name)
disp('-----------------------------------------------------------------')
end


if diplay_txt(2) ==1
disp(['Peak location: ',num2str(spec_vals.Peak_loc),' mm.'])
end
if diplay_txt(3) ==1
display_Block_data_stats(Block_DATA);
end

if diplay_txt(4) ==1
disp(['normalising_mode_pair: ',num2str(normalising_mode_pair(1)),'/',num2str(normalising_mode_pair(2)),'.'])
end

if diplay_txt(5) ==1
disp(['The AI predicts that this results is:   ', return_tag{1} ,' .'])
end

if diplay_txt(6) ==1
disp(['The statistical analysis predicts that the result is:   ',  predict_tag ,' .'])
end


if diplay_txt(7) ==1
disp('Dist from mean for each mode pair')
disp(score_table)
end

if diplay_txt(8) ==1
disp('-----------------------------------------------------------------')
disp('Log Likelyhood')
disp('-----------------------------------------------------------------')
disp(log_lik_table)
end

if diplay_txt(9) ==1
disp('Ranking for dist from mean')
disp(rank_table)
end


if diplay_txt(10) ==1
disp('-----------------------------------------------------------------')
disp(['Within range (+/- ',num2str(std_bar_size), ' * std.)'])
disp('-----------------------------------------------------------------')
disp(within_range_table)
disp('-----------------------------------------------------------------')
end

if diplay_txt(11) ==1
disp('-----------------------------------------------------------------')
disp('No. of STD dist from mean')
disp('-----------------------------------------------------------------')
disp(std_dist_table)
disp('-----------------------------------------------------------------')
disp('-----------------------------------------------------------------')
end


%if show_tag_mean_mode_plots == 1
%for index= 1: length(Block_DATA.Labels_)
%interp_data = get_interp_data(Block_DATA.mean_tag_modes_{index},50);
%plot_interp_data(interp_data,[Block_DATA.Labels_{index},':: BLOCK mean values(normalised to 1-1)'],0.8)
%end  % for index= 1: length(Block_DATA.Labels_)
%end %if show_tag_mean_mode_plots == 1

interp_data_2 = get_interp_data(spec_vals.crack_mode,50);
if display_plots(5) ==1
plot_interp_data(interp_data_2,'SPECIFIC TEST mode plot',0.8)
end %if display_plots(5) ==1


end  % function   predict_a_test_result

% have it so you dont have to select the boundaries  --  option to do
% manually or automatically
% check the FE get this bit correct

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

function [score_table,log_lik_table, rank_table,within_range_table,std_dist_table, predict_tag] = get_tag_scores (Score_vals,labels,mode_pairs_to_Use,Tags_,std_bar_size)

%log_lik_table   --   to be created


score_mat = zeros( length(Score_vals.Means_) , length(mode_pairs_to_Use) + 1 );
mean_mat = score_mat;
std_mat = score_mat;


% for index = 1 :length(Score_vals.Means_)
% Score_vals.Stds_{index})
% end
for index = 1 :length(Score_vals.Means_)
temp_ =  100 * abs((Score_vals.Means_{index}-Score_vals.spec_vals_ ));
% temp_ =   abs((Score_vals.Means_{index}-Score_vals.spec_vals_ )./Score_vals.Stds_{index});
score_mat(index,:) = [temp_,mean(temp_)];
end % for index = 1 :length(Score_vals.Means_)


for index = 1 :length(Score_vals.Means_)
temp_ = round(100*abs(log( Score_vals.Stds_{index}.*pdf('Normal',Score_vals. spec_vals_ , Score_vals.Means_{index},Score_vals.Stds_{index}))))/100;

log_lik(index,:) = [temp_,mean(temp_)];
end % for index = 1 :length(Score_vals.Means_)


for index = 1 :length(Score_vals.Means_)
temp_ =  Score_vals.Means_{index};
mean_mat(index,:) = [temp_,mean(temp_)];
end % for index = 1 :length(Score_vals.Means_)

for index = 1 :length(Score_vals.Means_)
temp_ =  Score_vals.Stds_{index};
std_mat(index,:) = [temp_,mean(temp_)];
end % for index = 1 :length(Score_vals.Means_)



std_within_range_mat = Score_vals.spec_vals_ <= mean_mat(:,1:end-1)+std_bar_size*std_mat(:,1:end-1) & Score_vals.spec_vals_ >= mean_mat(:,1:end-1)-std_bar_size*std_mat(:,1:end-1);
std_within_range_mat = [std_within_range_mat,mean(std_within_range_mat,2)];

std_dist_mat = abs((mean_mat(:,1:end-1) - Score_vals.spec_vals_))  ./ std_mat(:,1:end-1);  

std_dist_mat = [std_dist_mat,mean(std_dist_mat,2)];

std_dist_mat =  round(std_dist_mat*100)/100; 


columns__ =  [labels(mode_pairs_to_Use),{'Mean'}];

[~ ,Predict_index]  =  min(score_mat(:,end));

predict_tag = Tags_{Predict_index};

score_table = array2table(score_mat,...
       'VariableNames',columns__,...
       'RowNames',Tags_); 

log_lik_table = array2table(log_lik,...
       'VariableNames',columns__,...
       'RowNames',Tags_); 

within_range_table = array2table(std_within_range_mat,...
       'VariableNames',columns__,...
       'RowNames',Tags_); 

std_dist_table = array2table(std_dist_mat,...
       'VariableNames',columns__,...
       'RowNames',Tags_); 

vals__   =  [1:length(Tags_)]'     ;
rank_mat =  zeros(size(score_mat)) ;


for index = 1: size(score_mat,2) - 1

if  sum(score_mat(:,index)) == 0
% do nothing
else    
[~,b_] = sort(score_mat(:,index),'ascend');
dumb     = score_mat(:,index); 
dumb(b_) =  vals__ ;
rank_mat(:,index) = dumb;
end %if  sum(score_mat(:,index)) == 0

end  % for index = 1: size(score_mat,2)



for index = 1: size(rank_mat,1)
rank_mat(index,size(rank_mat,2)) =  sum(rank_mat(index,1:size(rank_mat,2)-1))/(size(rank_mat,2)-1); 
end %for index = 1: size(rank_mat,1)

rank_table = array2table(rank_mat   ,...
       'VariableNames',columns__      ,...
       'RowNames',Tags_); 

end %function Tag_scores_    = get_tag_scores (Score_vals);

function [Score_vals]  =  do_mean_std_plot(spec_vals_temp , Block_DATA , mode_pairs_to_Use,labels,std_bar_size,display_plots)

if display_plots(4) ==1
figure
end% if display_plots(4) ==1

val_nos_tmp = 1:16;

if display_plots(4) ==1
xBlanks = zeros(1, length(mode_pairs_to_Use));
axes('XTick', 1: length(mode_pairs_to_Use), 'XLim', [0,length(mode_pairs_to_Use)+1 ], 'XTickLabel', labels(mode_pairs_to_Use));
hold on
end %if display_plots(4) ==1


for index = 1: length(Block_DATA.Labels_)
mean_temp         =  reshape (Block_DATA.mean_tag_modes_{index},1,numel(Block_DATA.mean_tag_modes_{index}));
SD_temp           =  reshape (Block_DATA.std_tag_modes_{index},1,numel(Block_DATA.std_tag_modes_{index}));
if display_plots(4) ==1
errorbar(val_nos_tmp(1:length(mode_pairs_to_Use)),mean_temp(mode_pairs_to_Use),SD_temp(mode_pairs_to_Use)*std_bar_size,':o')
end%if display_plots(4) ==1
Means_{index} = mean_temp(mode_pairs_to_Use);
Stds_{index}  = SD_temp(mode_pairs_to_Use);
end %for index = 1: length(Block_DATA.Labels_)

if display_plots(4) ==1
plot(val_nos_tmp(1:length(mode_pairs_to_Use)),spec_vals_temp(mode_pairs_to_Use),'s','markersize',14)
legend([Block_DATA.Labels_,{'TEST'}],'location','EastOutside');
end %if display_plots(4) ==1

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




