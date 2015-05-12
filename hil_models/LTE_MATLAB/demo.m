function demo(IP)
%while(1)
    [plots,~,~]=ad9361_LTE(IP,'LTE1.4');
    close all;
    
    delete(plots{1});delete(plots{2});delete(plots{3});delete(plots{4});
    clear functions;
    [plots,~,~]=ad9361_LTE(IP,'LTE3');
    close all;
    
    delete(plots{1});delete(plots{2});delete(plots{3});delete(plots{4});
    clear functions;
    [plots,~,~]=ad9361_LTE(IP,'LTE5');
    close all;
    
    delete(plots{1});delete(plots{2});delete(plots{3});delete(plots{4});
    clear functions;
    [plots,~,~]=ad9361_LTE(IP,'LTE10');
    close all;
    
    delete(plots{1});delete(plots{2});delete(plots{3});delete(plots{4});
    clear functions;
%end