
function TString = remove_strong(TString)


lefts_  = find(TString=='<');
rights_  = find(TString=='>');

if length(lefts_ ) ~= length(rights_)
disp('length(lefts_ ) ~= length(rights_)')
else
    %disp('ok')
end

for index = length(lefts_):-1:1
TString(lefts_(index):rights_(index)) = '';
end %for index = length(lefts_):-1:1

end %function remove_strong(text_string)
