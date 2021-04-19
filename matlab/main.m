clear all; %#ok<*CLALL>
% illuminance map with 360 Pano-Camera (Ricoh Theta Z1)
% Type source file: [DIVA output hdr image]
% Hankun Li, University of Kansas
% Simple UI input version [long-term compatibility concern]
% Lighting Research Laboratory 
% update: 10/25/2020, version 1.2
%
%Author Notes on Usages:
%[1]illuminance map is to show the distribution of percieved light.
%user need to evaluate based on the whole map, check gradient.
%[2]CV_map is to show light uniformity at every specified direction, high
%number means at specific direction, light in 180-deg view is not uniform

%Camera parameters (Ricoh Theta Z1):
%DO NOT CHANGE FOR THETA Z1 CAMERA!
f = 3; % specify lens focal length ##(INPUT2)##
% sx = sy = f*1.414*2
sx = 8.48; sy = 8.48; % Calculated sensor size (Single 180deg fisheye)
%---------Camera parameter end----------%

%% UI initialization:
[fn,pn]=uigetfile('*.hdr','select a dual fisheye 360 hdr image'); str=[pn,fn];
[tilt_a,tilt_b,aim_a,aim_b,aim_step,compr,ac] = initial_dialog();
pano = hdrread(str); pano = imresize(pano, 1/compr); tilt_step = aim_step;
[y,x] = size(pano(:,:,1)); 

%% DIVA Reverse correction:
diva_cf = GetExpValue(str);
pano = pano./diva_cf;
%

%% make query martix:
i = aim_a; illu_map = []; ct = 1;
while i <= aim_b
    j = tilt_a; %ta
    while j <= tilt_b
        illu_map(ct,1) = j; illu_map(ct,2) = i; 
        ct = ct + 1;
        j  = j + tilt_step;
    end
    i = i + aim_step; %aa
end

% Generate a CV map?
% default is on (1), disable it change to (0) and unquote content below!
cv_flg = 1; 
%{
yn = yn_dialog('Generate Coefficient of Variance Map?'); %need five reference value!
if ismember(yn, ['Yes', 'yes'])
    cv_flg = 1;
end
%}
%% 
for z = 1: size(illu_map,1)
    IF_hdr = imequ2fish_hdr(pano,illu_map(z,1),illu_map(z,2) + ac, 0); %tmp +180 (in some case), check 0 direction with real HDR
    [hy,hx] = size(IF_hdr(:,:,1)); 
    if hy ~= hx
        IF_hdr = imresize(IF_hdr,[hy,hy]);
    end
    L = LuminanceRetrieve(IF_hdr,hy);%temporary global CF function!
    illu_map(z,3) = PerPixel_Fequisolid(hy,hy,sx,sy,f,L); %#ok<*SAGROW>
    if cv_flg
        illu_map(z,4) = std(L(:,3))/mean(L(:,3)); %CV map, gen source data
    end
end

illuminancePlot(illu_map,tilt_step,aim_step,tilt_a,tilt_b,aim_a,aim_b); %plot illuminance map
if cv_flg
    CVPlot(illu_map,tilt_step,aim_step,tilt_a,tilt_b,aim_a,aim_b) %plot cv map
end
%% Generate a report of data summary
yn = yn_dialog('Generate a brief lighting summary?'); 
if ismember(yn, ['Yes', 'yes'])
    staReport(illu_map,cv_flg);
end
%%
% Generate a report of similarity (if you already have the real scenario data)
yn = yn_dialog('Evaluated modeling with real scenario?'); 
if ismember(yn, ['Yes', 'yes'])
    Evalsim(illu_map);
end