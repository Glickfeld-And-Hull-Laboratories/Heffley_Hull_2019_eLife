%% SECTION ONE - assign pathnames and datasets to be analyzed/written. 
clear;
days = {'151021_img29', '151022_img29', '151009_img30', '151011_img30', '151211_img32', '151212_img32', '160129_img35', '160131_img35', '160129_img36', '160131_img36', '160314_img38', '160315_img38', '160319_img41', '160320_img41', '160606_img46', '160722_img53', '160904_img55'}; %'150718_img27', '150719_img27', '150716_img28', '150717_img28', 
days = {'170705_img98', '170421_img87', '170706_img98'}; %img86_10%OR_10%%UR  170420_img87_10%/10%   170417_img88_10/10
WF_CRP_list_of_days;
days = days_1;

bx_source     = ['Z:\Data\WidefieldImaging\GCaMP\behavior\'];
image_source_base  = ['Z:\Data\WidefieldImaging\GCaMP\']; %location of permanently stored image files for retreiving meta data
analysis_base = ['Z:\Analysis\WF Lever Analysis\'];
analysis_base2 =['Z:\Analysis\WF Lever Analysis rerun\'];
image_dest_base    = [analysis_base, 'BxAndAnalysisOutputs\']; %stores the data on crash in the lever analysis folder
bx_outputs_dir = [analysis_base, 'BxAndAnalysisOutputs\BxOutputs\'];
PCA_output_dir_base = [analysis_base, 'PCA_output_dir\'];
kmeans_output_dir_base = [analysis_base, 'kmeans_output_dir\'];

%% SECTION TWO - Uses a gui to allow user to draw ROIs 
for ii = 1:length(days)
    days{ii}
    image_source = [image_source_base, days{ii}, '_1'];
    image_dest = [image_dest_base days{ii} '\' days{ii}];
    if exist([image_dest_base days{ii}], 'file') ~= 7;
        mkdir(image_dest_base, days{ii});
    end
    WF_draw_ROIs_for_lever(days{ii}, image_source, image_dest); %automatically saves the ROIs
end

%% SECTION THREE - find/save frame times and meta data collected from the tiff files 
for ii = 1:length(days)
    image_source = [image_source_base, days{ii}, '_1'];
    [all_files, meta_data, meta_data2] = obtain_tif_meta_data(image_source);
    frame_times = get_frame_time_by_movie_info(meta_data);
    dest =  [image_dest_base days{ii} '\' days{ii}];
    if exist([image_dest_base days{ii}], 'file') ~= 7;
        mkdir(image_dest_base, days{ii});
    end
    save([dest '_frame_times'],  'frame_times');
    save([dest '_meta_data'],  'meta_data', 'meta_data2', 'all_files');
end

%% SECTION FOUR - calculate TC of raw F for each ROI
for ii = 1:length(days)
    image_dest = [image_dest_base days{ii} '\' days{ii}];
    meta_data_dir = [image_dest_base days{ii} '\' days{ii} '_meta_data'];
    cluster_dir = [image_dest_base days{ii} '\' days{ii} '_cluster'];
    %bx_out_dir  = [bx_outputs_dir days{ii} '_bx_outputs'];
    bx_out_dir  =[analysis_base2, 'BxAndAnalysisOutputs\BxOutputs\', days{ii} '_bx_outputs'];
    calculate_data_tc(meta_data_dir, cluster_dir, bx_out_dir, days_1_stable_int{ii}); %automatically saves data_tc to bxOutputs
end

%% SECTION FIVE - obtain bx and frame info from MWorks.
for ii =  1:length(days)
    days(ii)
    image_dest = [image_dest_base days{ii} '\' days{ii}];
    meta_data_dir = [image_dest '_meta_data'];
    frame_times_dir = [image_dest  '_frame_times'];
    bx_out_dir  = [bx_outputs_dir days{ii} '_bx_outputs'];
    b_data = get_bx_data(bx_source, days{ii});  %find the correct behavior file and loads it.
    [frame_info, lever] = parse_frame_data_for_HAD(b_data, frame_times_dir);
    [trial_outcome, lickTimes] = parse_behavior_for_HAD(b_data, frame_info);
    save(bx_out_dir, 'lever', 'frame_info', 'trial_outcome', 'lickTimes', '-append');
end

%% SECTION SIX - calculate df/f TC. baseline f redefined on a trial by trial basis
for ii = 1:length(days)
    bx_out_dir  = [bx_outputs_dir days{ii} '_bx_outputs'];
    %bx_out_dir2  =[analysis_base2, 'BxAndAnalysisOutputs\BxOutputs\', days{ii} '_bx_outputs'];
    b_data = get_bx_data(bx_source, days{ii});  %find the correct behavior file and loads it.
    tc_dfoverf = tbyt_dfoverf(b_data, bx_out_dir);
    save(bx_out_dir, 'tc_dfoverf', '-append');
end

%% PLOT TCs save TCs for summary plots
  %WF_lever_plotting_TCs;
  WF_CRP_lever_plotting_TCs
% struct_maker;
% plot_variables_from_structs;

