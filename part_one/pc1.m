function pc1_mm = pc1(filtered_data)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

[U, S, V ]=svd(filtered_data);
V_1 = V(:,1);
pc1_mm= filtered_data*V_1;

end