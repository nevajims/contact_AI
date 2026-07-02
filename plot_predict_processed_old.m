function prediction_ = plot_predict_processed(varargin)

% prediction = [];
% deal with the  new input settings 
%(0)
% --  DONE
%
%
%

%(3)
%
%
%
%

% Deal with predition_colours  --  look at size of learning file and work
% from there

%
%  display in themode plot the position of on 33
%
% like the other:
% -  two options 
%-------------------------------------
%  nargin = 0
% --   select the file to predict
% --   select what to show  (do_plot)
%-------------------------------------
%  nargin = 3
%  varagin{1} rail_tester 
%  varagin{2} settings_
%  varagin{4} do_plots_
%-------------------------------------
switch(nargin)
    
    case(0)

% select the file to predict

settings_           = load_structure_from_file('plot_options2.dat');

settings_.DATA_PATH  = settings_.Data_path_options{settings_.Data_path_choice};


starting_dir                     =  'P:\GITHUBS\AIDATA';
P_W_D = pwd ;
if (exist('P:\GITHUBS\AIDATA')) == 7  
cd(starting_dir)
end %if (exist('P:\GITHUBS\AIDATA')) == 7  
[FILE_TO_PREDICT,file_path_] = uigetfile('*.mat',  'Selec the file to Predict','MultiSelect','off');
cd (P_W_D)

do_plots = [0 0 0 0 0 0 0 0 0] ;

plot_list =   {'Peak find','Mode pairs','Single Mode map','mean/std of modes','MM Viewer','Tag MMs','Predictions','DFM table','LL Table'};

do_plots_dum =  choose_plots_to_show(plot_list);
do_plots(find(do_plots_dum ==1)) = 1;

dummy_1              = load([file_path_,FILE_TO_PREDICT]);
grid_data            = fn_get_grid_data(dummy_1.rail_tester , settings_);

    case(4)
% prediction_ = plot_predict_processed(proc_file, settings_ ,do_plots, settings_.Data_path_options{settings_.Data_path_choice})        

proc_file            =  varargin{1}                                 ;   
settings_            =  varargin{2}                                 ;
do_plots             =  varargin{3}                                 ;
DP                   =  varargin{4}                                 ;    

settings_.DATA_PATH  =  DP;

% settings_.DATA_PATH  = settings_.Data_path_options{settings_.Data_path_choice};

