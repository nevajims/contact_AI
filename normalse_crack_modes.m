
function norm_crack_mode_ = normalse_crack_modes(crack_mode_,normalising_mode_pair,PP_index)

for index = 1:length(crack_mode_)
dummy =  crack_mode_{index}{PP_index};    
norm_crack_mode_(:,:,index) = dummy / dummy(normalising_mode_pair(1),normalising_mode_pair(2));
end %for index = 1:length(crack_mode_)

end% function norm_crack_mode_ = normalse_crack_modes(Block_DATA.crack_mode_,normalising_mode_pair)
