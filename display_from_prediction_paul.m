function  display_from_prediction_paul(varargin)

%---------------------------------------------------------------------
% (1)---  create a program for alva for producing quality indicators
% (2)---  create an overall ranking for each mode pair  -  sum of the rankings for

% all types

% (3)---  rejection critreria:  multiple yellows for HFN or LWN 
%---------------------------------------------------------------------

% DONE *********************  check the DIST from mean ranking colormap-  not correct
% DONE***** DATA QUALITY TABLES
% DONE***** (1) chan amp maps 
% DONE***** (2) chan amps
% DONE***** (3) frequency plots ----   
% DONE***** (4) signal to noise 

% PREDICTION Values
% DONE***** (1) overall predictions divided by group 
% DONE***** (2) individual mode predictions   
% (3) 
% (4)

% PREDICTION tables 
% PREDICTIOn PERFORMANCE
% (1)
% (2)
% (3)

%  put in individual  do plots for all the plots
%  make a selection boundary for acceptance- SNR /  LFN /  HFN

plot_list = {'mode sel pt', 'sel mode pairs', 'stat mode plot','mode maps','chan RMS map','chan RMS bars', 'chan SNR map','chan SNR bars','Time Traces','fft traces','LFN Maps','LFN Bars','HFN Maps','HFN Bars','colormap predictions','predictions table','Signal Quality indicators','cons Prediction table', 'prediction scores' } ;

do_plots = zeros(1,19);
[ones_,~] = listdlg('ListString',plot_list);

do_plots(ones_) = 1;


RMS_boundaries =  [0.1 , 0.25 ,   0.6];
%SNR_boundaries = [ 0.3   , 1   ,   2];
SNR_boundaries =  [ 0.1   , 1   ,   2];
LFN_boundaries =  [-1   ,-2   ,    -5];  %  Green / Yellow / Orange / Red   ---- GOOD :: BAD 
HFN_boundaries =  [-1   ,-2   ,    -5];


% get the bar values from the fundtion
% put them into 


do_colormap_plots     =   do_plots(15)  ;
do_prediction_table   =   do_plots(16)  ;
do_prediction2_table  =   do_plots(18)  ;
do_prediction_scores  =   do_plots(19)  ;



sub_plots_inds = [1,1 ; 2,1 ; 3,1 ; 2,2 ; 3,2 ; 3,2 ; 4,2 ; 4,2 ; 3,3; 3,4; 3,4; 3,4 ; 4,4 ; 4,4 ; 4,4 ; 4,4; 4,5; 4,5; 4,5; 4,5; 5,5; 5,5; 5,5; 5,5; 5,5; ...
6,5;6,5;6,5;6,5;6,5;6,6;6,6;6,6;6,6;6,6;6,6;6,7;6,7;6,7;6,7;6,7;6,7;7,7;7,7;7,7;7,7;7,7;7,7;7,7;7,7;7,8;7,8;7,8;7,8;7,8;7,8;7,8];


labels = {'1-1','1-2','1-3','1-4','2-1','2-2','2-3','2-4','3-1','3-2','3-3','3-4','4-1','4-2','4-3','4-4'};

mp_vals_2use_mean1_or_max0  = 1 ;
db_range               =  1.6;
int_VAL                =  12;
res_start              =  200;
sig_amp_min            =  0.25;
SNR_bandwidth_kHz     =  21  ; 

%SNR_bandwidth_kHz      =  15  ; 

use_lin_or_DB          =  2  ;   % 1 = lin,  2 = DB
diagonal_gate          =  60  ;
exitation_freq         =  50;       

%diagonal_gate     =  1;

% modes_to_plot = [1,6,11,8,14]; 
modes_to_plot = 1:16;
max_rank = 2.9   ;
do_LL_bars = 0   ; 
do_DFM_bars = 0  ;


switch(nargin)
    case(0)
P_W_D = pwd;
cd('P:\GITHUBS\AIDATA') 
[FILES_TO_PREDICT,file_path_] = uigetfile('*.mat',  'Selec the comp file','MultiSelect','off') ;
dum =  load([file_path_,FILES_TO_PREDICT]);
cd (P_W_D);

comp_data = dum.compiled_data;   
    case(1)
comp_data =   varargin{1};
end % switch(nargin)

dum2 = load(comp_data.settings_.DATA_PATH);
Block_DATA   =   dum2.Block_DATA  ;
clear dum; clear dum2 ; clear varargin ;

%------------------------------------------------------
disp('-----------------------------------------------------------------')
disp(['Data coming from...',file_path_,FILES_TO_PREDICT])
fprintf(comp_data.settings_.s_TXT_)

temp_struct = comp_data.PREDICT_STRUCT;
temp_struct.FILENAME = categorical(temp_struct.FILENAME);
PREDICT_Table = struct2table(temp_struct);


PREDICT2_Table = struct2table(comp_data.PREDICT2_STRUCT);


if do_prediction_table ==1
disp('-------------------------------------------------------------------------------------------------------------------------------------')
disp(PREDICT_Table)
disp('-------------------------------------------------------------------------------------------------------------------------------------')
end % if do_prediction_table == 1

if do_prediction2_table   ==1
disp('-------------------------------------------------------------------------------------------------------------------------------------')
disp(PREDICT2_Table)
disp('-------------------------------------------------------------------------------------------------------------------------------------')
end % if do_prediction2_table   ==1



if do_prediction_scores   == 1
pred_score          =        comp_data.pred_score          ;
pred_consitancy     =        comp_data.pred_consitancy     ; 

disp('-------------------------------------------------------------------------------------------------------------------------------------')
disp(['Prediction rating: ',num2str(pred_score(3)),'%, (',num2str(pred_score(1)),'/',num2str(pred_score(2)),').'])
disp(['Prediction consistancy: ',num2str(pred_consitancy(3)),'%, (',num2str(pred_consitancy(1)),'/',num2str(pred_consitancy(2)),').'])
disp('-------------------------------------------------------------------------------------------------------------------------------------')
end % do_prediction_scores   == 1






file_indices =  get_descriptor_indices(comp_data,Block_DATA);
file_groups =  unique(file_indices.file_label_number);


if do_plots(1) ==1

figs1             =   plot_mode_selection_points(file_indices , comp_data , sub_plots_inds,Block_DATA); 

end %if do_plots(1) ==1


if do_plots(2) ==1
figs2             =   plot_selected_mode_pairs(file_indices , comp_data , sub_plots_inds,Block_DATA , modes_to_plot,labels ); 
end% if do_plots(2) ==1

if do_plots(3) ==1
figs3             =   do_statistical_mode_plot(file_indices , comp_data , sub_plots_inds,Block_DATA ,labels,mp_vals_2use_mean1_or_max0 ); 
end %if do_plots(2) ==1



if do_plots(4) ==1
figs4             =   plot_mode_maps (file_indices , comp_data , sub_plots_inds,Block_DATA , modes_to_plot,labels,mp_vals_2use_mean1_or_max0,db_range); 
end %if do_plots(2) ==1




%if do_plots(5) ==1
%[figH_5 , figH_6] = plot_chan_maps(file_indices , comp_data , sub_plots_inds,Block_DATA , labels,res_start,int_VAL);
%end %if do_plots(2) ==1

%[figH_8,RMS_bars]            =   plot_chan_amps(file_indices , comp_data , sub_plots_inds,Block_DATA , labels,res_start,sig_amp_min,do_plots(6) , RMS_boundaries);





%SNR_boundaries 
%LFN_boundaries 
%HFN_boundaries 


[figH_9,figH_10,figH_11,figH_12,figH_13,figH_14,figH_15,figH_16,RMS_bars,SNR_bars,LFN_bars,HFN_bars]        =   plot_signal_2_noise(file_indices , comp_data , sub_plots_inds,Block_DATA , labels,res_start,sig_amp_min,SNR_bandwidth_kHz,int_VAL,use_lin_or_DB,diagonal_gate,exitation_freq,do_plots,...
...
RMS_boundaries,SNR_boundaries,LFN_boundaries,HFN_boundaries);
[rejection_indicators, figH17] = create_rejection_indicators(RMS_bars,SNR_bars,LFN_bars,HFN_bars,RMS_boundaries,SNR_boundaries,LFN_boundaries,HFN_boundaries,file_indices,comp_data,Block_DATA,sub_plots_inds,do_plots(17)) ;





for index = 1:length(file_groups)

current_file_inds =  find(file_indices.file_label_number == file_groups(index));

if do_LL_bars==1
fig{index} = figure ; 
else
fig{index} = NaN;
end

if do_DFM_bars==1
fig{length(file_groups) + index} = figure ; 
else
fig{length(file_groups) + index} = NaN;
end

%PTI = Predicted type index         ROA =  Ranking of Actual 

LL_PTI_T   = zeros(length(current_file_inds),length(comp_data.settings_.mode_pairs_to_Use)+1);
LL_ROA_T   = zeros(length(current_file_inds),length(comp_data.settings_.mode_pairs_to_Use)+1);

