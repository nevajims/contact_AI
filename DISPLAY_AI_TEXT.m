function DISPLAY_AI_TEXT(all_display_data , data_to_display,file_name)

% data_to_display.display_txt = [1 1 1 1 1 1 1 1 1 1 1 ]     ;
% data_to_display.display_plots = [1 1 1]                    ;


fid = fopen(file_name, 'w');
show_on_console = 0;

% displays that bits you seect in      data_to_display
% put allthe disps in on output window
% data_to_display.display_txt = [1 1 1 1 1 1 1 1 1 1 1 ]     ;
% data_to_display.display_plots = [1 1 1]                    ; 
% DISPLAY_AI_DATA(output_,data_to_display )


if data_to_display.display_txt(1)== 1
%-----------------------------------------------------------
% DISP 1
fprintf(fid, all_display_data.txt{1});
if show_on_console == 1
fprintf(all_display_data.txt{1})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(2)== 1
%-----------------------------------------------------------
% DISP 2
fprintf(fid, all_display_data.txt{2});
if show_on_console == 1
fprintf(all_display_data.txt{2})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(3)== 1
%-----------------------------------------------------------
% DISP 3
fprintf(fid, all_display_data.txt{3});
if show_on_console == 1
fprintf(all_display_data.txt{3})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(4)== 1
%-----------------------------------------------------------
% DISP 4
fprintf(fid, all_display_data.txt{4});
if show_on_console == 1
fprintf(all_display_data.txt{4})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(5)== 1
%-----------------------------------------------------------
% DISP 5
fprintf(fid, all_display_data.txt{5});
if show_on_console == 1
fprintf(all_display_data.txt{5})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(6)== 1
%-----------------------------------------------------------
% DISP 6
fprintf(fid, all_display_data.txt{6});
if show_on_console == 1
fprintf(all_display_data.txt{6})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(7)== 1
%-----------------------------------------------------------
% DISP 7
fprintf(fid, all_display_data.txt{7});
if show_on_console == 1
fprintf(all_display_data.txt{7})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(8)== 1
%-----------------------------------------------------------
% DISP 8
fprintf(fid, all_display_data.txt{8});
if show_on_console == 1
fprintf(all_display_data.txt{8})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(9)== 1
%-----------------------------------------------------------
% DISP 9
fprintf(fid, all_display_data.txt{9});
if show_on_console == 1
fprintf(all_display_data.txt{9})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(10)== 1
%-----------------------------------------------------------
% DISP 10
fprintf(fid, all_display_data.txt{10});
if show_on_console == 1
fprintf(all_display_data.txt{10})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(11)== 1
%-----------------------------------------------------------
% DISP 11
fprintf(fid, all_display_data.txt{11});
if show_on_console == 1
fprintf(all_display_data.txt{11})
end
%-----------------------------------------------------------
end

fclose (fid);
if sum(data_to_display.display_txt) > 0
eval(['!notepad ',file_name, ' &'])
end
end      %function DISPLAY_AI_DATA(all_display_data , data_to_display,file_name)






