function [max_vals,max_,min_] = get_mode_vals(md_vals )

A = max([ md_vals(1,2),md_vals(2,1)]);
B = max([ md_vals(1,3),md_vals(3,1)]);
C = max([ md_vals(1,4),md_vals(4,1)]);
D = max([ md_vals(2,3),md_vals(3,2)]);
E = max([ md_vals(2,4),md_vals(4,2)]);
F = max([ md_vals(3,4),md_vals(4,3)]);
max_vals = [A,B,C,D,E,F];
max_ = max(max_vals);
min_ = min(max_vals);

end