DFM_PTI_T   = zeros(length(current_file_inds),length(comp_data.settings_.mode_pairs_to_Use)+1);
DFM_ROA_T   = zeros(length(current_file_inds),length(comp_data.settings_.mode_pairs_to_Use)+1);



if do_LL_bars==1
sgtitle(    ['Log Likelyhood predictions  group : ',Block_DATA.Labels_{file_groups(index)}])
hold on
end

if do_DFM_bars==1
sgtitle(    ['Distance From Mean predictions  group : ',Block_DATA.Labels_{file_groups(index)}])
hold on
end

for  index_2 = 1:length(current_file_inds)

cur_ind = current_file_inds(index_2);




[predicted_tag_index_temp , ranking_of_actual_temp]      = create_bar_from_Pred(fig{index}, comp_data.OP{cur_ind}.log_lik_table ,...
file_indices.f_names{cur_ind}, Block_DATA.conversion_key(file_indices.file_label_number(cur_ind)) , Block_DATA.Labels_, sub_plots_inds,length(current_file_inds),index_2,do_LL_bars ) ;


%if index==3
    %keyboard
%end


LL_PTI_T(index_2,:) = predicted_tag_index_temp;
LL_ROA_T(index_2,:) = ranking_of_actual_temp';


[predicted_tag_index_temp_2 , ranking_of_actual_temp_2]  = create_bar_from_Pred(fig{length(file_groups)}, comp_data.OP{cur_ind}.std_dist_table,...
    file_indices.f_names{cur_ind}, Block_DATA.conversion_key(file_indices.file_label_number(cur_ind)) , Block_DATA.Labels_, sub_plots_inds,length(current_file_inds),index_2,do_DFM_bars ) ;

DFM_PTI_T(index_2,:) = predicted_tag_index_temp_2;
DFM_ROA_T(index_2,:) = ranking_of_actual_temp_2;




end %for  index_2 = 1 length(current_file_inds)


%disp(['DFM size = ', num2str(size(LL_PTI_T,1)),' , ', num2str(size(LL_PTI_T,2))])
%disp(['LL size = ', num2str(size(DFM_PTI_T,1)),' , ',    num2str(size(DFM_PTI_T,2)) ])



LL_PTI{index}  = LL_PTI_T;
LL_ROA{index}  = LL_ROA_T;

DFM_PTI{index} = DFM_PTI_T;
DFM_ROA{index} = DFM_ROA_T;

%fig{index};

if do_LL_bars ==1
leg_ = legend(Block_DATA.Labels_);
fig{index}.Position(3)=fig{index}.Position(3)+400;
leg_.Position = [0.04,0.3543,0.05,0.45000];
end

end %for index = 1:length(file_groups)

if do_colormap_plots ==1




plot_colormap(LL_PTI,LL_ROA,comp_data.settings_.mode_pairs_to_Use,   Block_DATA.Labels_   , labels, Block_DATA.conversion_key(file_groups) ,  max_rank,'log Likelyhood')
plot_colormap(DFM_PTI,DFM_ROA,comp_data.settings_.mode_pairs_to_Use, Block_DATA.Labels_ , labels,  Block_DATA.conversion_key(file_groups)  ,  max_rank,'Distance from mean')
end %if do_colormap_plots ==1

%predicted_tag_index_temp , ranking_of_actual_temp
% sub_plots_inds(1,:)
%do the overall table

end %function  display_from_prediction(varargin)

function    [rejection_indicators, figH17]   =    create_rejection_indicators(RMS_bars,SNR_bars,LFN_bars,HFN_bars,RMS_boundaries,SNR_boundaries,LFN_boundaries,HFN_boundaries,file_indices,comp_data,Block_DATA,sub_plots_inds,do_plot)

rejection_indicators  = []; 
%figH17                = [];


file_label_groups =  unique(file_indices.file_label_number);
temp_ = find(comp_data.settings_.file_path_=='\');
tit_isrt  = comp_data.settings_.file_path_(temp_(3)+1:temp_(4)-1);
channels_ = {'1','2','3','4','5','6','7','8','9','10','11','12'}  ;


all_bars = zeros(size(RMS_bars,1),size(RMS_bars,2) ,4);
all_bars(:,:,1) =  RMS_bars;
all_bars(:,:,2) =  SNR_bars;
all_bars(:,:,3) =  LFN_bars;
all_bars(:,:,4) =  HFN_bars;
all_boundaries = zeros(4,3);

all_boundaries(1,:) = RMS_boundaries ;
all_boundaries(2,:) = SNR_boundaries ;
all_boundaries(3,:) = LFN_boundaries ;
all_boundaries(4,:) = HFN_boundaries ;


rejection_indicators      =     zeros(size(RMS_bars,1),size(RMS_bars,2) ,4) ;
mycolors = [1, 0, 0; 1, 0.55, 0.01; 1, 1, 0.3;0,1,0];

for index_pre = 1: 2
%all_bars(:,:,index_pre) < all_boundaries(index_pre,1);
rejection_indicators(:,:,index_pre) = all_bars(:,:,index_pre) < all_boundaries(index_pre,1);
rejection_indicators(:,:,index_pre) = rejection_indicators(:,:,index_pre)+  2*(all_bars(:,:,index_pre) >= all_boundaries(index_pre,1) & all_bars(:,:,index_pre) < all_boundaries(index_pre,2));
rejection_indicators(:,:,index_pre) = rejection_indicators(:,:,index_pre)+  3*(all_bars(:,:,index_pre) >= all_boundaries(index_pre,2) & all_bars(:,:,index_pre) < all_boundaries(index_pre,3));
rejection_indicators(:,:,index_pre) = rejection_indicators(:,:,index_pre)+  4*(all_bars(:,:,index_pre) >= all_boundaries(index_pre,3));
end % for index_pre = 1: size(all_bars,3)

for index_pre = 3: 4
rejection_indicators(:,:,index_pre) = all_bars(:,:,index_pre) >all_boundaries (index_pre,1);
rejection_indicators(:,:,index_pre) = rejection_indicators(:,:,index_pre)+  2*(all_bars(:,:,index_pre) <= all_boundaries(index_pre,1) & all_bars(:,:,index_pre) > all_boundaries(index_pre,2));
rejection_indicators(:,:,index_pre) = rejection_indicators(:,:,index_pre)+  3*(all_bars(:,:,index_pre) <= all_boundaries(index_pre,2) & all_bars(:,:,index_pre) > all_boundaries(index_pre,3));
rejection_indicators(:,:,index_pre) = rejection_indicators(:,:,index_pre)+  4*(all_bars(:,:,index_pre) <= all_boundaries(index_pre,3));
end % for index_pre = 3: 4


% first create the rejection indicators
%<1  >1 && <2


if do_plot ==1

for index = 1:length(file_label_groups)
figH17{index} = figure;
group_lab = Block_DATA.File_labels{index};   %  for the overall title
current_group_index =  file_label_groups(index);
file_inds =  find(file_indices.file_label_number  ==  current_group_index) ;
for index_2 = 1: length(file_inds)
%file_inds(index_2)
figure(figH17{index});
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)

temp_ = squeeze([rejection_indicators(file_inds(index_2),:,:)])';
imagesc(temp_)
hold on

 ALL_bars_temp  =  squeeze([all_bars(file_inds(index_2),:,:)])' ;

for n=1:numel(ALL_bars_temp)
    [x,y]=ind2sub(size(ALL_bars_temp),n);
    text(y,x,num2str( (round(ALL_bars_temp(n)*10)/10)),"FontSize",8,"Color",'k','HorizontalAlignment', 'center')
end %for n=1:numel(ALL_bars_temp)


title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))
xticks(1:12)
yticks (1:4)
yticklabels({'RMS','SNR','LFN','HFN'})
colormap(mycolors)
clim([1,4])
axis equal




%vertical
%keyboard

xtt= xticks;
ytt= yticks;
xLL = xlim;
yLL = ylim;

for indexa = 1: length(ytt)
plot([xLL(1),xLL(end)],[ytt(indexa)-0.5,ytt(indexa)-0.5],'k')
if indexa == length(ytt)
plot([xLL(1),xLL(end)],[ytt(indexa)+0.5,ytt(indexa)+0.5],'k')
end %if indexa == length(ytt)

end %for index = 1: length(xtt)

%horizontal lines

for indexb = 1: length(xtt)
plot([xtt(indexb)-0.5,xtt(indexb)-0.5],[yLL(1),yLL(end)],'k')
if indexb == length(xtt)
plot([xtt(indexb)+0.5,xtt(indexb)+0.5],[yLL(1),yLL(end)],'k')
end %if indexa == length(ytt)
end %for index = 1: length(ytt)

ylim([0.5,4.5])

end %for index_2 = 1: length(file_inds)