rail_tester   =  proc_file.rail_tester                       ;
grid_data     = fn_get_grid_data(rail_tester , settings_) ;
FILE_TO_PREDICT = proc_file.test_data.file_with_path(max(find(proc_file.test_data.file_with_path =='\'))+1:end);

end  % switch(nargin)        

% ----------------------------------------------------
%other internal stuff
labels = {'1-1','1-2','1-3','1-4','2-1','2-2','2-3','2-4','3-1','3-2','3-3','3-4','4-1','4-2','4-3','4-4'};
mod_vals_inds = [1,1;1,2;1,3;1,4;2,1;2,2;2,3;2,4;3,1;3,2;3,3;3,4;4,1;4,2;4,3;4,4];
% ----------------------------------------------------

dummy = open(settings_.DATA_PATH) ;
Block_DATA = dummy.Block_DATA   ;

switch(length(Block_DATA.Labels_))
    case(2)
settings_.predition_colours      =    [1,3] ;  % 1 = green / 3 = red         
    case(3)
settings_.predition_colours      =    [1,2,3] ;  % 1 = green // 2 = yellow  // 3 = red         
    case(4)
settings_.predition_colours      =    [1,1,2,3] ;  % 1 = green // 2 = yellow  // 3 = red         
    case(5)
settings_.predition_colours      =    [1,1,2,2,3] ;  % 1 = green // 2 = yellow  // 3 = red         
    case(6)
settings_.predition_colours      =    [1,1,2,2,3,3] ;  % 1 = green // 2 = yellow  // 3 = red         
end %switch(length(Block_DATA.Labels_))




[slice_options,slice_indices] = get_slice_options(Block_DATA.max_number_of_slices) ;
[Slice_index,Thresh_index]  = get_index_value (settings_,Block_DATA,slice_options) ;  %  extract from the learning file


[mod_val,lower_val,upper_val,~]  =  get_peak_vals_and_plot(grid_data,settings_ ,do_plots(1));

% keyboard


if do_plots(2) ==1
plot_mode_pairs(mod_val, grid_data,labels,mod_vals_inds) 
end  %if do_plots(2) ==1

[ ~ , MP_mean,MP_std] =  get_normalised_stack_and_mean_P(lower_val,upper_val,grid_data.data_stack);

if do_plots(3) ==1
Plot_single_mode_map(MP_mean,settings_.MM_interp_res,settings_.db_range, FILE_TO_PREDICT(1:end-4),mod_val,grid_data,lower_val,upper_val)
end %if do_plots(3) ==1

if do_plots(4) ==1
Plot_mean_and_std_of_MM (MP_mean,MP_std,settings_.mode_pairs_to_Use,FILE_TO_PREDICT,labels)
end %if do_plots(4) ==1

if do_plots(5) ==1
raw_mode_map_viewer(grid_data,mod_val,settings_.MM_interp_res,settings_.db_range )
end

%------------------------------------------------------------------------------
%------------------------------------------------------------------------------
% Predictions
%------------------------------------------------------------------------------
%------------------------------------------------------------------------------
% LS = Learning set


LS_crack_mode_matrices = create_crack_mode_matrices(Block_DATA.crack_mode_ , Thresh_index, slice_indices{Slice_index});
% creates learning block on the fly
AI_Block  = Create_AI_learning_Block(settings_.NumNeighbors , settings_.mode_pairs_to_Use, LS_crack_mode_matrices  ,  Block_DATA.Labels_ , Block_DATA.tag_label_index );

%SV = specific value (the test to be predicted)
SV_crack_mode     = MP_mean ; 
SV_temp    = reshape(SV_crack_mode, 1 , numel(SV_crack_mode))  ;      

[ai_tag,~,~] = predict (AI_Block , SV_temp(settings_.mode_pairs_to_Use));

Block_DATA  =  add_means_and_std_of_tags_to_Block_DATA(Block_DATA,LS_crack_mode_matrices);

if do_plots(6) ==1
display_tag_mode_maps(Block_DATA,settings_)
end % if do_plots(6) ==1
Score_vals =  get_Score_vals(SV_temp,Block_DATA , settings_.mode_pairs_to_Use);

[DFM_table, LL_table, DFM_tag , LL_tag]    = get_tags_and_score_tables(Score_vals,labels,settings_.mode_pairs_to_Use,Block_DATA.Labels_);

prediction_.ai_tag  =  ai_tag{1}          ;
prediction_.DFM_tag =  DFM_tag            ;
prediction_.LL_tag  =  LL_tag             ;
prediction_.Labels  =  Block_DATA.Labels_  ;
prediction_.values  =  get_prediction_values(prediction_);
prediction_.colours =  settings_.predition_colours;

if do_plots(7) ==1
show_predictions(prediction_ ,settings_.predictions2use) ;    
end %if do_plots(7) ==1

if do_plots(8) ==1
show_dfm_table(DFM_table,length(settings_.mode_pairs_to_Use) );
end %if do_plots(7) ==1

if do_plots(9) ==1
show_LL_table(LL_table,length(settings_.mode_pairs_to_Use));
end %if do_plots(7) ==1

end %function predict_plot_processed()
%---------------------------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------------------------
% END OF MAIN
%---------------------------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------------------------
function do_plots =  choose_plots_to_show(plot_list)
[ones_,~] = listdlg('ListString',plot_list);
do_plots(ones_) = 1;
end %function do_plots =  choose_plots_to_show(plot_list);

function values_ = get_prediction_values(prediction_)

values_ = zeros(1,3);
for index = 1:length(prediction_.Labels)

if strcmp(prediction_.ai_tag, prediction_.Labels{index})
values_(1) = index;
end %if strcmp(prediction_.ai_tag, prediction_.Labels{index})

if strcmp(prediction_.DFM_tag, prediction_.Labels{index})
values_(2) = index;
end %if strcmp(prediction_.DFM_tag, prediction_.Labels{index})

if strcmp(prediction_.LL_tag, prediction_.Labels{index})
values_(3) = index;
end %if strcmp(prediction_.LL_tag, prediction_.Labels{index})

end %for index = 1:length(prediction_.Labels)

end %function values_ = get_prediction_values(prediction_)

function show_dfm_table(DFM_table,no_el)
h1 = figure;
TString = evalc('disp(DFM_table)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0.15 0.15 0.75 0.75],'FitBoxToText','on');
annotation(gcf,'Textbox','String', 'Distance from Mean Table', 'Position',[0.3 0.9 0.4 0.1],'FitBoxToText','on')

if no_el>10
 set(gcf, 'Position',  [100, 100, 1750, 250])
end%if no_el>10

end %function show_dfm_table(DFM_table)

function show_LL_table(LL_table,no_el)
h1 = figure;
TString = evalc('disp(LL_table)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0.15 0.15 0.75 0.75],'FitBoxToText','on');
annotation(gcf,'Textbox','String', 'Log Likelyhood Table', 'Position',[0.3 0.9 0.4 0.1],'FitBoxToText','on')

if no_el>10
 set(gcf, 'Position',  [100, 100, 1750, 250])
end%if no_el>10
end %function show_LL_table(LL_table)

function show_predictions(prediction_, predictions2use )
ai_tag  =  prediction_.ai_tag  ;
DFM_tag = prediction_.DFM_tag  ; 
LL_tag  = prediction_.LL_tag   ;
Labels  = prediction_.Labels   ;
values  = prediction_.values   ;
colours = prediction_.colours  ;


figure

if predictions2use(1)==1
AI_txt = ['AI Pred = ',ai_tag];
else
AI_txt = [];
end %if predictions2use(1)==1

if predictions2use(2)==1
DFM_txt = ['DFM Pred = ',DFM_tag];
else
DFM_txt = [];
end %if predictions2use(2)==1

if predictions2use(3)==1
LL_txt = ['LL Pred = ',LL_tag];
else
LL_txt = [];
end %if predictions2use(3)==1

dim1 = [0.15 0.5 0.3 0.3];
dim2 = [0.15 0.3 0.3 0.3];
dim3 = [0.15 0.1 0.3 0.3];

RGB_colours = [0,1,0; 1 0.5 0  ;1,0,0];
str1  = AI_txt   ;
str2  = DFM_txt  ;
str3  = LL_txt  ;

annotation('textbox',dim1,'String',str1,'FitBoxToText','on','FontSize',20,'color',RGB_colours(colours(values(1)),:));
annotation('textbox',dim2,'String',str2,'FitBoxToText','on','FontSize',20,'color',RGB_colours(colours(values(2)),:));
annotation('textbox',dim3,'String',str3,'FitBoxToText','on','FontSize',20,'color',RGB_colours(colours(values(3)),:));

winsize_ = get(gcf, 'Position');
set(gcf, 'Position',  [winsize_(1), winsize_(2), winsize_(3)/1.5,winsize_(4)/2])
annotation(gcf,'Textbox','String', 'PREDICTIONS', 'Position',[0.3 0.9 0.4 0.1],'FitBoxToText','on','FontSize',15)

end % function show_predictions(ai_tag, DFM_tag , LL_tag ,Labels_,predictions2use )

function  [DFM_table, LL_table, DFM_tag , LL_tag]    = get_tags_and_score_tables(Score_vals,labels,mode_pairs_to_Use,Tags_)

%DFM-------------Distance From mean-----------------------------------------

DFM_mat = zeros( length(Score_vals.Means_) , length(mode_pairs_to_Use) + 1 );

for index = 1 :length(Score_vals.Means_)
temp_ =  100 * abs((Score_vals.Means_{index}-Score_vals.spec_vals_ ));
DFM_mat(index,:) = [temp_,mean(temp_)];
end % for index = 1 :length(Score_vals.Means_)

columns__ =  [labels(mode_pairs_to_Use),{'Mean'}];
[~ ,DFM_index]  =  min(DFM_mat(:,end));

DFM_tag = Tags_{DFM_index};
DFM_table = array2table(DFM_mat,...
       'VariableNames',columns__,...
       'RowNames',Tags_); 
%DFM-------------Distance From mean-----------------------------------------

%LL---------------Log Likelyhood---------------------------------------
for index = 1 :length(Score_vals.Means_)
temp_ = round(100*abs(log( Score_vals.Stds_{index}.*pdf('Normal',Score_vals. spec_vals_ , Score_vals.Means_{index},Score_vals.Stds_{index}))))/100;
LL_mat(index,:) = [temp_,mean(temp_)];
end % for index = 1 :length(Score_vals.Means_)


LL_table = array2table(LL_mat,...
       'VariableNames',columns__,...
       'RowNames',Tags_); 

[~ ,LL_indx]  =  min(LL_mat(:,end));
LL_tag = Tags_{LL_indx};
%LL---------------Log Likelyhood---------------------------------------

end %function  [DFM_table,LL_table, DFM_tag , LL_tag]    = get_tags_score_tables(Score_vals,labels,mode_pairs_to_Use,Block_DATA.Labels_);

function Score_vals =  get_Score_vals(spec_vals_temp,Block_DATA , mode_pairs_to_Use)

for index = 1: length(Block_DATA.Labels_)
mean_temp         =  reshape (Block_DATA.mean_tag_modes_{index},1,numel(Block_DATA.mean_tag_modes_{index}));
SD_temp           =  reshape (Block_DATA.std_tag_modes_{index},1,numel(Block_DATA.std_tag_modes_{index}));
Means_{index} = mean_temp(mode_pairs_to_Use);
Stds_{index}  = SD_temp(mode_pairs_to_Use);
end %for index = 1: length(Block_DATA.Labels_)

Score_vals.Means_       =  Means_                              ;
Score_vals.Stds_        =  Stds_                               ; 
Score_vals.spec_vals_   =  spec_vals_temp(mode_pairs_to_Use)   ;
end %function Score_vals =  get_Score_vals(SV_temp,Block_DATA , settings_.mode_pairs_to_Use, labels)

function   display_tag_mode_maps(Block_DATA,settings_)
subplot_inds = [1,1;2,1;2,2;2,2;3,2;3,2];
LL_ = length(Block_DATA.Labels_);
fH = figure;

for index = 1: LL_
SB{index} = subplot(subplot_inds(LL_,1),subplot_inds(LL_,2),index) ;
do_the_mode_map(Block_DATA.mean_tag_modes_{index},Block_DATA.Labels_{index},settings_,SB{index},length(find(Block_DATA.tag_label_index == index)))

end %for index = 1: LL_

figure(fH)
tit_ins = settings_.DATA_PATH(max(find(settings_.DATA_PATH=='\'))+1:end-4); 
tit_ins(find(tit_ins=='_'))=' ';
sgtitle(['MM for learning set: ', tit_ins])

end %function   display_tag_mode_maps(Block_DATA)

function do_the_mode_map(slice_data,label,settings_, sb_handle,no_tests)

grid_size_to_plot = settings_.MM_interp_res   ;
db_range          = settings_.db_range        ;

if grid_size_to_plot > 4
    x = linspace(1,size(slice_data,1),grid_size_to_plot);
    y = linspace(1,size(slice_data,2),grid_size_to_plot);
    [xi, yi] = meshgrid(x, y);
    interp_data = interp2([1:size(slice_data,1)],[1:size(slice_data,2)],slice_data,xi,yi);
else
    interp_data = slice_data;
end %if grid_size_to_plot > length(options.modes)

interp_data = [interp_data; zeros(1, size(interp_data, 2)) ]       ;
interp_data = [interp_data, zeros(size(interp_data,1), 1)  ]       ;

subplot(sb_handle)


colormap default;
surf(interp_data);
view(2);
axis equal;
shading flat;
axis off;
caxis([0, db_range]);

%colorbar;
    sf = grid_size_to_plot / 4;
    offset = grid_size_to_plot / grid_size_to_plot;
modes_temp = [1,2,3,4];
for ii = 1:4
    a = text((ii - 0.5) * sf + 1, - offset + 1, sprintf('%i',modes_temp(ii)));
    set(a, 'HorizontalAlignment', 'center');
    set(a, 'VerticalAlignment', 'top');

    a = text(-offset + 1, (ii - 0.5) * sf + 1, sprintf('%i',modes_temp(ii)));
    set(a, 'HorizontalAlignment', 'right');
    set(a, 'VerticalAlignment', 'middle');

end % for ii = 1:length(options.modes)

title(['Tag = ',label,', (',num2str(no_tests),')'])

end %function do_the_mode_map(map,label,sb_handle)

function  Block_DATA  =  add_means_and_std_of_tags_to_Block_DATA(Block_DATA,LS_crack_mode_matrices)

for index = 1:length(Block_DATA.Labels_)
tag_indicies                   = find(Block_DATA.tag_label_index == index);
tag_modes_ =   LS_crack_mode_matrices(:,:,tag_indicies);
mean_temp = mean(tag_modes_ , 3) ;
mean_tag_modes_{index}         = mean_temp;
std_temp = std(tag_modes_,0,3)  ;
std_tag_modes_{index}          = std_temp;
end %for index = 1:length(Labels_)
Block_DATA.mean_tag_modes_ = mean_tag_modes_;
Block_DATA.std_tag_modes_  = std_tag_modes_;
end %function  Block_DATA  =  add_means_and_std_of_tags_to_Block_DATA(Block_DATA,labels,LS_crack_mode_matrices)

function AI_Block  = Create_AI_learning_Block(NumNeighbors_,mode_pairs_to_Use, all_modes,Labels_,tag_label_index)
mode_block_2d = reshape(all_modes,16,length(all_modes))';
Data_mat = mode_block_2d(:,mode_pairs_to_Use);
tags_ = Labels_(tag_label_index)';
AI_Block = fitcknn(Data_mat,tags_,"Standardize",true,'NumNeighbors',NumNeighbors_ ,'Distance','cityblock');
end %function AI_Block  = Create_AI_learning_Block()

function crack_mode_matrix = create_crack_mode_matrices (crack_mode_,Thresh_index, slice_ind)

crack_mode_matrix = zeros(4,4,length(crack_mode_));

for index = 1:length(crack_mode_)
dum = crack_mode_{index}{Thresh_index}(:,:,slice_ind);
crack_mode_matrix(:,:,index) = mean(dum,3);
end %for index = 1:length(crack_mode_)

end %function crack_mode_matrix = create_crack_mode_matrix(Block_DATA.crack_mode_,Thresh_index, slice_indices);




function raw_mode_map_viewer(grid_data,mod_val,MM_interp_res,db_range)

fH = figure ;
%sp1 = subplot(8,3,1:3)   ;
%sp2 = subplot(8,3,7:24)  ;

sp1 = subplot(8,6,1:6)            ;
sp2 = subplot(8,6,[14,15,16,17,20,21,22,23,26,27,28,29,32,33,34,35,38,39,40,41,44,45,46,47]) ;

plot_data_structure.dv = grid_data.distance_vector;
plot_data_structure.mod_val = mod_val;
plot_data_structure.mod_val_variable = mod_val;
plot_data_structure.mm_33  = squeeze(grid_data.data_stack(3,3,:));
plot_data_structure.data_stack= grid_data.data_stack;
plot_data_structure.MM_interp_res = MM_interp_res;
plot_data_structure.db_range = db_range;
plot_data_structure.fH = fH;
plot_data_structure.sp1  =  sp1;
plot_data_structure.sp2  =  sp2; 


Popup1 = uicontrol(fH, 'Style', 'slider', 'String', '1', ...
  'Position', [0 5 400 10], ...
  'CallBack', @change_MM_dist, ......
  'SliderStep',[0.0002,0.002],...
  'Value', mod_val/length(plot_data_structure.dv), ...
  'UserData', 0);

txt_handle = uicontrol(fH, 'Style', 'text',...
  'Position', [10 20 70 20], ...
  'string',[num2str(round(1000*plot_data_structure.dv(mod_val))),'mm'],...
  'FontSize', 12 ,...
  'UserData', 0);

%Button1 = uicontrol(fH, 'Style', 'pushbutton', 'String', 'Update Plot', ...
%  'Position', [450 5 80 40], ...
%  'CallBack', @update_MM_plot, ......
%  'UserData', 0);


Button2 = uicontrol(fH, 'Style', 'pushbutton', 'String', 'Reset', ...
  'Position', [5 50 40 40], ...
  'CallBack', @reset_MM_plot, ......
  'UserData', 0);

plot_data_structure.txt_handle = txt_handle;
plot_data_structure.Popup1     = Popup1;

fH.UserData = plot_data_structure;
update_top_plot(plot_data_structure)    ;
update_bottom_plot(plot_data_structure) ;
end %function raw_mode_map_viewer(grid_data )

function update_top_plot(plot_data_structure)
dv = plot_data_structure.dv ;
mod_val = plot_data_structure.mod_val ;
mod_val_variable = plot_data_structure.mod_val_variable;
mm_33 = plot_data_structure.mm_33;
sp1 = plot_data_structure.sp1;

subplot(sp1)
hold off
plot(dv ,mm_33)
hold on
y_lim = ylim;
plot([dv(mod_val) dv(mod_val)] ,[y_lim(1) y_lim(2)],'k')
plot([dv(mod_val_variable) dv(mod_val_variable)] ,[y_lim(1) y_lim(2)],'r')
legend('M3-3','MM','MM view','Location','westoutside')
x_lim = xlim;
xticks([x_lim(1):1:x_lim(2)])
title('Mode 3-3 ')
xlabel('Distance(m)')


end

function update_bottom_plot(plot_data_structure)
dv = plot_data_structure.dv ;
mod_val_variable = plot_data_structure.mod_val_variable;
data_stack =plot_data_structure.data_stack;
grid_size_to_plot = plot_data_structure.MM_interp_res;
db_range =plot_data_structure.db_range;
sp2 = plot_data_structure.sp2;

slice_data = data_stack(:,:,mod_val_variable);
slice_data = slice_data/mean(mean(slice_data));

if grid_size_to_plot > 4
    x = linspace(1,size(slice_data,1),grid_size_to_plot);
    y = linspace(1,size(slice_data,2),grid_size_to_plot);
    [xi, yi] = meshgrid(x, y);
    interp_data = interp2([1:size(slice_data,1)],[1:size(slice_data,2)],slice_data,xi,yi);
else
    interp_data = slice_data;

end %if grid_size_to_plot > length(options.modes)

interp_data = [interp_data; zeros(1, size(interp_data, 2)) ]       ;
interp_data = [interp_data, zeros(size(interp_data,1), 1)  ]       ;

subplot(sp2)

hold off
colormap default;
surf(interp_data);
view(2);
%axis equal;
shading flat;
axis off;
caxis([0, db_range]);
%colorbar;
title(['@  ',num2str(round(dv(mod_val_variable)*1000)),' mm. (unaveraged)'])

    sf = grid_size_to_plot / 4;
    offset = grid_size_to_plot / grid_size_to_plot;
modes_temp = [1,2,3,4];
for ii = 1:4
    a = text((ii - 0.5) * sf + 1, - offset + 1, sprintf('%i',modes_temp(ii)));
    set(a, 'HorizontalAlignment', 'center');
    set(a, 'VerticalAlignment', 'top');

    a = text(-offset + 1, (ii - 0.5) * sf + 1, sprintf('%i',modes_temp(ii)));
    set(a, 'HorizontalAlignment', 'right');
    set(a, 'VerticalAlignment', 'middle');

end % for ii = 1:length(options.modes)
sgtitle('Unaveraged mode map viewer')

end %function update_bottom_plot(plot_data_structure)

function reset_MM_plot(hObject, ~)

plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
plot_data_structure.mod_val_variable = plot_data_structure.mod_val;
plot_data_structure.txt_handle.String = [num2str(round(1000*plot_data_structure.dv(plot_data_structure.mod_val))),'mm'];
plot_data_structure.Popup1.Value = plot_data_structure.mod_val/length(plot_data_structure.dv);
update_top_plot(plot_data_structure)    ;
update_bottom_plot(plot_data_structure) ;
set(get(hObject,'Parent'),'UserData',plot_data_structure);

end

%function update_MM_plot(hObject, ~)
%plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
%update_top_plot(plot_data_structure)    ;
%update_bottom_plot(plot_data_structure) ;
%end

function change_MM_dist(hObject, ~)
new_value =  get(hObject,'Value');
if new_value == 0; new_value=0.0001;end

plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
plot_data_structure.mod_val_variable  = ceil(new_value*length(plot_data_structure.dv));
plot_data_structure.txt_handle.String = [num2str(round(plot_data_structure.dv(plot_data_structure.mod_val_variable)*1000)),'mm'];

update_top_plot(plot_data_structure)    ;
update_bottom_plot(plot_data_structure) ;



set(get(hObject,'Parent'),'UserData',plot_data_structure);
end






function Plot_mean_and_std_of_MM (MP_mean,MP_std,mode_pairs_to_Use,file_name,labels )
figure

std_bar_size = 1;
val_nos_tmp = 1:16;
spec_vals_means = reshape(MP_mean, 1 , numel(MP_mean));
spec_vals_std = reshape(MP_std, 1 , numel(MP_std));
file_name(find(file_name =='_')) = ' ';
xBlanks = zeros(1, length(mode_pairs_to_Use));

axes('XTick', 1: 16, 'XLim', [0,17], 'XTickLabel', labels);
%axes('XTick', 1: length(mode_pairs_to_Use), 'XLim', [0,length(mode_pairs_to_Use)+1 ], 'XTickLabel', labels(mode_pairs_to_Use));

hold on
errorbar(val_nos_tmp,spec_vals_means,spec_vals_std*std_bar_size,':o')
errorbar(mode_pairs_to_Use,spec_vals_means(mode_pairs_to_Use),spec_vals_std(mode_pairs_to_Use)*std_bar_size,'rs','markersize',15)
legend('All Modes','Prediction Modes')
title(['Prediction modes vals: ',file_name(1:end-4)])

end %function Plot_mean_and_std_of_MM (MP_mean,MP_std,settings_.mode_pairs_to_Use )

function Plot_single_mode_map(slice_data,grid_size_to_plot,db_range,filename_ , mod_val , grid_data , lower_val , upper_val)
%,mod_val,grid_data,lower_val,upper_val
dv =grid_data.distance_vector;

if grid_size_to_plot > 4
    x = linspace(1,size(slice_data,1),grid_size_to_plot);
    y = linspace(1,size(slice_data,2),grid_size_to_plot);
     %x = linspace(1,4,grid_size_to_plot);
    %y = linspace(1,4,grid_size_to_plot);
     
    [xi, yi] = meshgrid(x, y);
    interp_data = interp2([1:size(slice_data,1)],[1:size(slice_data,2)],slice_data,xi,yi);
else
    interp_data = slice_data;

end %if grid_size_to_plot > length(options.modes)

interp_data = [interp_data; zeros(1, size(interp_data, 2)) ] ;
interp_data = [interp_data, zeros(size(interp_data,1), 1)  ] ;
figure
colormap default;
surf(interp_data);
view(2);
axis equal;
shading flat;
axis off;
caxis([0, db_range]);
colorbar;

filename_ = remove_(filename_);
title(['MM:  ',filename_,  'value at ave between ',num2str(1000*dv( lower_val)),'mm and ',num2str(1000*dv( upper_val)), 'nn.  mid:',num2str(1000*dv( mod_val)),'mm.'] )



    sf = grid_size_to_plot / 4;
    offset = grid_size_to_plot / grid_size_to_plot;

modes_temp = [1,2,3,4];

for ii = 1:4
    a = text((ii - 0.5) * sf + 1, - offset + 1, sprintf('%i',modes_temp(ii)));
    set(a, 'HorizontalAlignment', 'center');
    set(a, 'VerticalAlignment', 'top');

    a = text(-offset + 1, (ii - 0.5) * sf + 1, sprintf('%i',modes_temp(ii)));
    set(a, 'HorizontalAlignment', 'right');
    set(a, 'VerticalAlignment', 'middle');

end % for ii = 1:length(options.modes)
end %function Plot_single_mode_map(MP_mean)

function [ MP_stack,MP_mean,MP_std ] = get_normalised_stack_and_mean_P(lower_val,upper_val,mode_map)    
MP_stack = zeros(4,4,upper_val-lower_val);
count = 0;
for index = lower_val:upper_val
count = count + 1;
temp_MM =mode_map(:,:,index);
MP_stack(:,:,count) = temp_MM;
MP_stack(:,:,count) = temp_MM/ mean(mean(temp_MM));
end  % for index = lower_val:upper_val
MP_mean = mean(MP_stack,3)  ;

MP_std  =  std(MP_stack,[],3)  ;
end %function [MP_stack,MP_mean] = get_normalised_stack_and_mean(lower_val,upper_val,mode_map)

function plot_mode_pairs(mod_val, grid_data,labels_,mod_val_inds) 

mode_map                   = grid_data.data_stack                   ;
fig_H = figure;

Popup1 = uicontrol(fig_H, 'Style', 'popupmenu', 'String', '1', ...
  'Position', [0 40 50 40], ...
  'CallBack', @change_MP1, ......
  'Value', 1, ...
  'UserData', 0);
Popup1.String = labels_;

Popup2 = uicontrol(fig_H, 'Style', 'popupmenu', 'String', '1', ...
  'Position', [0 40 50 0], ...
  'CallBack', @change_MP2, ...
  'Value', 11, ...
  'UserData', 0);
Popup2.String = labels_;

plot_data_structure.mode_map                    = mode_map                               ;
plot_data_structure.fig_H                       = fig_H                                  ;
plot_data_structure.Row_ind1                    = 1                                     ;
plot_data_structure.Col_ind1                    = 1                                     ;
plot_data_structure.Row_ind2                    = 3                                     ;
plot_data_structure.Col_ind2                    = 3                                     ;
plot_data_structure.dv                          = grid_data.distance_vector              ;  
plot_data_structure.mm_33                       = squeeze(mode_map(3,3,:))               ;
plot_data_structure.mod_val                     = mod_val                                ; 
plot_data_structure.mod_val_inds                = mod_val_inds                          ;  
fig_H.UserData = plot_data_structure;

update_mode_plot(plot_data_structure);

end %function plot_mode_pairs(  ) 

function change_MP1(hObject, ~)
new_value =  get(hObject,'Value');
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
plot_data_structure.Row_ind1 = plot_data_structure.mod_val_inds(new_value,1);
plot_data_structure.Col_ind1 = plot_data_structure.mod_val_inds(new_value,2);
update_mode_plot(plot_data_structure)  
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end %function change_row(hObject, ~)

function change_MP2(hObject, ~)
new_value =  get(hObject,'Value');
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
plot_data_structure.Row_ind2 = plot_data_structure.mod_val_inds(new_value,1);
plot_data_structure.Col_ind2 = plot_data_structure.mod_val_inds(new_value,2);
update_mode_plot(plot_data_structure)  
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end %function change_row(hObject, ~)

function update_mode_plot(plot_data_structure)
mode_map      = plot_data_structure.mode_map ;
fig_H         = plot_data_structure.fig_H    ;
Row_ind1      = plot_data_structure.Row_ind1  ;
Col_ind1      = plot_data_structure.Col_ind1  ;
Row_ind2      = plot_data_structure.Row_ind2  ;
Col_ind2      = plot_data_structure.Col_ind2  ;
dv            = plot_data_structure.dv       ;  
mm_33         = plot_data_structure.mm_33    ;
mod_val       = plot_data_structure.mod_val             ; 
figure(fig_H)
mm_temp1  = squeeze(mode_map(Row_ind1,Col_ind1,:)) ; 
mm_temp2  = squeeze(mode_map(Row_ind2,Col_ind2,:)) ; 

hold off
plot(dv,mm_temp1,'k')
hold on
plot(dv,mm_temp2,'r:')
%ylim([0,max(max(max(mode_map)))])
ylims_ = ylim; 
plot([dv(mod_val) dv(mod_val)],[ylims_(1) ylims_(2)])
legend(['Mod ',num2str(Row_ind1),num2str(Col_ind1)],['Mod ',num2str(Row_ind2),num2str(Col_ind2)] ,['mode map val(',num2str(round(dv(mod_val)*1000)),' mm).' ] )
xlabel('Distance (m)')
title(['Full range plots (Mod ',num2str(Row_ind1),'-',num2str(Col_ind1),' Mod ',num2str(Row_ind2),'-',num2str(Col_ind2),')']) 

end %function update_mode_plot(plot_data_structure)

function  [mod_val,lower_val,upper_val,actual_peak_val]  =  get_peak_vals_and_plot(grid_data,settings_ , do_plot)
%--------------------------------------------------------------------------------------------
% function [mod_val  , lower_val  ,  upper_val  ,  actual_peak_val]  =  get_peak_values( )
%--------------------------------------------------------------------------------------------

initial_thresh = settings_.initial_thresh                 ;
thresh_val     = settings_.thresh_val                     ;
num_slices     = settings_.num_slices                     ;
window_start   = settings_.window_start                   ;    

mode_map             = grid_data.data_stack               ;

mm33                 = squeeze(mode_map(3,3,:))           ;
dv                   = grid_data.distance_vector          ;  


start_val       =   min(find(dv>window_start)) + min(find(mm33(find(dv>window_start))  >   max(mm33(find(dv>window_start)))*initial_thresh))-1;

mm33_s = mm33(start_val:start_val+200);
mm33_s_diff = diff(mm33_s);
dum_ = find(mm33_s_diff>0);
DV2 = dum_(find(diff(dum_)>1));
actual_peak_val = DV2(1)+ start_val;
actual_max_val = mm33(actual_peak_val);
target_val=  actual_max_val*thresh_val;

temp_val = actual_peak_val;
peak_found =0;
while peak_found ==0
temp_val = temp_val -1;
if mm33(temp_val) <= target_val
   mod_val = temp_val;
   peak_found =1;
end    

end % while peak_not_found ==1
lower_val     =   mod_val-floor(num_slices/2);
upper_val     =   mod_val+floor(num_slices/2);

if do_plot ==1
plot(dv,mm33)
hold on

%plot(dv(start_val),mm33(start_val),'g.','markersize',20)
plot(dv(actual_peak_val),mm33(actual_peak_val),'g.','markersize',10)

plot(dv(mod_val),mm33(mod_val),'rs','markersize',10)

plot(dv(lower_val),mm33(lower_val),'r.','markersize',10)
plot(dv(upper_val),mm33(upper_val),'r.','markersize',10)

xlim([0 round(max(dv))])
ylim([0 1.2*max( mm33(find(dv>0)))])
xlabel('Dist (m)')
ylabel('M33 Amplitude')
title(['Dist loc for mode map'  ])    %  get the file name
ylim_s =  ylim;
xlim_s =  xlim;

plot([window_start window_start], [ylim_s(1) ylim_s(2)], 'r:')
plot([xlim_s(1) xlim_s(2)], [max(mm33(find(dv>window_start)))*initial_thresh max(mm33(find(dv>window_start)))*initial_thresh], 'b:')

legend('M33','Peak','Mode centre val', 'av start','av end','Xgate','Ygate')

end % if do_plot ==1

end % function [mod_val  , lower_val  ,  upper_val  ,  actual_peak_val]  =  get_peak_values(dv,mm33,initial_thresh,thresh_val,num_slices)

function  [Slice_index,Thresh_index]  = get_index_value (settings_,Block_DATA,slice_options)
Slice_index  =   find(slice_options ==  settings_. num_slices);
Thresh_index =  find(Block_DATA.threshold_value == settings_.thresh_val);
end

function [slice_options ,  slice_indices] = get_slice_options(max_number_of_slices)
slice_options = [1:2:max_number_of_slices];
central_val = ceil(max_number_of_slices/2);
for index = 1: length(slice_options)
amount_to_PM = floor(slice_options(index)/2);
slice_indices{index} =  [(central_val-amount_to_PM): (central_val+amount_to_PM)];
end %for index = 1: length(slice_options)
%slice_indices
end %function slice_options = get_slice_options(Block_DATA.max_number_of_slices);



