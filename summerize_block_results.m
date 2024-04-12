function summerize_block_results(combined_data)


overall_settings =  combined_data.overall_settings ;
summary_results  =  combined_data.summary_results  ; 

fprintf(overall_settings.txt{1})

FL_s = zeros(1,length(summary_results));

for index = 1 : length(summary_results)
FL_s(index) =  str2num(summary_results{index}.file_label) ; 
end     %   for index = 1 : length(summary_results)


Unique_FLs = unique (FL_s,'stable' );




for index = 1: length (Unique_FLs) 
type_indices  =  find(FL_s == Unique_FLs(index));

disp('--------------------------------------------')
disp(['File Label number ',num2str(Unique_FLs(index)) ]) 
disp(['File Label ',overall_settings.File_labels{Unique_FLs(index)+1}]) 
disp('--------------------------------------------')

temp_count = 0;
temp_tests = [];
temp_AI = [];
temp_DistM = [];
temp_LeastL = [];

for index_2 = 1: length(type_indices)
temp_count = temp_count + 1;
type_indices(index_2);
temp_tests = [temp_tests;summary_results{type_indices(index_2)}.file_name(find(summary_results{type_indices(index_2)}.file_name=='H'):end-4) ];     

temp_AI{index_2}       =  summary_results{type_indices(index_2)}.predict{1}  ;

temp_DistM{index_2}    = summary_results{type_indices(index_2)}.predict{2}   ;

temp_LeastL{index_2}   = summary_results{type_indices(index_2)}.predict{3}   ;

end %for index_2 = 1: length(type_indices)


Sum_tab{index}.Test   = temp_tests   ;
Sum_tab{index}.AI     = temp_AI'      ;
Sum_tab{index}.DistM  = temp_DistM'   ;
Sum_tab{index}.LeastL = temp_LeastL'  ;

Tab_{index} =   struct2table(Sum_tab{index});
disp(Tab_{index})
end %for index = 1: length (Unique_FLs) 



end       %function summerize_block_results(overall_settings,summary_results)