set(gcf, 'name',['Quality indicators : ',remove_(tit_isrt), ' : ',  group_lab,'.'])
sgtitle(['Quality indicators:: ' , remove_(tit_isrt), ' : ',  group_lab,'.' ]) 

end %for index = 1:length(file_label_groups)

else
figH17 =[];

end% if do_plot ==1




% disp('here')

end %function  create_rejection_indicators(RMS_bars,SNR_bars,LFN_bars,HFN_bars,RMS_boundariesSNR_boundaries,LFN_boundaries,HFN_boundaries)

function [figH_9,figH_10,figH_11,figH_12,figH_13,figH_14,figH_15,figH_16,RMS_bars,SNR_bars,LFN_bars,HFN_bars]    =   plot_signal_2_noise(file_indices , comp_data , sub_plots_inds,Block_DATA , labels,res_start,sig_amp_min,SNR_bandwidth_kHz,int_VAL,use_lin_or_DB,diagonal_gate,exitation_freq,do_plots,RMS_boundaries,SNR_boundaries,LFN_boundaries,HFN_boundaries)

%(5) maps (6) amps



RMS_bars = zeros(size(comp_data.OP,2),   size(comp_data.OP{1}.chan_data.time_data,3 )) ;
SNR_bars = zeros(size(comp_data.OP,2),   size(comp_data.OP{1}.chan_data.time_data,3 )) ;
LFN_bars = zeros(size(comp_data.OP,2),   size(comp_data.OP{1}.chan_data.time_data,3 )) ;
HFN_bars = zeros(size(comp_data.OP,2),   size(comp_data.OP{1}.chan_data.time_data,3 )) ;


multiplier_1 = 1;

file_label_groups =  unique(file_indices.file_label_number);
temp_ = find(comp_data.settings_.file_path_=='\');
tit_isrt  = comp_data.settings_.file_path_(temp_(3)+1:temp_(4)-1);

channels_ = {'1','2','3','4','5','6','7','8','9','10','11','12'}  ;

for index = 1:length(file_label_groups)
 
group_lab = Block_DATA.File_labels{index};   %  for the overall title
current_group_index =  file_label_groups(index);
file_inds =  find(file_indices.file_label_number  ==  current_group_index) ;

if do_plots(5) ==1
figH_1{index}   =  figure;
else
figH_1{index}   =  [];
end

if do_plots(6) ==1
figH_2{index}   =  figure;
else
figH_2{index}   =  [];
end


if do_plots(7) ==1
figH_9{index}   =  figure;
else
figH_9{index}   =  [];
end

if do_plots(8) ==1
figH_10{index}  =  figure;
else
figH_10{index}   =  [];
end

if do_plots(9) ==1
figH_11{index}  =  figure;
else
figH_11{index}   =  [];
end

if do_plots(10) ==1
figH_12{index}  =  figure;
else
figH_12{index}   =  [];
end

% ----------------------------------------------------
% low freq noise ratio  
% ----------------------------------------------------
if do_plots(11) ==1
figH_13{index}  =  figure;
else
figH_13{index}   =  [];
end
if do_plots(12) ==1
figH_14{index}  =  figure;
else
figH_14{index}   =  [];
end


% ----------------------------------------------------
% high freq noise ratio  
% ----------------------------------------------------
if do_plots(13) ==1
figH_15{index}  =  figure;
else
figH_15{index}   =  [];
end

if do_plots(14) ==1
figH_16{index}  =  figure;
else
figH_16{index}   =  [];
end


for index_2 = 1: length(file_inds)

if do_plots(7) ==1
figure(figH_9{index}) 
hold on
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)
end


%disp(num2str(index_2))
%disp(num2str(length(time_)))


temp__td   =  comp_data.OP{file_inds(index_2)}.chan_data.time_data ;
time_d   =  temp__td(diagonal_gate:end,:,:)                            ;

% time_d    =  comp_data.OP{file_inds(index_2)}.chan_data.time_data ;

tmp_time   = comp_data.OP{file_inds(index_2)}.chan_data.time;

%disp(num2str(length(tmp_time)))

time_  = tmp_time(diagonal_gate:end);

samp_freq  = 1/(time_(2)- time_(1));

temp_f = [1:length(time_)]/length(time_)*samp_freq/1000;
freq_axis_KHz = temp_f(1:floor(length(temp_f)/2));

tem_f_d = abs(fft(time_d));
fft_d_temp = tem_f_d(1: floor(length(tem_f_d)/2),:,:);


%keyboard


RMS_mat_LIN  =  zeros(size((fft_d_temp),2),size((fft_d_temp),3));
SNR_mat_DB  =  zeros(size((fft_d_temp),2),size((fft_d_temp),3));
SNR_mat_Lin =  zeros(size((fft_d_temp),2),size((fft_d_temp),3));
LFN_mat_DB =  zeros(size((fft_d_temp),2),size((fft_d_temp),3));
LFN_mat_Lin =  zeros(size((fft_d_temp),2),size((fft_d_temp),3));
HFN_mat_DB =  zeros(size((fft_d_temp),2),size((fft_d_temp),3));
HFN_mat_Lin =  zeros(size((fft_d_temp),2),size((fft_d_temp),3));


for index_a = 1:size((fft_d_temp),2)
for index_b = 1:size((fft_d_temp),3)

current_fft_tmp =  fft_d_temp(: ,index_a,index_b);


sig_tmp = sum(current_fft_tmp(find(freq_axis_KHz< (50+SNR_bandwidth_kHz)  & freq_axis_KHz> (50-SNR_bandwidth_kHz))));
noise_tmp = sum(current_fft_tmp((find(freq_axis_KHz> (50+SNR_bandwidth_kHz) | freq_axis_KHz < (50-SNR_bandwidth_kHz)))));

%LFN
Low_freq_temp     = sum(current_fft_tmp(find(freq_axis_KHz< (50-SNR_bandwidth_kHz))));
not_Low_freq_temp = sum(current_fft_tmp(find(freq_axis_KHz> (50-SNR_bandwidth_kHz))));

%HFN
High_freq_temp     = sum(current_fft_tmp(find(freq_axis_KHz> (50+SNR_bandwidth_kHz))));
not_High_freq_temp = sum(current_fft_tmp(find(freq_axis_KHz< (50+SNR_bandwidth_kHz)))); 


RMS_mat_LIN(index_a,index_b) = sig_tmp;

SNR_mat_DB(index_a,index_b) =  10*log10(sig_tmp /noise_tmp);
SNR_mat_Lin(index_a,index_b) =  (sig_tmp /noise_tmp);

LFN_mat_DB(index_a,index_b) =  10*log10(Low_freq_temp/not_Low_freq_temp);
LFN_mat_Lin(index_a,index_b) =  (Low_freq_temp/not_Low_freq_temp);

HFN_mat_DB(index_a,index_b) =  10*log10(High_freq_temp/not_High_freq_temp);
HFN_mat_Lin(index_a,index_b) =  (High_freq_temp/not_High_freq_temp);

end %for index_b = 1:size((fft_d_temp),3)
end %for index_a = 1:size((fft_d_temp),2)

% now plot it as a colour matrix
% give option for linear or log


m_temp_rms =  RMS_mat_LIN ;
m_temp_rms (eye(size(m_temp_rms ))==1)=0;
m_temp_rms = m_temp_rms/mean(mean(m_temp_rms));




switch (use_lin_or_DB)
    case(1)
SNR_2_use = SNR_mat_Lin;
SNR_inst = ' SNR- Linear';
    case(2)
SNR_2_use = SNR_mat_DB;
SNR_inst = 'SNR - DB';
end %switch (use_lin_or_DB)


%keyboard


m_temp =  SNR_2_use;

if do_plots(7) ==1
imagesc (m_temp)
hold on

yticks(1:size(m_temp,1))
ylabel('Channel #')
xticks(1:size(m_temp,2))
xlabel('Channel #')
clim([-1 8])

for n=1:numel(m_temp)
    [x,y]=ind2sub(size(m_temp),n);
    
    if m_temp(n)>0
    text(y,x,num2str( abs(round(m_temp(n)*10)/10)),"FontSize",6,"Color",'k','HorizontalAlignment', 'center')
    else
    text(y,x,num2str( abs(round(m_temp(n)*10)/10)),"FontSize",6,"Color",'w','HorizontalAlignment', 'center')
       
    end
end %for n=1:numel(m_temp)

end %if do_plots(7) ==1

if do_plots(5) ==1
figure(figH_1{index}) 
hold on
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)
end

if do_plots(5) ==1

imagesc (m_temp_rms)
hold on

yticks(1:size(m_temp_rms,1))
ylabel('Channel #')
xticks(1:size(m_temp_rms,2))
xlabel('Channel #')

for n=1:numel(m_temp_rms)
    [x,y]=ind2sub(size(m_temp_rms),n);
    
    if m_temp_rms(n)>0
    text(y,x,num2str( abs(round(m_temp_rms(n)*10)/10)),"FontSize",6,"Color",'k','HorizontalAlignment', 'center')
    else
    text(y,x,num2str( abs(round(m_temp_rms(n)*10)/10)),"FontSize",6,"Color",'w','HorizontalAlignment', 'center')
       
    end
