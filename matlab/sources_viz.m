%% Load data
clear; close all; clc;

load('../duneuropy/Data/dipoles_downsampled_5k.mat')

sources = readNPY('/media/thanos/Elements/thanos/sim_data/sim_type_1/downsampled_dipoles-5k/1e-1/sources_20TeD.npy');
predicted_sources = readNPY('../../../Downloads/pred_sources.npy');

load('/media/thanos/Elements/thanos/sim_data/sim_type_1/downsampled_dipoles-5k/1e-1/eeg_20TeD_topos.mat')
load('/media/thanos/Elements/thanos/sim_data/sim_type_1/downsampled_dipoles-5k/1e-1/eeg_20TeD_xi.mat')
load('/media/thanos/Elements/thanos/sim_data/sim_type_1/downsampled_dipoles-5k/1e-1/eeg_20TeD_yi.mat')


%% visualize

% close all;

n_samples = size(predicted_sources,2);

source_idx = randi([1 n_samples],1,1);


source = sources(:, source_idx);
pred = predicted_sources(:,source_idx);
loc = cd_matrix(:,1:3);

Zi = eeg_topos(:,:,source_idx);
Xi = eeg_Xi(:,:,source_idx);
Yi = eeg_Yi(:,:,source_idx);

figure;
subplot(1,3,1)
contourf(Xi,Yi,Zi)
title('EEG topography.');


subplot(1,3,2)
scatter3(loc(:,1),loc(:,2),loc(:,3),100,source,'.')
title('Simulated source');
view([121.7 21.2]);

subplot(1,3,3)
scatter3(loc(:,1),loc(:,2),loc(:,3),100,pred,'.')
title('Predicted source');
colorbar;
view([121.7 21.2]);

suptitle(sprintf('Sample %d',source_idx))
set(gcf,'Position',[60 180 1600 500])
