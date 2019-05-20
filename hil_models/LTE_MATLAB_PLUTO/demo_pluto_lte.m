function demo_pluto_lte(IP)
plots = [];
while(1)
    [plots,~,~]=pluto_LTE(IP,'LTE10',plots);
%     delete(plots{1});delete(plots{2});delete(plots{3});delete(plots{4});
end