end %for n=1:numel(m_temp_rms)

end %if do_plots(5) ==1

%------------------------------------------------------
% BAR CHART SNR
%------------------------------------------------------


RMS_mat_LIN (eye(size(RMS_mat_LIN ))==1) = nan;
bars_temp_a =  (mean(RMS_mat_LIN,1,'omitnan')+mean(RMS_mat_LIN,2,'omitnan')') / 2;
bars_temp_a = bars_temp_a/mean(bars_temp_a);

RMS_bars (file_inds(index_2),:)  = bars_temp_a;

if do_plots(6) ==1
figure(figH_2{index})
hold on
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)
end %if do_plots(8) ==1

if do_plots(6) ==1
bar(bars_temp_a)
hold on
xLi = xlim;
plot([xLi(1),xLi(2)] , [ RMS_boundaries(1),RMS_boundaries(1)],'r')
plot([xLi(1),xLi(2)] , [ RMS_boundaries(2),RMS_boundaries(2)],'y')
plot([xLi(1),xLi(2)] , [ RMS_boundaries(3),RMS_boundaries(3)],'g')

xticks(1:size(m_temp,2))
xlim([1,12])
%ylim([-5,5])
title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))
end %if do_plots(8) ==1


m_temp (eye(size(m_temp ))==1) = nan;
bars_temp = (mean(m_temp,1,'omitnan')+mean(m_temp,2,'omitnan')') / 2;
SNR_bars (file_inds(index_2),:)   = bars_temp; 


if do_plots(8) ==1
figure(figH_10{index})
hold on
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)
end %if do_plots(8) ==1

if do_plots(8) ==1
bar(bars_temp)
hold on
xLi = xlim;
plot([xLi(1),xLi(2)] , [ SNR_boundaries(1),SNR_boundaries(1)],'r')
plot([xLi(1),xLi(2)] , [ SNR_boundaries(2),SNR_boundaries(2)],'y')
plot([xLi(1),xLi(2)] , [ SNR_boundaries(3),SNR_boundaries(3)],'g')

xticks(1:size(m_temp,2))
xlim([1,12])
ylim([-5,5])
title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))
end %if do_plots(8) ==1




%if index_2 == 6
%keyboard    
%end    
%------------------------ 
%------------------------ 
% do timeplots  best / worst  and any < 0
%------------------------ 
%------------------------ 
% find the 2 lowest and then the highest bars
% for each one -- highest-  get the 2 highest    
% 2 lowest  -  get the 2 lowest
%[~,min_chan_ind]  =  min(bars_temp);
%[~,max_chan_ind]  =  max(bars_temp);

[~ ,bbb_tmp ] = sort(bars_temp); 

%sub_zero_inds     =  find(bars_temp<0) ; 
chan_inds2plot    =  unique([bbb_tmp(1),bbb_tmp(2),bbb_tmp(end)]);

two_d_inds = zeros(length(chan_inds2plot)*2,2);
pair_vals = zeros(length(chan_inds2plot)*2,1);

LABEL_itt = [];
LABEL_itt_f = [];


for index_x = 1:length(chan_inds2plot) 

tmpx =  chan_inds2plot(index_x);
ind_2d = [tmpx,1;tmpx,2;tmpx,3;tmpx,4;tmpx,5;tmpx,6;tmpx,7;tmpx,8;tmpx,9;tmpx,10;tmpx,11;tmpx,12 ;1,tmpx; 2,tmpx;3,tmpx;4,tmpx;5,tmpx;6,tmpx;7,tmpx;8,tmpx;9,tmpx;10,tmpx;11,tmpx;12,tmpx];

MPs_ = [m_temp(tmpx,:),m_temp(:,tmpx)'];
[MPs_vals,MPs_order] =  sort(MPs_);

switch(index_x)

    case{1,2}
first_pair_val            =  MPs_vals(1) ;
first_pair_val_tmp        =  MPs_order(1);       %  the smallest MP
second_pair_val           =  MPs_vals(2);     
second_pair_val_tmp       =  MPs_order(2);       %  the second smallest MP        
    
    case(3)
first_pair_val            = MPs_vals(end-2);
first_pair_val_tmp        = MPs_order(end-2);   %  the largest MP

second_pair_val           =   MPs_vals(end-3);
second_pair_val_tmp       =  MPs_order(end-3);   %  the second largest MP
end %switch(index_x)


two_d_inds(index_x*2-1,:)  =  ind_2d(first_pair_val_tmp, : )     ;
two_d_inds(index_x*2,:)    =  ind_2d(second_pair_val_tmp , : )     ;

pair_vals(index_x*2-1)     =  first_pair_val                     ;
pair_vals(index_x*2)       =  second_pair_val                      ;

LABEL_itt{index_x*2-1}     = [num2str(two_d_inds(index_x*2-1,1)),'/',num2str(two_d_inds(index_x*2-1,2))   ,'(',num2str( round(first_pair_val*10)/10 ),')']; 
LABEL_itt{index_x*2}       = [num2str(two_d_inds(index_x*2,1)),'/',num2str(two_d_inds(index_x*2,2))   ,'(',num2str(round(second_pair_val*10)/10),')'];

end %for index_x = 1:length(chan_inds2plot) 

LABEL_itt_f = LABEL_itt;


if do_plots(9) ==1

figure(figH_11{index}) 
hold on
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)

end %if do_plots(9) ==1

accumulator_ = 0;

%get the  ymin and max

ymax_temp = 0;
ymin_temp = 0;

for index_y = 1 : length(two_d_inds)
td_traces_tmp =  temp__td(:,two_d_inds(index_y,1),two_d_inds(index_y,2));

if index_y ~= length(two_d_inds)
ymax_temp = ymax_temp+ max(abs(td_traces_tmp));
else
ymax_temp = ymax_temp+ max(abs(td_traces_tmp));
end
if min(td_traces_tmp)  < ymin_temp
ymin_temp = min(td_traces_tmp);
end
end %for index_y = 1 : length(two_d_inds)

if do_plots(9) ==1

ylim([ymin_temp,ymax_temp])
for index_y = 1: length(two_d_inds)
%disp(num2str(index_y))

td_traces_tmp =  temp__td(:,two_d_inds(index_y,1),two_d_inds(index_y,2)); 
plot(tmp_time*1000 ,td_traces_tmp + accumulator_)
hold on

if index_y == length(two_d_inds)
Y_lms = get(gca,'YLim');
plot([1000*tmp_time(diagonal_gate),1000*tmp_time(diagonal_gate)],[ymin_temp, ymax_temp], 'k-s','MarkerSize',3,'LineWidth',2)
end %if index_y == length(two_d_inds)

accumulator_ =accumulator_ + max(abs(td_traces_tmp));
end %for index_y = 1 : length(two_d_inds)

% Plot the whole timeplot but put the gate in
% put an offset as the mean alue of the timetrace (not max)
xlabel('time (ms)')
title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))

LABEL_itt{end+1} = 'Gate';

legend(LABEL_itt,'location','southeast','fontsize',6)
title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))
end%if do_plots(9) ==1



if do_plots(10) ==1
figure(figH_12{index}) 
hold on
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)
accumulator_ = 0;
end %if do_plots(10) ==1


%get the  ymin and max

ymax_temp = 0;
ymin_temp = 0;

for index_y = 1 : length(two_d_inds)

    td_traces_tmp =  fft_d_temp (:,two_d_inds(index_y,1),two_d_inds(index_y,2));

if index_y ~= length(two_d_inds)
ymax_temp = ymax_temp+ max(abs(td_traces_tmp));
else
ymax_temp = ymax_temp+ max(abs(td_traces_tmp));
end
if min(abs(td_traces_tmp))  < ymin_temp
ymin_temp = min(abs(fft_d_));
end
end %for index_y = 1 : length(two_d_inds)

if do_plots(10) ==1
ylim([ymin_temp,ymax_temp])


for index_y = 1: length(two_d_inds)
%disp(num2str(index_y))

fft_d_tmp =  fft_d_temp(:,two_d_inds(index_y,1),two_d_inds(index_y,2)); 

plot(freq_axis_KHz ,fft_d_tmp + accumulator_)
hold on

if index_y == length(two_d_inds)
Y_lms = get(gca,'YLim');

plot( [exitation_freq-SNR_bandwidth_kHz,exitation_freq-SNR_bandwidth_kHz]     ,  [ymin_temp, ymax_temp], 'k-s','MarkerSize',3,'LineWidth',2)
plot( [exitation_freq+SNR_bandwidth_kHz,exitation_freq+SNR_bandwidth_kHz]     ,  [ymin_temp, ymax_temp], 'k-s','MarkerSize',3,'LineWidth',2)
end  %if index_y == length(two_d_inds)
accumulator_ =accumulator_ + max(abs(fft_d_tmp));


