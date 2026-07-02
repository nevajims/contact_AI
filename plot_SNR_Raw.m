function  rejection_indicators   =  plot_SNR_Raw(varargin)
% ---------------------------------------------------------------------- %
% for use with single result of Raw data file 
% Jim 11/7/2024
% ---------------------------------------------------------------------- %
% To Do:
% Put the numbers into quality indicators
%
% ---------------------------------------------------------------------- %
%INPUTS
% 2 options :  
% (a) nargin==0   --- no inputs parameters   plot_SNR_Raw()  select the file /  and  select what to plot 
% (b) nargin==3   --- 3 input paramenets     plot_SNR_Raw(test_data,do_plots,snr_settings)
% ---------------------------------------------------------------------- %
%NOTES
% ------------ all these properties should be in processing settings
% ---------------------------------------------------------------------- %
%  do_plots = [1 1 1 1]  %  to plot everything
%{
settings.RMS_boundaries     =  [0.1  , 0.25 , 0.6]                             ;
settings.SNR_boundaries     =  [ 0.3 , 1    ,   2]                             ;
settings.LFN_boundaries     =  [-1   ,-2    ,  -5]                             ; 
settings.HFN_boundaries     =  [-1   ,-2    ,  -5]                             ;

settings.exitation_freq_kHz =  50                                              ;  
settings.SNR_bandwidth_kHz  =  21                                              ;  
settings.time_gate          =  60                                              ;
settings.diagonal_time_gate =  200                                             ;
%}
% ---------------------------------------------------------------------- %
switch(nargin)
  
    case(0)%------------------------------------
% FORMAT::   rejection_indicators   = plot_SNR_Raw()
snr_settings       = load_structure_from_file('snr_settings.dat')  ;
RMS_boundaries = snr_settings.RMS_boundaries                       ;
SNR_boundaries   = snr_settings.SNR_boundaries                     ;
LFN_boundaries  = snr_settings.LFN_boundaries                      ;  %  Green / Yellow / Orange / Red   ---- GOOD :: BAD 
HFN_boundaries  = snr_settings.HFN_boundaries                      ;
exitation_freq_kHz = snr_settings.exitation_freq_kHz               ;  
SNR_bandwidth_kHz = snr_settings.SNR_bandwidth_kHz                 ;  
time_gate    = snr_settings.time_gate                              ;
diagonal_time_gate  = snr_settings.diagonal_time_gate              ;
starting_dir  = 'P:\GITHUBS\AIDATA'                                ;

P_W_D =   pwd;
if (exist(starting_dir)) == 7  
cd(starting_dir)
end
[file_name,file_path_] = uigetfile('*.mat',  'Selec the comp file','MultiSelect','off') ;
cd (P_W_D);
%--------------------------
% choose what to plot
%--------------------------
plot_list =   {'Maps','Bar Charts','indicators','time_freq_traces' } ;

do_plots =[0 0 0 0];
do_plots_dum =  choose_plots_to_show(plot_list);
do_plots(find(do_plots_dum ==1)) = 1;
[ALL_time_d,time_d,ALL_time,time_ ]  = load_the_data_from_file(file_path_,file_name,time_gate);

    case(2) %------------------------------------
test_data_path       = varargin{1}  ; 
do_plots             = varargin{2}  ; 
snr_settings_N         = load_structure_from_file('P:\GITHUBS\contact_AI\SETTINGS_FILES\snr_settings2.dat');
snr_settings        = convert_to_snr_struct(snr_settings_N);
dummy_1              = load(test_data_path)        ;
test_data            =  dummy_1.test_data     ;

    case(3) %------------------------------------
% FORMAT::   rejection_indicators   = plot_SNR_Raw(test_data,do_plots,snr_settings)
test_data       = varargin{1}  ; 
do_plots        = varargin{2}  ; 
snr_settings    = varargin{3}  ; 

end %switch(narargin)

