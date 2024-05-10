function  [data_ ,checked_ok] = load_structure_from_file(varargin)



% variable input to allow a check on field values ;
switch(nargin)
    case(1)
file_name           = varargin{1} ;  
    case(2)
file_name           = varargin{1} ;
expected_fields     = varargin{2} ;  
end %switch(nargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% msgbox(file_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

raw_data    =  get_raw_data(file_name);
%keyboard
data_       =  process_raw_data(raw_data);
if nargin ==2

checked_ok =  check_fields_present (data_ ,expected_fields) ;
else    
checked_ok =  NaN;   
end

end %function  data_ =  load_structure_from_file(file_name)

function data_  =  process_raw_data(raw_data)

counter = 0;
for index = 1:length(raw_data)

if raw_data{index}(1) == '%'

if length(strfind(raw_data{1},'%'))==1
disp('warning there should be a terminating % on the variable name string')   
end
counter = counter + 1 ;
variable_names            {counter} =  raw_data{index};
variable_names_line_number(counter) =  index; 
end %if raw_data{index}(1) == '%'

end %for index = 1:length(raw_data)
variable_names_line_number (counter+1) = length(raw_data) + 1;

for index = 1: length(variable_names)
variable_name_temp = remove_the_percents(variable_names{index});

variable_val    = get_variable_val(variable_names_line_number(index)+ 1 ,variable_names_line_number(index+1)-1,raw_data);
eval (['data_.',variable_name_temp,' = variable_val;']);
end %for index = 1: length(variable_names)
end %function data       =  process_raw_data

function variable_val    = get_variable_val(start_ind,end_ind,raw_data)
%disp ([num2str(start_ind),':',num2str(end_ind)])
if start_ind == end_ind
if length(str2num(remove_all_spaces(raw_data{start_ind}))) >= 1  
variable_val = str2num( remove_all_spaces(raw_data{start_ind})  );
else
variable_val = raw_data{start_ind};    
end %if length(str2num(raw_data{start_ind})) >= 1  

else
counter = 0;
for index = start_ind:end_ind
counter = counter + 1;


if length(str2num(raw_data{index})) >= 1
variable_val(counter,:)= str2num(remove_all_spaces(raw_data{index}))    ;
else
variable_val{counter} = raw_data{index}              ;
if index == end_ind
variable_val = variable_val'                ;
end %if index == end_ind
end %if str2num(raw_data{index})

end %for index = start_ind:end_ind
end %if start_ind == end_ind
end %function variable_val    = get_variable_val([start_ind end_ind],raw_data);

function raw_data =  get_raw_data(file_name)

fileID = fopen(file_name,'r')                ; 
at_start = 0                             ;

while at_start == 0
    dummy = remove_all_spaces(fgetl(fileID));
    if strcmp(dummy,'START') == 1
    at_start = 1                         ; 
    end % if  strcmp(aa,'START') ==1
end %while at_start == 0

at_end = 0 ;
counter = 0;
while at_end == 0
    counter = counter + 1;
    %dummy = remove_all_spaces(fgetl(fileID))  ;
    dummy = fgetl(fileID)  ;
    if strcmp(dummy,'END') == 1
    at_end = 1                                ; 
    else
    raw_data{counter} =  dummy                ;    
    end % if  strcmp(aa,'START') ==1
end %while at_end == 0
end %function get_raw_data(file_name 

function  checked_ok =  check_fields_present (data_ ,expected_fields) 

checked_ok = 1 ;
for index = 1:length(expected_fields)

switch(length(find(expected_fields{index}=='.')))
    case(0)
if ~isfield(data_,expected_fields{index})
disp(['Warning:: expected field ',expected_fields{index},' not present']) 
checked_ok = 0;
end % if ~isfield(data_,expected_fields{index})
    case(1)
%root_field  =  expected_fields{index}(1:find(expected_fields{24}=='.')-1);
%sub_field   =  expected_fields{index}(find(expected_fields{24}=='.')+1:end);
root_field  =  expected_fields{index}(1:find(expected_fields{index}=='.')-1);
sub_field   =  expected_fields{index}(find(expected_fields{index}=='.')+1:end);
eval(['val__ = ~isfield(data_.',root_field,',','''',sub_field,''');'])
if val__
disp(['Warning:: expected field ',expected_fields{index},' not present']) 
checked_ok = 0;
end %if val__
end %switch(length(find(expected_fields{1}=='.')))

end %for index = 1:length(expected_fields)
% isfield(data_,expected_fields{1})

end %function  checked_ok =  check_fields_present (data_ ,expected_fields) ;

function new_text = remove_the_percents(txt_)
inds_ =  find(txt_=='%') ;
if length(inds_) >= 2 
new_text = txt_(inds_(1)+1:inds_(2)-1); 
else
new_text = txt_(inds_(1):end);
end %if length(inds_) >= 2 


end %function new_text = remove_the_percents(txt_)

function txt_ =  remove_all_spaces(txt_)
txt_(strfind(txt_,' '))=[];
end %function new_text =  remove_end_space(txt_)