end %for index_y = 1 : length(two_d_inds)

% Plot the whole timeplot but put the gate in
% put an offset as the mean alue of the timetrace (not max)
xlabel('Freq (kHz)')
title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))

LABEL_itt_f{end+1} = 'L.Band';
LABEL_itt_f{end+1} = 'U.Band';

legend(LABEL_itt_f,'location','northeast','fontsize',6 )

end %if do_plots(10) ==1


%------------------------ 
%------------------------ 
% now do the freq plots
%------------------------ 
%------------------------ 
% LFN- MAPS
%------------------------ 

if do_plots(11) ==1

figure(figH_13{index}) 
hold on
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)

end %if do_plots(11) ==1


switch (use_lin_or_DB)
    case(1)
LFN_2_use = LFN_mat_Lin;
LFN_inst = ' LFN- Linear';
    case(2)
LFN_2_use = LFN_mat_DB;
LFN_inst = 'LFN - DB';
end %switch (use_lin_or_DB)

%keyboard

mm_temp =  LFN_2_use;

if do_plots(11) ==1
imagesc (mm_temp)
hold on

yticks(1:size(mm_temp,1))
ylabel('Channel #')
xticks(1:size(mm_temp,2))
xlabel('Channel #')
clim([-8 1])

for n=1:numel(mm_temp)
    [x,y]=ind2sub(size(mm_temp),n);
    
    if mm_temp(n)>0
    text(y,x,num2str( abs(round(mm_temp(n)*10)/10)),"FontSize",6,"Color",'k','HorizontalAlignment', 'center')
    else
    text(y,x,num2str( abs(round(mm_temp(n)*10)/10)),"FontSize",6,"Color",'w','HorizontalAlignment', 'center')
        
    end
 
end %for n=1:numel(mm_temp)

title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))
end %if do_plots(11) ==1


%------------------------ 
% LFN- BARS
%------------------------ 
mm_temp (eye(size(mm_temp ))==1) = nan;
bars_temp = (mean(mm_temp,1,'omitnan')+mean(mm_temp,2,'omitnan')') / 2;
LFN_bars (file_inds(index_2),:)   =bars_temp; 


if do_plots(12) ==1

figure(figH_14{index})


subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)
bar(bars_temp)
hold on
xLi = xlim;
plot([xLi(1),xLi(2)] , [LFN_boundaries(1),LFN_boundaries(1)],'r')
plot([xLi(1),xLi(2)] , [LFN_boundaries(2),LFN_boundaries(2)],'y')
plot([xLi(1),xLi(2)] , [LFN_boundaries(3),LFN_boundaries(3)],'g')

xticks(1:size(mm_temp,2))
xlim([1,12])
ylim([-12,2])
title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))

end %if do_plots(12) ==1


%------------------------ 
%------------------------ 
% now do the freq plots
%------------------------ 
%------------------------ 
% HFN- MAPS
%------------------------ 
if do_plots(13) ==1

figure(figH_15{index}) 
hold on
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)

end %if do_plots(13) ==1


switch (use_lin_or_DB)
    case(1)
HFN_2_use = HFN_mat_Lin;
HFN_inst = ' HFN- Linear';
    case(2)
HFN_2_use = HFN_mat_DB;
HFN_inst = 'HFN - DB';
end %switch (use_lin_or_DB)

%keyboard

mmm_temp =  HFN_2_use;
if do_plots(13) ==1
imagesc (mmm_temp)
hold on

yticks(1:size(mmm_temp,1))
ylabel('Channel #')
xticks(1:size(mmm_temp,2))
xlabel('Channel #')
clim([-8 2])

for n=1:numel(mmm_temp)
    [x,y]=ind2sub(size(mmm_temp),n);
    
    if mmm_temp(n)>0
    text(y,x,num2str( abs(round(mmm_temp(n)*10)/10)),"FontSize",6,"Color",'k','HorizontalAlignment', 'center')
    else
    text(y,x,num2str( abs(round(mmm_temp(n)*10)/10)),"FontSize",6,"Color",'w','HorizontalAlignment', 'center')
        
    end
 
end %for n=1:numel(mmm_temp)

title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))
end %if do_plots(13) ==1


%------------------------ 
% HFN- BARS
%------------------------ 

mmm_temp (eye(size(mmm_temp ))==1) = nan;
bars_temp = (mean(mmm_temp,1,'omitnan')+mean(mmm_temp,2,'omitnan')') / 2;
HFN_bars (file_inds(index_2),:)   =bars_temp; 


if do_plots(14) ==1

figure(figH_16{index})

subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)

bar(bars_temp)
hold on


xLi = xlim;
plot([xLi(1),xLi(2)] , [HFN_boundaries(1),HFN_boundaries(1)],'r')
plot([xLi(1),xLi(2)] , [HFN_boundaries(2),HFN_boundaries(2)],'y')
plot([xLi(1),xLi(2)] , [HFN_boundaries(3),HFN_boundaries(3)],'g')


xticks(1:size(mmm_temp,2))
xlim([1,12])
ylim([-12,2])
title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))

end %if do_plots(14) ==1

end  %for index_2 = 1: length(file_inds)


