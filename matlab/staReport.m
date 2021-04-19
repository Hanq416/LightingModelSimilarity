%data analysis function
function staReport(imap,cv_flg)
th = -30; % statisic starting angle range [-90 to 90], 0: defualt
%lux results
lux_max = max(imap(:,3)); %max lux number
%average lux of direction with positive tilting angle
row_pos = (-1.*imap(:,1)>= th); 
lux_avg = mean(nonzeros(imap(:,3).*row_pos));
lux_std = std(nonzeros(imap(:,3).*row_pos));
%CV results
if cv_flg
    cv_max = max(imap(:,4)); %most unnuniform
    ycv = find(imap(:,4) == cv_max);
end
%find aiming direction
ylux = find(imap(:,3) == lux_max);
%calculating EV and Eh
yev = find(imap(:,1) == 0);
yev(:,2) = imap(yev(:,1),3);
yev(:,3) = find(imap(:,1) == -90);
yev(:,4) = imap(yev(:,3),3);
%generate a brief report:
fprintf('Brief Uniformity Data Evaluation: \n');
fprintf('\n[1] Aiming direction of max illuminance\n');
fprintf('Horizontal : %d(deg); Vertical : %d(deg); Max illuminance: %.2f(lux)\n',...
    imap(ylux(1),2),-1.*imap(ylux(1),1),lux_max);
fprintf('\n[2] Average illuminance of veritcal aiming direction >= %d (deg)\n',th);
fprintf('Average illuminance: %.2f(lux); Standard Deviation: %.2f(lux)\n', lux_avg, lux_std);
if cv_flg
    fprintf('\n[3] Aiming Direction with <MOST Ununiform> lighting condition\n');
    fprintf('Horizontal : %d(deg); Vertical : %d(deg); Coefficient of Variance: %.3f\n',...
        imap(ycv,2),-1.*imap(ycv,1),cv_max);
end
fprintf('\n[4] Veritcal illuminance (Ev) = %.2f lux \n',mean(yev(:,2)));
fprintf('    Horizontal illuminance (Eh) = %.2f lux \n',mean(yev(:,4)));
end