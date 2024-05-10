function [sym_vals,max_] = get_mode_symmetry_vals(md_vals )

A = max( md_vals(1,2)/md_vals(2,1),md_vals(2,1)/md_vals(1,2));
B = max( md_vals(1,3)/md_vals(3,1),md_vals(3,1)/md_vals(1,3));
C = max( md_vals(1,4)/md_vals(4,1),md_vals(4,1)/md_vals(1,4));
D = max( md_vals(2,3)/md_vals(3,2),md_vals(3,2)/md_vals(2,3));
E = max( md_vals(2,4)/md_vals(4,2),md_vals(4,2)/md_vals(2,4));
F = max( md_vals(3,4)/md_vals(4,3),md_vals(4,3)/md_vals(3,4));
sym_vals = [A,B,C,D,E,F];
max_ = max(sym_vals);
end