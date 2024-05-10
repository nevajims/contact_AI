
function [score_table,log_lik_table, rank_table,within_range_table,std_dist_table, predict_tag,LL_tag] = get_tag_scores (Score_vals,labels,mode_pairs_to_Use,Tags_,std_bar_size,include_LL)

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

if include_LL == 1
for index = 1 :length(Score_vals.Means_)

 temp_ = round(100*abs(log( Score_vals.Stds_{index}.*pdf('Normal',Score_vals. spec_vals_ , Score_vals.Means_{index},Score_vals.Stds_{index}))))/100;


log_lik(index,:) = [temp_,mean(temp_)];
end % for index = 1 :length(Score_vals.Means_)
end %if include_LL == 1


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

if include_LL == 1
log_lik_table = array2table(log_lik,...
       'VariableNames',columns__,...
       'RowNames',Tags_); 
[~ ,LL_indx]  =  min(log_lik(:,end));
LL_tag = Tags_{LL_indx};
else
log_lik_table = NaN;
LL_tag        = NaN;   
end %if include_LL == 1


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
