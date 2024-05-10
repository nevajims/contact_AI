
function formated_output =  display_Block_data_stats(Block_DATA)

formated_output = 'Number of tests for each data set\n' ;

for index = 1:length(Block_DATA.Labels_)
formated_output = [formated_output,'Tag = ', Block_DATA.Labels_{index},'(',num2str(length(find(Block_DATA.tag_label_index==index))),')\n'];
end %for index = 1:length(Block_DATA.Labels_)

end %function display_Block_data_stats(Block_DATA);
