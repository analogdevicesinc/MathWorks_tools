clc;
clear;
close all;

aa = 100;
bb = 500;
a = 1:4;
b = 11:15;
c = 6:8;
d = 20:10:70;

m = length(a);
n = length(b);
p = length(c);
q = length(d);

parameters = zeros(4, m*n*p*q);
count = 1;
for ii = 1:m
    for jj = 1:n
        for kk = 1:p
            for ll = 1:q
                parameters(:, count) = [a(ii);b(jj);c(kk);d(ll)];
                count = count+1;
            end
        end
    end
end

sets = {d, c, b, a};
x = cell(1,numel(a));
[x{:}] = ndgrid(sets{:});
cartProd = flipud([x{1}(:) x{2}(:) x{3}(:) x{4}(:)].');