if do_plots(5) ==1
figure(figH_1{index})    
set(gcf, 'name',['RMS(MAP): ',remove_(tit_isrt), ' : ',  group_lab,'.'])
sgtitle(['RMS(MAP): ',remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
end%if do_plots(7) ==1

if do_plots(6) ==1
figure(figH_2{index})    
set(gcf, 'name',['RMS(BAR): ',remove_(tit_isrt), ' : ',  group_lab,'.'])
sgtitle(['RMS BARS: ' ,remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
end%if do_plots(7) ==1


if do_plots(7) ==1
figure(figH_9{index})    
set(gcf, 'name',['SNR(MAP): ',remove_(tit_isrt), ' : ',  group_lab,'.'])
sgtitle([SNR_inst, ' MAPS,(BW = ', num2str( SNR_bandwidth_kHz),' kHz, G=',num2str((tmp_time(diagonal_gate)*1000)),'ms) : ',remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
end%if do_plots(7) ==1

if do_plots(8) ==1
figure(figH_10{index})    
set(gcf, 'name',['SNR(BARS): ',remove_(tit_isrt), ' : ',  group_lab,'.'])
sgtitle([SNR_inst, ' BARS,(BW = ', num2str( SNR_bandwidth_kHz),' kHz, G=',num2str((tmp_time(diagonal_gate)*1000)),'ms) : ',remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
end%if do_plots(7) ==1


if do_plots(9) ==1
figure(figH_11{index})    
set(gcf, 'name',['SNR(time traces): ',remove_(tit_isrt), ' : ',  group_lab,'.'])
sgtitle([SNR_inst, ' TRACES,(BW = ', num2str( SNR_bandwidth_kHz),' kHz, G=',num2str((tmp_time(diagonal_gate)*1000)),'ms) : ',remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
end %if do_plots(7) ==1

if do_plots(10) ==1
figure(figH_12{index})    
set(gcf, 'name',['SNR(fft traces): ',remove_(tit_isrt), ' : ',  group_lab,'.'])
sgtitle([SNR_inst, ' TRACES,(BW = ', num2str( SNR_bandwidth_kHz),' kHz, G=',num2str((tmp_time(diagonal_gate)*1000)),'ms) : ',remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
end %if do_plots(7) ==1


if do_plots(11) ==1
figure(figH_13{index})    
set(gcf, 'name',['LFN(MAP): ',remove_(tit_isrt), ' : ',  group_lab,'.'])
sgtitle([LFN_inst, ' MAPS,(BW = ', num2str( SNR_bandwidth_kHz),' kHz, G=',num2str((tmp_time(diagonal_gate)*1000)),'ms) : ',remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
end %if do_plots(7) ==1

if do_plots(12) ==1
figure(figH_14{index})    
set(gcf, 'name',['LFN(BARS): ',remove_(tit_isrt), ' : ',  group_lab,'.'])
sgtitle([LFN_inst, ' BARS,(BW = ', num2str( SNR_bandwidth_kHz),' kHz, G=',num2str((tmp_time(diagonal_gate)*1000)),'ms) : ',remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
end %if do_plots(7) ==1

if do_plots(13) ==1
figure(figH_15{index})    
set(gcf, 'name',['HFN(MAP): ',remove_(tit_isrt), ' : ',  group_lab,'.'])
sgtitle([HFN_inst, ' MAPS,(BW = ', num2str( SNR_bandwidth_kHz),' kHz, G=',num2str((tmp_time(diagonal_gate)*1000)),'ms) : ',remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
end%if do_plots(7) ==1

if do_plots(14) ==1
figure(figH_16{index})    
set(gcf, 'name',['HFN(BARS): ',remove_(tit_isrt), ' : ',  group_lab,'.'])
sgtitle([HFN_inst, ' BARS,(BW = ', num2str( SNR_bandwidth_kHz),' kHz, G=',num2str((tmp_time(diagonal_gate)*1000)),'ms) : ',remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
end %if do_plots(7) ==1






end  %for index = 1:length(file_label_groups)
end %function figH_9          =   plot_signal_2_noise(file_indices , comp_data , sub_plots_inds,Block_DATA , labels,res_start,sig_amp_min);

function [figH_8 ,RMS_bars]          =   plot_chan_amps(file_indices , comp_data , sub_plots_inds,Block_DATA , labels,res_start,sig_amp_min,do_plot, RMS_boundaries)


multiplier_1 = 1;
file_label_groups =  unique(file_indices.file_label_number);
temp_ = find(comp_data.settings_.file_path_=='\');
tit_isrt  = comp_data.settings_.file_path_(temp_(3)+1:temp_(4)-1);
channels_ = {'1','2','3','4','5','6','7','8','9','10','11','12'}  ;


% keyboard

RMS_bars = zeros(size(comp_data.OP,2),   size(comp_data.OP{1}.chan_data.time_data,3 ));

for index = 1:length(file_label_groups)


group_lab = Block_DATA.File_labels{index};   %  for the overall title
current_group_index =  file_label_groups(index);
file_inds =  find(file_indices.file_label_number  ==  current_group_index) ;


if do_plot ==1
figH_8{index} = figure;
else
figH_8{index} = [];
end %if do_plot ==1


for index_2 = 1: length(file_inds)
    
if do_plot ==1
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)
end
% disp (num2str(file_inds(index_2)))

% put the boundaries in
%  file_inds(index_2)


%  CODE HERE  ------------------------------------------
time_d = comp_data.OP{file_inds(index_2)}.chan_data.time_data;

rms_square_response_tmp    =  squeeze(sqrt(mean((time_d(res_start:end,:,:)).^2)));

temp_ = rms_square_response_tmp-diag(diag(rms_square_response_tmp));
temp_amps = zeros(1,length(temp_ ));

for index_3 = 1: length(temp_ )
temp_amps(index_3)   =  mean([temp_(index_3,:),temp_(:,index_3)'])  ;
end %for index_3 = 1: length(temp_ )

temp_amps = temp_amps / mean(temp_amps);
RMS_bars (file_inds(index_2),:)   =temp_amps; 

if do_plot == 1
bar(temp_amps)
hold on
xlim([0.5,12.5])
ylim([0,  2*mean(temp_amps)] )

%RMS_boundaries
xLi = xlim;
plot([xLi(1),xLi(2)] , [ RMS_boundaries(1),RMS_boundaries(1)],'r')
plot([xLi(1),xLi(2)] , [ RMS_boundaries(2),RMS_boundaries(2)],'y')
plot([xLi(1),xLi(2)] , [ RMS_boundaries(3),RMS_boundaries(3)],'g')

title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))
plot([0.5,12.5],[sig_amp_min*mean(temp_amps),sig_amp_min*mean(temp_amps)],'r')
end %if if do_plot ==1
end  % for index_2 = 1: length(file_inds)


if do_plot ==1
sgtitle( ['CHAN RMS  bars: ',remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
set(gcf, 'name',['CHAN RMS  bars:', remove_(tit_isrt), ' : ',  group_lab,'.' ])
end %if if do_plot ==1

end %  for index = 1:length(file_label_groups)

end %function figH_8          =   plot_chan_amps(file_indices , comp_data , sub_plots_inds,Block_DATA , labels,res_start);

function [figs5,figs6] = plot_chan_maps(file_indices , comp_data , sub_plots_inds,Block_DATA , labels,res_start,int_VAL)

multiplier_1 = 1;
file_label_groups =  unique(file_indices.file_label_number);
temp_ = find(comp_data.settings_.file_path_=='\');
tit_isrt  = comp_data.settings_.file_path_(temp_(3)+1:temp_(4)-1);
channels_ = {'1','2','3','4','5','6','7','8','9','10','11','12'}  ;


for index = 1:length(file_label_groups)

group_lab = Block_DATA.File_labels{index};   %  for the overall title
current_group_index =  file_label_groups(index);
file_inds =  find(file_indices.file_label_number  ==  current_group_index) ;



figs5{index} = figure;
figs6{index} = figure;

%
for index_2 = 1: length(file_inds)

time_d = comp_data.OP{file_inds(index_2)}.chan_data.time_data;

rms_square_tmp =  squeeze(sqrt( mean((time_d.^2))))   ;
rms_square_response_tmp    =  squeeze(sqrt(mean((time_d(res_start:end,:,:)).^2)));


%{
figure(figs5{index});
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)


%-----------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------
m_temp =  rms_square_tmp -diag(diag(rms_square_tmp)*multiplier_1);
imagesc (m_temp)
hold on

yticks(1:size(m_temp,1))
ylabel('Channel #')
xticks(1:size(m_temp,2))
xlabel('Channel #')

%clim([1 6])
for n=1:numel(m_temp)
    [x,y]=ind2sub(size(m_temp),n);
    
    if m_temp(n)>0
    text(y,x,num2str( abs(round(m_temp(n)*10)/10)),"FontSize",6,"Color",'k','HorizontalAlignment', 'center')
    else
    text(y,x,num2str( abs(round(m_temp(n)*10)/10)),"FontSize",6,"Color",'w','HorizontalAlignment', 'center')
        
    end
 
end %for n=1:numel(m_temp)

%}

%-----------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------







title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))
figure(figs6{index})
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)



%-----------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------
m_temp =  rms_square_response_tmp -diag(diag(rms_square_response_tmp)*multiplier_1);
imagesc (m_temp)
hold on

yticks(1:size(m_temp,1))
ylabel('Channel #')
xticks(1:size(m_temp,2))
xlabel('Channel #')

%clim([1 6])
for n=1:numel(m_temp)
    [x,y]=ind2sub(size(m_temp),n);
    
    if m_temp(n)>0
    text(y,x,num2str( abs(round(m_temp(n)*10)/10)),"FontSize",6,"Color",'k','HorizontalAlignment', 'center')
    else
    text(y,x,num2str( abs(round(m_temp(n)*10)/10)),"FontSize",6,"Color",'w','HorizontalAlignment', 'center')
        
    end
 
end %for n=1:numel(m_temp)
%-----------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------

%{


DATA_ =rms_square_response_tmp -diag(diag(rms_square_response_tmp)*multiplier_1);
DATA_I  =  get_interp_data(DATA_,int_VAL);

colormap default;
surf(DATA_I);
view(2);
axis equal;
shading flat;
axis off;
%colorbar;

sf = int_VAL/ 12;
offset = int_VAL / 50;

modes_temp = [1,2,3,4,5,6,7,8,9,10,11,12];

for ii = 1:12
    a = text((ii - 0.5) * sf + 1, - offset + 1, sprintf('%i',modes_temp(ii)));
    set(a, 'HorizontalAlignment', 'center');
    set(a, 'VerticalAlignment', 'top');

    a = text(-offset + 1, (ii - 0.5) * sf + 1, sprintf('%i',modes_temp(ii)));
    set(a, 'HorizontalAlignment', 'right');
    set(a, 'VerticalAlignment', 'middle');

end % for ii = 1:length(options.modes)
%}

title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))

end %for index_2 = 1: length(file_inds)

figure(figs5{index})
%sgtitle(['RMS SIGNAL(map) :  ', remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
sgtitle(['RMS SIGNAL(map) :  ', remove_(tit_isrt), ' : ',  group_lab,'.' ]) 



figure(figs6{index})
%sgtitle(['RESPONSE:  ',remove_(tit_isrt), ' : ',  group_lab,'.' ]) 

sgtitle(['RMS RESPONSE(map) :  ', remove_(tit_isrt), ' : ',  group_lab,'.' ]) 


end %for index = 1:length(file_label_groups)

end %function [figH_5,figH_6] = plot_chan_maps(file_indices , comp_data , sub_plots_inds,Block_DATA , modes_to_plot,labels,mp_vals_2use_mean1_or_max0);

function  figs4 =   plot_mode_maps (file_indices , comp_data , sub_plots_inds,Block_DATA , modes_to_plot,labels,mp_vals_2use_mean1_or_max0,db_range) 

file_label_groups =  unique(file_indices.file_label_number);
temp_ = find(comp_data.settings_.file_path_=='\');
tit_isrt  = comp_data.settings_.file_path_(temp_(3)+1:temp_(4)-1);

for index = 1:length(file_label_groups)

group_lab = Block_DATA.File_labels{index};   %  for the overall title
current_group_index =  file_label_groups(index);
file_inds =  find(file_indices.file_label_number  ==  current_group_index) ;

figs4{index} = figure;

for index_2 = 1: length(file_inds)

subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)

mode_map_t = comp_data.OP{file_inds(index_2)}.grid_data.data_stack;
lower_val_t = comp_data.OP{file_inds(index_2)}.plot_data{1}.lower_val;
upper_val_t = comp_data.OP{file_inds(index_2)}.plot_data{1}.upper_val;

[~,MP_mean,MP_max] = get_normalised_stack_and_mean(lower_val_t,upper_val_t , mode_map_t) ;


title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))
hold on

switch (mp_vals_2use_mean1_or_max0) 
    case(1)
    MP_vals_to_use = MP_mean;
    mean_max_insert = 'mean';
    case(0)    
    MP_vals_to_use = MP_max;
    mean_max_insert = 'max';
end


mode_PLOT_data_temp  =  get_interp_data(MP_vals_to_use,50);
colormap default;
surf(mode_PLOT_data_temp);
view(2);
axis equal;
shading flat;
axis off;
caxis([0, db_range]);
title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))
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


end %for index_2 = 1: length(file_inds)

sgtitle([remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
set(gcf, 'name',['MODE maps:', remove_(tit_isrt), ' : ',  group_lab,'.' ])




end %for index = 1:length(file_label_groups)



end  %function  figs4 =   plot_mode_maps (file_indices , comp_data , sub_plots_inds,Block_DATA , modes_to_plot,labels,mp_vals_2use_mean1_or_max0) 

function  figs3 =   do_statistical_mode_plot(file_indices , comp_data , sub_plots_inds,Block_DATA ,labels,mp_vals_2use_mean1_or_max0 )

file_label_groups =  unique(file_indices.file_label_number);
temp_ = find(comp_data.settings_.file_path_=='\');
tit_isrt  = comp_data.settings_.file_path_(temp_(3)+1:temp_(4)-1);
x_vals = [1:16]';



for index = 1:length(file_label_groups)

group_lab = Block_DATA.File_labels{index};   %  for the overall title
current_group_index =  file_label_groups(index);
file_inds =  find(file_indices.file_label_number  ==  current_group_index) ;

figs3{index} = figure;

for index_2 = 1: length(file_inds)
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)

mode_map_t = comp_data.OP{file_inds(index_2)}.grid_data.data_stack;
lower_val_t = comp_data.OP{file_inds(index_2)}.plot_data{1}.lower_val;
upper_val_t = comp_data.OP{file_inds(index_2)}.plot_data{1}.upper_val;

[MP_stack,MP_mean,MP_max] = get_normalised_stack_and_mean(lower_val_t,upper_val_t , mode_map_t) ;


title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))
hold on

switch (mp_vals_2use_mean1_or_max0) 
    case(1)
    MP_vals_to_use = MP_mean;
    %mean_max_insert = 'mean';
    case(0)    
    MP_vals_to_use = MP_max;
    %mean_max_insert = 'max';
end


% code here
std_s  =   reshape(std(MP_stack,[],3), numel(std(MP_stack,[],3)),1)  ;  
max_s  =   reshape(max(MP_stack,[],3), numel(max(MP_stack,[],3)),1)   ;
min_s  =   reshape(min(MP_stack,[],3), numel(min(MP_stack,[],3)),1)   ;

mean_s = reshape(MP_mean(:,:),numel(MP_mean(:,:)),1)                    ;
MP_VTU =  reshape(MP_vals_to_use(:,:),numel(MP_vals_to_use(:,:)),1)       ;

errorbar(x_vals,mean_s,mean_s-min_s,abs(mean_s-max_s),':o')

xlim([0,17])
xticks(1:16)
xticklabels(labels)
plot(x_vals,MP_VTU,'s','markersize',10)


end %for index_2 = 1: length(file_inds)

leg_ = legend('Mean','Val Used','Location','westoutside','orientation','vertical');
figs3{index}.Position(3)=figs3{index}.Position(3)+400;
leg_.Position = [0.04,0.3543,0.05,0.45000];
sgtitle([remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
set(gcf, 'name',['Stat Mode plot: ',remove_(tit_isrt), ' : ',  group_lab,'.' ])


end %for index = 1:length(file_label_groups)




%{
figH = figure;

x_vals = [1:16]' ;

for index = 1: length(file_) 
    
subplot(sub_plots_inds(length(file_),1),sub_plots_inds(length(file_),2),index)


title(subplot_tit{index})
hold on

std_s  =   reshape(std(MP_stack_vals{index},[],3), numel(std(MP_stack_vals{index},[],3)),1)    ;  
max_s =   reshape(max(MP_stack_vals{index},[],3), numel(max(MP_stack_vals{index},[],3)),1)    ;
min_s =   reshape(min(MP_stack_vals{index},[],3), numel(min(MP_stack_vals{index},[],3)),1)    ;

MP_VTU =  reshape(MP_vals_to_use(:,:,index),numel(MP_vals_to_use(:,:,index)),1)       ;


mean_s = reshape(MP_mean_vals(:,:,index),numel(MP_mean_vals(:,:,index)),1)                    ;

errorbar(x_vals,mean_s,mean_s-min_s,abs(mean_s-max_s),':o')
xlim([0,17])
xticks([1:16])
xticklabels(labels)

plot(x_vals,MP_VTU,'s','markersize',10)

% MP_mean_vals
end %for index = 1: length(file_) 
leg_ = legend('Mean','Val Used','Location','westoutside','orientation','vertical');
figH.Position(3)=figH.Position(3)+400;
leg_.Position = [0.04,0.3543,0.05,0.45000];
sgtitle(plot_title) 
%}



end %function  figs3 =   do_statistical_mode_plot(file_indices , comp_data , sub_plots_inds,Block_DATA , modes_to_plot,labels ); 

function figs2 =   plot_selected_mode_pairs(file_indices , comp_data , sub_plots_inds,Block_DATA, modes_to_plot,labels )

mm_indices = [1,1;1,2;1,3;1,4;2,1;2,2;2,3;2,4;3,1;3,2;3,3;3,4;4,1;4,2;4,3;4,4];

file_label_groups =  unique(file_indices.file_label_number);
temp_ = find(comp_data.settings_.file_path_=='\');
tit_isrt  = comp_data.settings_.file_path_(temp_(3)+1:temp_(4)-1);



for index = 1:length(file_label_groups)


group_lab = Block_DATA.File_labels{index};   %  for the overall title
current_group_index =  file_label_groups(index);
file_inds =  find(file_indices.file_label_number  ==  current_group_index) ;

figs2{index} = figure;

for index_2 = 1: length(file_inds)
subplot(sub_plots_inds(length(file_inds),1), sub_plots_inds(length(file_inds),2),index_2)

if index_2 == length(file_inds) 
leg_txt =  ['legend(''',labels{modes_to_plot(1)},'''',','];
end %if index == length(file_inds) 

hold on
count_ = length(modes_to_plot)-1;

dv_tmp = comp_data.OP{file_inds(index_2)}.grid_data.distance_vector;
mode_map_tmp = comp_data.OP{file_inds(index_2)}.grid_data.data_stack;

temp_trace =    squeeze(mode_map_tmp(mm_indices(1,1),mm_indices(1,2),:));
addit_ = max(temp_trace);
plot(dv_tmp, addit_*(0.7*(count_)) + temp_trace)

for index_3 = 2:length(modes_to_plot)
count_ = count_-1;

temp_trace =    squeeze(mode_map_tmp(mm_indices(index_3,1),mm_indices(index_3,2),:));
addit_ = max(temp_trace);
plot(dv_tmp, addit_*(0.7*(count_)) + temp_trace)

if index_2 == length(file_inds) 
leg_txt =  [leg_txt,'''', labels{modes_to_plot(index_3)},'''',','];
end %if index_2 == length(file_) 

end %for index_3 = 1 : length(modes_to_plot   )

actual_peak_val_tmp   = comp_data.OP{file_inds(index_2)}.plot_data{1}.actual_peak_val;
mod_val_tmp           = comp_data.OP{file_inds(index_2)}.plot_data{1}.mod_val;

y_lims = ylim;

plot([dv_tmp(actual_peak_val_tmp),dv_tmp(actual_peak_val_tmp)],[y_lims(1),y_lims(2)],'k:')
plot([dv_tmp(mod_val_tmp),dv_tmp(mod_val_tmp)],[y_lims(1),y_lims(2)],'r')

title(remove_(file_indices.f_names{file_inds(index_2)}(4:end-6)))

end %for index_2 = 1: length(flle_inds)




leg_txt = [leg_txt,'''Peak''',',','''Used val''',',','''Location''',',','''southoutside''',',','''orientation''',',','''vertical''',')'];
eval(['leg_ =' ,  leg_txt,';'] );

figs2{index}.Position(3)=figs2{index}.Position(3)+400;
leg_.Position = [0.0161,0.3143,0.0969,0.5000];
sgtitle([remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
set(gcf, 'name',['SELECTED Mode pairs: ',remove_(tit_isrt), ' : ',  group_lab,'.' ])

end %for index = 1:length(file_label_groups)







end %function figs2 =   plot_selected_mode_pairs(file_indices , comp_data , sub_plots_inds,Block_DATA);

function figs1 =   plot_mode_selection_points(file_indices , comp_data , sub_plots_inds , Block_DATA)

file_label_groups =  unique(file_indices.file_label_number)            ;
temp_ = find(comp_data.settings_.file_path_=='\')                      ;
tit_isrt  = comp_data.settings_.file_path_(temp_(3)+1:temp_(4) - 1)    ;

for index = 1:length(file_label_groups)

group_lab = Block_DATA.File_labels{index};   %  for the overall title
current_group_index =  file_label_groups(index);
flle_inds =  find(file_indices.file_label_number  ==  current_group_index) ;

figs1{index} = figure;

for index_2 = 1: length(flle_inds)
   
subplot(sub_plots_inds(length(flle_inds),1), sub_plots_inds(length(flle_inds),2),index_2)
temp__ = comp_data.OP{flle_inds(index_2)}.plot_data{1} ;

plot(temp__.dv,temp__.mm33)
hold on
plot(temp__.dv (temp__.mod_val)      ,    temp__.mm33(temp__.mod_val),'g.','MarkerSize',25)
plot(temp__.dv(temp__.lower_val),temp__.mm33(temp__.lower_val),'r.','MarkerSize',10)
plot(temp__.dv(temp__.upper_val),temp__.mm33(temp__.upper_val),'r.','MarkerSize',10)
plot(temp__.dv(temp__.actual_peak_val),temp__.mm33(temp__.actual_peak_val),'k.','MarkerSize',20)

% -----------------------------------------------------

title(remove_(file_indices.f_names{flle_inds(index_2)}(4:end-6)))

% -----------------------------------------------------


end %for index_2 = 1: length(flle_inds)

sgtitle([remove_(tit_isrt), ' : ',  group_lab,'.' ]) 
set(gcf, 'name',['MODE sel pt', remove_(tit_isrt), ' : ',  group_lab,'.' ])


end  %for index = 1:length(file_label_groups)
end %function figs1 =   plot_mode_selection_points (file_indices,comp_data)

function plot_colormap(PTI,ROA,mode_pairs_to_Use , Labels_,MP_labels,group_act_tags ,max_rank,tit_insert )

%   now creat the plot with sub plots
%predicted_tag_index   PTI , ranking_of_actual   ROA
labs =  MP_labels(mode_pairs_to_Use);
labs{end+1} = 'mean';

fig_H = figure;

for index = 1: length(PTI)


subplot(length(PTI),4,index*4-3) 

m_temp = abs(PTI{index}-group_act_tags(index))+1;
m_temp_raw = PTI{index};


imagesc (m_temp)

hold on

yticks(1:size(PTI{index},1))
ylabel('Test #')
xticks(1:size(PTI{index},2))
xticklabels(labs)

colormap([0 1 0 ; 0 1 0 ; 1 1 0.3 ;1 0.5 0 ; 1 0 0 ; 1 0 0])
clim([1 6])
title(['Pred Tab Ind Rank: ', Labels_{group_act_tags(index)},'.'])

for n=1:numel(m_temp)
    [x,y]=ind2sub(size(m_temp),n);
        text(y,x,num2str(m_temp(n)))
end %for n=1:numel(m_temp)

subplot(length(PTI),4,index*4-2) 

m_temp2 = ROA{index};
m_temp2_raw = ROA{index};

imagesc (m_temp2)
hold on
yticks(1:size(ROA{index},1))
ylabel('Test #')
xticks(1:size(ROA{index},2))
xticklabels(labs)

colormap([0 1 0 ; 0 1 0 ; 1 1 0.3 ;1 0.5 0;1 0 0;1 0 0])
clim([1 6])

title(['Ranking of actual: ', Labels_{group_act_tags(index)},'.'])

for n=1:numel(m_temp2_raw)
    [x,y]=ind2sub(size(m_temp2_raw),n);
        text(y,x,num2str(m_temp2_raw(n)))
end %for n=1:numel(m_temp2_raw)


subplot(length(PTI),4,index*4-1) 
m_ave = floor((m_temp+m_temp2)./2);
imagesc (m_ave)
hold on
yticks(1:size(ROA{index},1))
ylabel('Test #')
xticks(1:size(ROA{index},2))
xticklabels(labs)
colormap([0 1 0 ; 0 1 0 ; 1 1 0.3 ;1 0.5 0;1 0 0;1 0 0])
clim([1 6])
title(['mean (PTI and ROA) : ', Labels_{group_act_tags(index)},'.'])

for n=1:numel(m_ave)
    [x,y]=ind2sub(size(m_ave),n);
        text(y,x,num2str(m_ave(n)))
end %for n=1:numel(m_ave)


subplot(length(PTI),4,index*4) 
ave_ave = mean(m_ave,1);
bar(ave_ave)
hold on
xticks(1:size(ROA{index},2))
xticklabels(labs)
ylim([0.5 4])
yticks(1:4)
X_L = xlim;
plot([X_L(1),X_L(2)],[max_rank max_rank],'r' ) 
ylabel('Ranking  (1 is best)')
title(['mean mean (between all Ts) : ', Labels_{group_act_tags(index)},'.'])
fontsize("default");fontsize("decrease");fontsize("decrease");fontsize("decrease");fontsize("decrease")
passed_vals{index} = find(ave_ave(1:end-1)<= max_rank);

end %for index = 1: length(PTI)

intersect_vals = passed_vals{1};

for index = 2:length(passed_vals)
intersect_vals = intersect(intersect_vals,passed_vals{index});
end %for index = 2:length(passed_vals)

sgtitle([tit_insert,  'rankings: all Cases, Thresh ranking = ',num2str(max_rank),', (Passed : ',num2str(intersect_vals),').'])
set(gcf, 'name',['PREDICT Ranking map: ' tit_insert,'.'])


end %function plot_colormap(PTI,ROA,comp_data.settings_.mode_pairs_to_Use,Block_DATA.Labels_)

%----------------------------------------------------------------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------------------------------------
function  [pred_tag,ranking_of_actual] =   create_bar_from_Pred(fig_h, TABLE_ , f_name, Label_ind ,all_labs, sub_plots_inds,no_plots, ind,do_plot ) 

if do_plot==1
figure(fig_h);
subplot(sub_plots_inds(no_plots,1),sub_plots_inds(no_plots,2),ind)
end



warning('off','all')
strc = table2struct(TABLE_)   ;
flds = fields(strc)           ;
plot_mat = zeros(length(all_labs),length(flds));


for index = 1:length(flds)
eval(['dum =  [strc.',flds{index},'];'])
plot_mat(:,index) = dum;


end %for index = 1:length(flds)



if do_plot==1
bar(plot_mat')
hold on
ylim([0,mean(mean(plot_mat))])
xticks([1:17])
xticklabels( TABLE_.Properties.VariableNames)
%title([remove_(f_name(1:end-4)),' : (', all_labs{Label_ind},').'])
title([remove_(f_name(1:end-4)),'.'])
% NOW GET THE RANKINGS
end %if do_plot==1


warning('on','all')

[~,pred_tag]  = min(plot_mat);
[~,sorted_vals] = sort(plot_mat);


[ranking_of_actual,~]= find(sorted_vals == Label_ind);




end %function  create_bar_from_Pred(comp_data.OP{index}.log_lik_table , file_indices.f_names{index}, file_indices.file_label_number(index) , Block_DATA.Labels_ ) 
%----------------------------------------------------------------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------------------------------------



function  file_indices =  get_descriptor_indices(comp_data,Block_DATA)

file_label_index = zeros(1,length(comp_data. PREDICT_STRUCT.FILENAME));

for index = 1:length(comp_data. PREDICT_STRUCT.FILENAME)
file_label_number  (index)  = comp_data.PREDICT_STRUCT.File_Label(index) + 1   ;
file_label         {index}  =  Block_DATA.Labels_{Block_DATA.conversion_key(file_label_number(index))}             ;

end  %for index = 1:length(comp_data. PREDICT_STRUCT.FILENAME)


file_indices.f_names                   = comp_data. PREDICT_STRUCT.FILENAME;

file_indices.file_label_number  = file_label_number                 ;
file_indices.file_label         = file_label                        ;


end %function get_descriptor_indices(comp_data,Block_DATA)

function [MP_stack,MP_mean,MP_max] = get_normalised_stack_and_mean(lower_val,upper_val,mode_map)

MP_stack = zeros(4,4,upper_val-lower_val);
count = 0;

for index = lower_val:upper_val
count = count + 1;
temp_MM =mode_map(:,:,index);

MP_stack(:,:,count) = temp_MM/mean(mean(temp_MM));
%MP_stack(:,:,count) = temp_MM./temp_MM(1,1);
%MP_stack(:,:,count) = temp_MM;

end  % for index = lower_val:upper_val

MP_mean = mean(MP_stack,3);
MP_max =  max(MP_stack,[],3);

end %function [MP_stack,MP_mean] = get_normalised_stack_and_mean(lower_val,upper_val,mode_map)













