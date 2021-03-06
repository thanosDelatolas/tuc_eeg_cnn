clear; close all; clc;

%A1999,A1974,A0206
subject='A0206';
ms_A1999={'17_5','21_7','22_5','23','20_8'}; 
ms_A0206='25';
ms_A1974={'22_5','23_3','24_2','25'}; 

ms=ms_A0206;


load(sprintf('../real_data/%s/EEG_avg.mat',subject));

% plot EEG_avg
pol = -1;     % correct polarity
scale = 10^6; % scale for eeg data micro volts
signal_EEG = scale*pol*EEG_avg.avg; % add single trials in a new value
figure;
plot(EEG_avg.time,signal_EEG,'color',[0,0,0.5]);


load(sprintf('../real_data/%s/%sms/eeg_topo_real_%sms.mat',subject,ms,ms));
load(sprintf('../real_data/%s/%sms/eeg_topo_real_xi_%sms.mat',subject,ms,ms));
load(sprintf('../real_data/%s/%sms/eeg_topo_real_yi_%sms.mat',subject,ms,ms));



% load source space and the fsl linear registration output.
if strcmp(subject,'A1974')
    load(sprintf('../real_data/%s/%s_source_space.mat',subject,subject));
    % apply the linear registration matrix from fsl
    cd_matrix = apply_lt_matrix(sprintf('../mri_data/%s/%s_regist.mat',subject,subject),cd_matrix(:,1:3));
    
    T1_name = sprintf('../mri_data/%s/%s_regist.nii',subject,subject);
    
elseif strcmp(subject,'A1999')
    load(sprintf('../real_data/%s/%s_source_space.mat',subject,subject));
    cd_matrix = apply_lt_matrix(sprintf('../mri_data/%s/%s_regist.mat',subject,subject),cd_matrix(:,1:3));
     
     T1_name = sprintf('../mri_data/%s/%s_regist.nii',subject,subject);
elseif strcmp(subject,'A0206')
    load('../duneuropy/Data/dipoles.mat')
    
    T1_name = sprintf('../mri_data/%s/%s_mri.nii',subject,subject);
end

eeg_idx = get_eeg_idx(subject,ms);

% load the neural net's prediction
neural_net_pred = double(readNPY(sprintf('../real_data/%s/%sms/pred_sources_%s.npy',subject,ms,ms)));


[neural_net_pred,location_nn] = create_source_activation_vector(...
    neural_net_pred,'loc_cnn',cd_matrix);

figure;
scatter3(cd_matrix(:,1),cd_matrix(:,2),cd_matrix(:,3),100,neural_net_pred,'.')
title('Neural Net prediciton');
colorbar;

import_fieldtrip();

mri_t1        = ft_read_mri(T1_name);

mri_data_scale     = 60;
mri_data_clipping  = 1;

% create the source grid
source_grid = downsample(cd_matrix(:,1:3),3);


% project to MRI the neural net's prediction
source_activation_mri(mri_t1,mri_data_scale,neural_net_pred,source_grid,...
    mri_data_clipping,EEG_avg.time(eeg_idx),'Localization with Neural Net');

