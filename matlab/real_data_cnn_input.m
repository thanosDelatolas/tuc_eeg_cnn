clear; close all; clc;


layout = '/home/thanos/fieldtrip/template/layout/EEG1010.lay';
[sensors_1010, lay] = compatible_elec(EEG_avg.label, layout);

% 25ms ,151
% 24.2 ms 150
% 25.8 ms 152
% 24 ms 145

eeg_s = (EEG_avg.avg(:,150) - mean(EEG_avg.avg(:,150)))/std(EEG_avg.avg(:,150));
[Zi, Yi, Xi ] = ft_plot_topo(sensors_1010(:,1),sensors_1010(:,2),eeg_s,'mask',lay.mask,'outline',lay.outline);
Zi = -replace_nan(Zi);

figure;
contourf(Xi,Yi,Zi)
title('EEG topography.');

save('../real_data/eeg_topo_real_20.mat', 'Zi');
save('../real_data/eeg_topo_real_20_xi.mat', 'Xi');
save('../real_data/eeg_topo_real_20_yi.mat', 'Yi');

%% 


load('../real_data/eeg_topo_real_20.mat');
load('../real_data/eeg_topo_real_20_xi.mat');
load('../real_data/eeg_topo_real_20_yi.mat');


load('../duneuropy/Data/dipoles_downsampled_5k.mat')

pred = readNPY('../../../Downloads/pred_sources_real_20.npy');



loc = cd_matrix(:,1:3);

figure;
subplot(1,2,1)
contourf(Xi,Yi,Zi)
title('EEG topography.');



subplot(1,2,2)
scatter3(loc(:,1),loc(:,2),loc(:,3),100,pred,'.')

title('Predicted source');
view([121.7 21.2]);

suptitle('Read Data Prediction 24.2ms')
set(gcf,'Position',[60 180 1600 500])