if nargin ==2 || nargin ==3
RMS_boundaries     = snr_settings.RMS_boundaries     ;
SNR_boundaries     = snr_settings.SNR_boundaries     ;
LFN_boundaries     = snr_settings.LFN_boundaries     ;  %  Green / Yellow / Orange / Red   ---- GOOD :: BAD 
HFN_boundaries     = snr_settings.HFN_boundaries     ;
exitation_freq_kHz = snr_settings.exitation_freq_kHz ;  
SNR_bandwidth_kHz  = snr_settings.SNR_bandwidth_kHz  ;  
time_gate          = snr_settings.time_gate          ;
diagonal_time_gate = snr_settings.diagonal_time_gate ;

[ALL_time_d,time_d,ALL_time,time_ ] =  load_the_data_from_structure(test_data,time_gate);
file_name = test_data.file_with_path(max(find(test_data.file_with_path=='\'))+1:end-4);
end %if nargin ==2 || nargin ==3

% give option to plot time/frequecy traces   -  for selected send and
%------------------------------------------------
% Calculate matrix properties
%-----------------------------------------------
[samp_freq,freq_axis_KHz,fft_d_temp,RMS_mat,SNR_mat_DB,LFN_mat_DB,HFN_mat_DB]  =  calculate_mat_properties(time_,ALL_time_d,time_d,exitation_freq_kHz,SNR_bandwidth_kHz);
%------------------------------------------------
% PLOT COLORMAPS
%-----------------------------------------------
if do_plots(1) ==1
plot_colourmaps(RMS_mat,SNR_mat_DB,LFN_mat_DB,HFN_mat_DB,file_name)
end %if do_plots(1) ==1
%------------------------------------------------
% CREATE THE DATA FOR THE BARCHART
%-----------------------------------------------
ALL_bars = create_ALL_Bars(ALL_time_d,RMS_mat,SNR_mat_DB,LFN_mat_DB,HFN_mat_DB);
%------------------------------------------------
% PLOT BARCHART
%------------------------------------------------
if do_plots(2) ==1
plot_Barcarts(ALL_bars,RMS_boundaries,SNR_boundaries,LFN_boundaries,HFN_boundaries,file_name);
end %if do_plots(2) ==1
% ----------------------------------------------------------
% Calcutate REJECTION INDICATORS 
% ----------------------------------------------------------
rejection_indicators = Calcutate_REJECTION_INDICATORS(ALL_bars,RMS_boundaries,SNR_boundaries,LFN_boundaries,HFN_boundaries); 
% ----------------------------------------------------------
% Plot REJECTION INDICATORS 
% ----------------------------------------------------------
if do_plots(3) == 1
Plot_REJECTION_INDICATORS (rejection_indicators,file_name,ALL_bars )
end %if do_plots(3) == 1

% ----------------------------------------------------------
% Plot selected_time/freq_traces
% ----------------------------------------------------------

if do_plots(4) == 1
row_ind = 1;   % start val 
col_ind = 1;   % start val 
plot_time_and_frequencies(ALL_time_d,ALL_time, freq_axis_KHz,fft_d_temp,exitation_freq_kHz,SNR_bandwidth_kHz,time_gate,file_name,row_ind,col_ind)

end %if do_plots(4) == 1

end %function   plot_SNR_Raw(raw_data)

%------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------FUNCTIONS---------------------------------------------------------------------------------------------------------------------------  
%------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------

function plot_time_and_frequencies(ALL_time_d,ALL_time, freq_axis_KHz,fft_d_temp,exitation_freq_kHz,SNR_bandwidth_kHz,time_gate,file_name,row_ind,col_ind)

fH3 = figure('units','normalized');

sbH1 = subplot(2,1,1);
sbH2 = subplot(2,1,2);

Popup1 = uicontrol(fH3, 'Style', 'popupmenu', 'String', '1', ...
  'Position', [0 80 50 40], ...
  'CallBack', @change_row, ......
  'UserData', 0);

Popup1.String = {'R=1','R=2','R=3','R=4','R=5','R=6','R=7','R=8','R=9','R=10','R=11','R=12'};

Popup2 = uicontrol(fH3, 'Style', 'popupmenu', 'String', '1', ...
  'Position', [0 40 50 40], ...
  'CallBack', @change_col, ......
  'UserData', 0);

Popup2.String = {'C=1','C=2','C=3','C=4','C=5','C=6','C=7','C=8','C=9','C=10','C=11','C=12'};

PushButton = uicontrol(fH3, 'Style', 'push', 'String', 'RePlot', ...
  'Position', [0 0 40 30], ...
  'CallBack', @Replot_signals, ...
  'UserData', 0);

plot_data_structure.ALL_time                       = ALL_time           ; 
plot_data_structure.row_ind                        = row_ind            ;
plot_data_structure.col_ind                        = col_ind            ;
plot_data_structure.time_gate                      = time_gate          ;          
plot_data_structure.sbH1                           = sbH1               ;
plot_data_structure.sbH2                           = sbH2               ;
plot_data_structure.fH3                            = fH3                ;
plot_data_structure.freq_axis_KHz                  = freq_axis_KHz      ; 
plot_data_structure.fft_d_temp                     = fft_d_temp         ;   
plot_data_structure.exitation_freq_kHz             = exitation_freq_kHz ; 
plot_data_structure.SNR_bandwidth_kHz              = SNR_bandwidth_kHz  ; 
plot_data_structure.file_name                      = file_name          ; 
plot_data_structure.ALL_time_d                     = ALL_time_d         ;
fH3.UserData = plot_data_structure;

update_time_plot(plot_data_structure)  
%keyboard
end % function plot_time_and_frequencies(ALL_time_d,time_d,ALL_time,time_ )

function change_row(hObject, ~)
new_value =  get(hObject,'Value');
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
plot_data_structure.row_ind = new_value;

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end %function change_row(hObject, ~)

function change_col(hObject, ~)
new_value =  get(hObject,'Value');
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
plot_data_structure.col_ind = new_value;
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end %function change_row(hObject, ~)

function Replot_signals(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
update_time_plot(plot_data_structure)  
end %function change_row(hObject, ~)

function  update_time_plot(plot_data_structure)

ALL_time           = plot_data_structure.ALL_time           ; 
row_ind            = plot_data_structure.row_ind            ;
col_ind            = plot_data_structure.col_ind            ;
time_gate          = plot_data_structure.time_gate          ;          
sbH1               = plot_data_structure.sbH1               ;
sbH2               =  plot_data_structure.sbH2              ;
fH3                =  plot_data_structure.fH3               ;
freq_axis_KHz      = plot_data_structure.freq_axis_KHz      ; 
fft_d_temp         = plot_data_structure.fft_d_temp         ;   
exitation_freq_kHz = plot_data_structure.exitation_freq_kHz ; 
SNR_bandwidth_kHz  = plot_data_structure.SNR_bandwidth_kHz  ; 
file_name          = plot_data_structure.file_name          ; 
ALL_time_d         = plot_data_structure.ALL_time_d         ;

subplot(sbH1)
hold off
plot(ALL_time*1000 ,ALL_time_d(:,row_ind,col_ind))
hold on
y_lim  =  ylim;
plot([ALL_time(time_gate)*1000,ALL_time(time_gate)*1000],[y_lim(1),y_lim(2)])
legend('Data','T Gate')
xlabel('Time (ms)')

subplot(sbH2)
hold off
plot(freq_axis_KHz,fft_d_temp(:,row_ind,col_ind))
hold on
y_lim  =  ylim;
plot([exitation_freq_kHz + SNR_bandwidth_kHz , exitation_freq_kHz + SNR_bandwidth_kHz] , [y_lim(1),y_lim(2)],'r')
plot([exitation_freq_kHz - SNR_bandwidth_kHz , exitation_freq_kHz - SNR_bandwidth_kHz] , [y_lim(1),y_lim(2)],'r')
legend('Data','L band',' U band')
xlabel('Freq (kHz)')
sgtitle(['Time/Freq, R=' ,num2str(row_ind),', C=',num2str( col_ind),'    ::   ',remove_(file_name)])

end %function  update_time_plot(plot_data_structure)

function  Plot_REJECTION_INDICATORS (rejection_indicators,file_name,ALL_bars)
mycolors                  =     [1, 0, 0 ; 1, 0.55, 0.01 ; 1, 1, 0.3 ; 0,1,0];
fH3 = figure;
imagesc(rejection_indicators)
hold on

%rejection_indicators(file_inds(index_2),:,:)
%  for each on create  a set of indicator lights  RMS / SNR / LFN / HFN 
% for each one there are 4 x 12 values  plot as an image or colormap
% G / O / Y / R      1 / 2 / 3 / 4
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



for n=1:numel(ALL_bars)
    [x,y]=ind2sub(size(ALL_bars),n);
    text(y,x,num2str( (round(ALL_bars(n)*10)/10)),"FontSize",8,"Color",'k','HorizontalAlignment', 'center')
end %for n=1:numel(ALL_bars)


ylim([0.5,4.5])
xlabel('Channel#' )
set(gcf, 'name',['Quality indicators : ',file_name, '.'])
title(['Quality indicators:: ' , remove_(remove_(file_name))   ,'.']) 
end %function  Plot_REJECTION_INDICATORS (rejection_indicators )

function rejection_indicators = Calcutate_REJECTION_INDICATORS(ALL_bars,RMS_boundaries,SNR_boundaries,LFN_boundaries,HFN_boundaries) 
rejection_indicators      =     zeros(size(ALL_bars)) ;
all_boundaries = zeros(4,3);
all_boundaries(1,:) = RMS_boundaries ;
all_boundaries(2,:) = SNR_boundaries ;
all_boundaries(3,:) = LFN_boundaries ;
all_boundaries(4,:) = HFN_boundaries ;


for index_pre = 1: 2
rejection_indicators(index_pre,:) = ALL_bars(index_pre,:) < all_boundaries(index_pre,1);
rejection_indicators(index_pre,:) = rejection_indicators(index_pre,:) +  2*(ALL_bars(index_pre,:) >= all_boundaries(index_pre,1) & ALL_bars(index_pre,:) < all_boundaries(index_pre,2));
rejection_indicators(index_pre,:) = rejection_indicators(index_pre,:) +  3*(ALL_bars(index_pre,:) >= all_boundaries(index_pre,2) & ALL_bars(index_pre,:) < all_boundaries(index_pre,3));
rejection_indicators(index_pre,:) = rejection_indicators(index_pre,:) +  4*(ALL_bars(index_pre,:) >= all_boundaries(index_pre,3));
end % for index_pre = 1: size(ALL_bars,3)

for index_pre = 3: 4
rejection_indicators(index_pre,:) = ALL_bars(index_pre,:) > all_boundaries(index_pre,1);
rejection_indicators(index_pre,:) = rejection_indicators(index_pre,:) +  2*(ALL_bars(index_pre,:) <= all_boundaries(index_pre,1) & ALL_bars(index_pre,:) > all_boundaries(index_pre,2));
rejection_indicators(index_pre,:) = rejection_indicators(index_pre,:) +  3*(ALL_bars(index_pre,:) <= all_boundaries(index_pre,2) & ALL_bars(index_pre,:) > all_boundaries(index_pre,3));
rejection_indicators(index_pre,:) = rejection_indicators(index_pre,:) +  4*(ALL_bars(index_pre,:) <= all_boundaries(index_pre,3));
end % for index_pre = 3: 4
end %function rejection_indicators = Calcutate_REJECTION_INDICATORS(ALL_bars,RMS_mat,SNR_mat_DB,LFN_mat_DB,HFN_mat_DB); 

function plot_Barcarts(ALL_bars,RMS_boundaries,SNR_boundaries,LFN_boundaries,HFN_boundaries,file_name)
temp_amps = ALL_bars(1,:);
bars_temp = ALL_bars (2,:); 
bars2_temp= ALL_bars (3,:);
bars3_temp= ALL_bars (4,:); 

f2H = figure; 
hold on
% (1) RMS
subplot(2,2,1)
bar(temp_amps)
hold on
xlim([0.5,12.5])
ylim([0,  2*mean(temp_amps)] )

%RMS_boundaries
xLi = xlim;
plot([xLi(1),xLi(2)] , [ RMS_boundaries(1),RMS_boundaries(1)],'r')
plot([xLi(1),xLi(2)] , [ RMS_boundaries(2),RMS_boundaries(2)],'y')
plot([xLi(1),xLi(2)] , [ RMS_boundaries(3),RMS_boundaries(3)],'g')
xticks(1:size(ALL_bars,2))
xlim([1,12])
title('RMS/ each channel (averaged)')
ylabel('normalised')
xlabel('chan#')


% (2) SNR
subplot(2,2,2)
bar(bars_temp)
hold on
xLi = xlim;
plot([xLi(1),xLi(2)] , [ SNR_boundaries(1),SNR_boundaries(1)],'r')
plot([xLi(1),xLi(2)] , [ SNR_boundaries(2),SNR_boundaries(2)],'y')
plot([xLi(1),xLi(2)] , [ SNR_boundaries(3),SNR_boundaries(3)],'g')

xticks(1:size(ALL_bars,2))
xlim([1,12])
title('SNR/ each channel (averaged)')
ylabel('dB')
xlabel('chan#')

% (3) LFN
subplot(2,2,3)
bar(bars2_temp)
hold on
xLi = xlim;
plot([xLi(1),xLi(2)] , [ LFN_boundaries(1),LFN_boundaries(1)],'r')
plot([xLi(1),xLi(2)] , [ LFN_boundaries(2),LFN_boundaries(2)],'y')
plot([xLi(1),xLi(2)] , [ LFN_boundaries(3),LFN_boundaries(3)],'g')

xticks(1:size(ALL_bars,2))
xlim([1,12])
title('LFN/ each channel (averaged)')
ylabel('dB')
xlabel('chan#')

% (4) HFN
subplot(2,2,4)
bar(bars3_temp)
hold on
xLi = xlim;
plot([xLi(1),xLi(2)] , [ HFN_boundaries(1),HFN_boundaries(1)],'r')
plot([xLi(1),xLi(2)] , [ HFN_boundaries(2),HFN_boundaries(2)],'y')
plot([xLi(1),xLi(2)] , [ HFN_boundaries(3),HFN_boundaries(3)],'g')

xticks(1:size(ALL_bars,2))
xlim([1,12])
title('HFN/ each channel (averaged)')
ylabel('dB')
xlabel('chan#')

sgtitle(['Bar charts: ' remove_(file_name),'.'])
set(gcf, 'name',['Bar charts: ' remove_(file_name),'.'])
end %function  plot_Barcarts(ALL_bars)

function ALL_bars = create_ALL_Bars(ALL_time_d,RMS_mat,SNR_mat_DB,LFN_mat_DB,HFN_mat_DB)

m1_temp =  RMS_mat ; 
m2_temp =  SNR_mat_DB ;
m3_temp =  LFN_mat_DB;
m4_temp =  HFN_mat_DB;

ALL_bars = zeros (4 ,   size(ALL_time_d,3))    ;

% RMS
%

%for index_3 = 1: length(m1_temp)
%temp_amps(index_3)   =  mean([temp_(index_3,:),temp_(:,index_3)'])  ;
%end %for index_3 = 1: length(temp_ )

m1_temp (eye(size(m1_temp ))==1) = nan;
barsa_temp = (mean(m1_temp,1,'omitnan')+mean(m1_temp,2,'omitnan')') / 2;
barsa_temp = barsa_temp /mean(barsa_temp);
ALL_bars(1,:)  = barsa_temp; 

% SNR
%

m2_temp (eye(size(m2_temp ))==1) = nan;
bars_temp = (mean(m2_temp,1,'omitnan')+mean(m2_temp,2,'omitnan')') / 2;
ALL_bars (2,:)   =bars_temp; 

% LFN
%

%ALL_bars (3,:)   =bars_temp; 
m3_temp (eye(size(m3_temp ))==1) = nan;
bars2_temp = (mean(m3_temp,1,'omitnan')+mean(m3_temp,2,'omitnan')') / 2;
ALL_bars (3,:)   =bars2_temp; 

% HFN
%

m4_temp (eye(size(m4_temp ))==1) = nan;
bars3_temp = (mean(m4_temp,1,'omitnan')+mean(m4_temp,2,'omitnan')') / 2;
ALL_bars (4,:)   =bars3_temp; 

end

function plot_colourmaps(RMS_mat,SNR_mat_DB,LFN_mat_DB,HFN_mat_DB,file_name)
%---------------------
% COLORMAPS
%---------------------
m1_temp =  RMS_mat ; 
m2_temp =  SNR_mat_DB ;
m3_temp =  LFN_mat_DB;
m4_temp =  HFN_mat_DB;


f1H = figure;

% (1) RMS  ---------------------------------------------------------------
subplot(2,2,1)
imagesc (m1_temp)
hold on

yticks(1:size(m1_temp,1))
ylabel('Channel #')
xticks(1:size(m1_temp,2))
xlabel('Channel #')

%clim([1 6])
for n=1:numel(m1_temp)
    [x,y]=ind2sub(size(m1_temp),n);
    
    if m1_temp(n)>0
    text(y,x,num2str( abs(round(m1_temp(n)*10)/10)),"FontSize",6,"Color",'k','HorizontalAlignment', 'center')
    else
    text(y,x,num2str( abs(round(m1_temp(n)*10)/10)),"FontSize",6,"Color",'w','HorizontalAlignment', 'center')
    end
end %for n=1:numel(m1_temp)

title('RMS(black# +ve white# -ve)')

% (2) SNR  ---------------------------------------------------------------
subplot(2,2,2)
imagesc (m2_temp)
hold on
yticks(1:size(m2_temp,1))
ylabel('Channel #')
xticks(1:size(m2_temp,2))
xlabel('Channel #')
clim([-1 8])

for n=1:numel(m2_temp)
    [x,y]=ind2sub(size(m2_temp),n);
    if m2_temp(n)>0
    text(y,x,num2str( abs(round(m2_temp(n)*10)/10)),"FontSize",6,"Color",'k','HorizontalAlignment', 'center')
    else
    text(y,x,num2str( abs(round(m2_temp(n)*10)/10)),"FontSize",6,"Color",'w','HorizontalAlignment', 'center')
    end

end %for n=1:numel(m2_temp)
title('SNR(black# +ve white# -ve)')

% (3) LFN  ---------------------------------------------------------------
subplot(2,2,3)
imagesc (m3_temp)

yticks(1:size(m3_temp,1))
ylabel('Channel #')
xticks(1:size(m3_temp,2))
xlabel('Channel #')
clim([-8 1])

for n=1:numel(m3_temp)
    [x,y]=ind2sub(size(m3_temp),n);
    if m3_temp(n)>0
    text(y,x,num2str( abs(round(m3_temp(n)*10)/10)),"FontSize",6,"Color",'k','HorizontalAlignment', 'center')
    else
    text(y,x,num2str( abs(round(m3_temp(n)*10)/10)),"FontSize",6,"Color",'w','HorizontalAlignment', 'center')
    end
 
end %for n=1:numel(m3_temp)

title('LFN(black# +ve white# -ve)')

% (4) HFN  ---------------------------------------------------------------

subplot(2,2,4)
imagesc (m4_temp)
hold on

yticks(1:size(m4_temp,1))
ylabel('Channel #')
xticks(1:size(m4_temp,2))
xlabel('Channel #')
clim([-8 2])

for n=1:numel(m4_temp)
    [x,y]=ind2sub(size(m4_temp),n);
    if m4_temp(n)>0
    text(y,x,num2str( abs(round(m4_temp(n)*10)/10)),"FontSize",6,"Color",'k','HorizontalAlignment', 'center')
    else
    text(y,x,num2str( abs(round(m4_temp(n)*10)/10)),"FontSize",6,"Color",'w','HorizontalAlignment', 'center')
    end
 
end %for n=1:numel(m4_temp)
title('HFN(black# +ve white# -ve)')

sgtitle(['Maps : ' remove_(file_name),'.'])
set(gcf, 'name',['Maps : ' remove_(file_name),'.'])

end %plot_colourmaps(RMS_mat,SNR_mat_DB,LFN_mat_DB,HFN_mat_DB)

function [samp_freq,freq_axis_KHz,fft_d_temp,RMS_mat,SNR_mat_DB,LFN_mat_DB,HFN_mat_DB]  =  calculate_mat_properties(time_,ALL_time_d,time_d,exitation_freq_kHz,SNR_bandwidth_kHz)

samp_freq  = 1/(time_(2)- time_(1));
temp_f = [1:length(time_)]/length(time_)*samp_freq/1000;
freq_axis_KHz = temp_f(1:floor(length(temp_f)/2));

tem_f_d = abs(fft(time_d));
fft_d_temp = tem_f_d(1: floor(length(tem_f_d)/2),:,:);

SNR_mat_DB  =  zeros(size((fft_d_temp),2),size((fft_d_temp),3));

%rms_square_response_tmp    =  squeeze(sqrt(mean((time_d(:,:,:)).^2)));
%RMS_mat =   rms_square_response_tmp -diag(diag(rms_square_response_tmp));

for index_a = 1:size((fft_d_temp),2)
for index_b = 1:size((fft_d_temp),3)
current_fft_tmp =  fft_d_temp(: ,index_a,index_b);
sig_tmp = sum(current_fft_tmp(find(freq_axis_KHz< (exitation_freq_kHz +SNR_bandwidth_kHz)  & freq_axis_KHz> (exitation_freq_kHz -SNR_bandwidth_kHz))));
noise_tmp = sum(current_fft_tmp((find(freq_axis_KHz> (exitation_freq_kHz +SNR_bandwidth_kHz) | freq_axis_KHz < (exitation_freq_kHz -SNR_bandwidth_kHz)))));


%LFN
Low_freq_temp     = sum(current_fft_tmp(find(freq_axis_KHz< (exitation_freq_kHz -SNR_bandwidth_kHz))));
not_Low_freq_temp = sum(current_fft_tmp(find(freq_axis_KHz> (exitation_freq_kHz -SNR_bandwidth_kHz))));

%HFN
High_freq_temp     = sum(current_fft_tmp(find(freq_axis_KHz> (exitation_freq_kHz +SNR_bandwidth_kHz))));
not_High_freq_temp = sum(current_fft_tmp(find(freq_axis_KHz< (exitation_freq_kHz +SNR_bandwidth_kHz)))); 

RMS_mat_LIN(index_a,index_b) = sig_tmp;
SNR_mat_DB(index_a,index_b) =  10*log10(sig_tmp /noise_tmp);
LFN_mat_DB(index_a,index_b) =  10*log10(Low_freq_temp/not_Low_freq_temp);
HFN_mat_DB(index_a,index_b) =  10*log10(High_freq_temp/not_High_freq_temp);

end % for index_b = 1:size((fft_d_temp),3)
end % for index_a = 1:size((fft_d_temp),2)

RMS_mat =  RMS_mat_LIN ;
RMS_mat (eye(size(RMS_mat ))==1)=0;
RMS_mat = RMS_mat/mean(mean(RMS_mat));

end %function [samp_freq,freq_axis_KHz,fft_d_temp,RMS_mat,SNR_mat_DB,LFN_mat_DB,HFN_mat_DB]  =  calculate_mat_properties(time_,ALL_time_d,time_d,exitation_freq_kHz,SNR_bandwidth_kHz);

function do_plots =  choose_plots_to_show(plot_list)
[ones_,~] = listdlg('ListString',plot_list);
do_plots(ones_) = 1;
end %function do_plots =  choose_plots_to_show(plot_list);

function [ALL_time_d,time_d,ALL_time,time_ ] =  load_the_data_from_structure(test_data,time_gate)
ALL_time_d   =   test_data.raw_data.time_data ; 
time_d       =  ALL_time_d(time_gate:end,:,:) ;
ALL_time     = test_data.raw_data.time        ;
time_        = ALL_time(time_gate:end)        ;
end %function [ALL_time_d,time_d,ALL_time,time_ ] =  load_the_data_from_structure(test_data,time_gate);  

function [ALL_time_d,time_d,ALL_time,time_ ]  = load_the_data_from_file(file_path_,file_name,time_gate) 
dummy =  load([file_path_,file_name]);
ALL_time_d   =   dummy.test_data.raw_data.time_data   ; 
time_d     =  ALL_time_d(time_gate:end,:,:)       ;
ALL_time   = dummy.test_data.raw_data.time          ;
time_      = ALL_time(time_gate:end)            ;
end %function [ALL_time_d,time_d,ALL_time,time_ ]  = load_the_data_from_file(file_path_,file_name) 

function  name_ = remove_(name_)
name_(find(name_=='_'))= ' ';
end






