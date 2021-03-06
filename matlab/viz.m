%% load data
clear; close all; clc;

import_fieldtrip();

[sensors,sensor_labels] = read_elc('./../duneuropy/Data/electrodes.elc');
sensor_labels = split(sensor_labels{4});
sensor_labels = sensor_labels(1:end-1);

eeg = double(readNPY('../../../Downloads/one_two_sources/eeg.npy'));

sources = double(readNPY('../../../Downloads/one_two_sources/sources.npy'));

predicted_sources = double(readNPY('../../../Downloads/one_two_sources/predicted_sources.npy'));

load('../duneuropy/Data/dipoles_downsampled_10k.mat')

layout = '/home/thanos/fieldtrip/template/layout/EEG1010.lay';

[sensors_1010, lay] = compatible_elec(sensor_labels, layout);

%% Visualize random dipole

n_samples = size(eeg,2);
sample = randi([1 n_samples],1,1);


eeg_s = eeg(:,sample);


% scatter3(sensors(:,1),sensors(:,2),sensors(:,3),73,eeg_s,'.')

idx = ismember(sensor_labels, lay.label)';

tlabels=lay.label(idx)';
tpos=lay.pos(idx,:);

% [Zi, Yi, Xi ] = ft_plot_topo(sensors_1010(:,1),sensors_1010(:,2),eeg_s,'mask',lay.mask,'outline',lay.outline);
% 
% Zi = -replace_nan(Zi);
% figure;
% subplot(1,2,1)
% fac = 0.9;
% contourf(Xi,Yi,Zi);
% hold on;
% scatter(sensors_1010(:,1),sensors_1010(:,2),100,'k','.');
% hold on;
% plot(lay.outline{1}(:,1)*fac,lay.outline{1}(:,2)*fac,'k');
% plot(lay.outline{2}(:,1)*fac,lay.outline{2}(:,2)*fac,'k');
% plot(lay.outline{3}(:,1)*fac,lay.outline{3}(:,2)*fac,'k');
% plot(lay.outline{4}(:,1)*fac,lay.outline{4}(:,2)*fac,'k');
% title(sprintf('Topography for sample: %d',sample));
%colorbar;
%colormap(spring(20))
%saveas(gcf,'../assets/sim.png')


loc = cd_matrix(:,1:3);

figure;
subplot(1,2,1)
scatter3(loc(:,1),loc(:,2),loc(:,3),100,predicted_sources(:, sample),'.')
view([-103.9 -6.8])
title('Predicted');

subplot(1,2,2);
source = sources(:, sample);
scatter3(loc(:,1),loc(:,2),loc(:,3),100,source,'.')
title(sprintf('Simulated source space for sample: %d',sample));
colorbar;
%colormap(spring(20))
view([-103.9 -6.8])
set(gcf,'Position',[60 180 1600 500])


