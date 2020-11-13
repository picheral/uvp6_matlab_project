

%% --------- DAC ------------------------

% ---------- metadata -------------------
meta = ncstruct('C:\Dvlpt_projet_UVP6\Integration_vecteur\NKE\ARGO\Ressources_pour_ARGO_netcdf_ecotaxa\Tests-netcdf\6903069_dac\6903069_meta.nc');
meta.PLATFORM_TYPE'
meta.PLATFORM_NUMBER'
meta.SENSOR'
meta.SENSOR_MODEL'
meta.PREDEPLOYMENT_CALIB_COEFFICIENT'

% % ---------- Trajectoire --------------------
% Rtraj = ncstruct('C:\Dvlpt_projet_UVP6\Integration_vecteur\NKE\ARGO\Ressources_pour_ARGO_netcdf_ecotaxa\Tests-netcdf\6903069_dac\6903069_Rtraj.nc');
%
% % ---------------- Profiles ---------------------------
% Profile = ncstruct('C:\Dvlpt_projet_UVP6\Integration_vecteur\NKE\ARGO\Ressources_pour_ARGO_netcdf_ecotaxa\Tests-netcdf\6903069_dac\profiles\BR6903069_004.nc');
% Profile.LATITUDE'
% Profile.LONGITUDE'
% JULD = Profile.JULD'
% datestr(JULD(1))
%
% JULD_LOCATION = Profile.JULD_LOCATION'
% datestr(JULD_LOCATION(1))

%% ----------- AUX --------------------------
% ---------- metadata -------------------
meta_aux = ncstruct('C:\Dvlpt_projet_UVP6\Integration_vecteur\NKE\ARGO\Ressources_pour_ARGO_netcdf_ecotaxa\Tests-netcdf\6903069_aux\6903069_meta_aux.nc');
PLATFORM_NUMBER =                      meta_aux.PLATFORM_NUMBER'            % 6903069
FLOAT_META_DATA_NAME =                 meta_aux.FLOAT_META_DATA_NAME'
%     'FLOAT_IP_ADDRESS                                                                                                                '
%     'FLOAT_DNIS_NUMBER                                                                                                               '
%     'IRIDIUM_SERIAL_PORT_NUMBER                                                                                                      '
%     'HYDRAULIC_ENGINE_TYPE                                                                                                           '
%     'EMAP_SERIAL_PORT_NUMBER                                                                                                         '
%     'EMAP_POWER_OUTPUT_PORT_NUMBER                                                                                                   '
%     'UseaSensorList_STRING                                                                                                           '
%     'GPS_SERIAL_PORT_NUMBER                                                                                                          '
%     'GPS_POWER_OUTPUT_PORT_NUMBER                                                                                                    '
%     'CTD_SERIAL_PORT_NUMBER                                                                                                          '
%     'DO_SERIAL_PORT_NUMBER                                                                                                           '
%     'OCR_SERIAL_PORT_NUMBER                                                                                                          '
%     'ECO_SERIAL_PORT_NUMBER                                                                                                          '
%     'UVP_SERIAL_PORT_NUMBER                                                                                                          '
%     'FLOAT_SIM_CARD_NUMBER                                                                                                           '
%     'FIRMWARE_VERSION_SECONDARY                                                                                                      '
%     'UVP_ACQ_CONF_01_PARAMETERS                                                                                                      '
%     'UVP_ACQ_CONF_02_PARAMETERS                                                                                                      '
%     'UVP_ACQ_CONF_03_PARAMETERS                                                                                                      '
%     'UVP_ACQ_CONF_04_PARAMETERS                                                                                                      '
%     'UVP_ACQ_CONF_05_PARAMETERS                                                                                                      '
%     'UVP_ACQ_CONF_06_PARAMETERS                                                                                                      '
%     'UVP_ACQ_CONF_07_PARAMETERS                                                                                                      '
%     'UVP_ACQ_CONF_08_PARAMETERS                                                                                                      '
%     'UVP_ACQ_CONF_09_PARAMETERS                                                                                                      '
%     'UVP_ACQ_CONF_10_PARAMETERS                                                                                                      '
%     'UVP_HW_CONF_PARAMETERS                                                                                                          '
%     'FLOAT_WC_NUMBER                                                                                                                 '
FLOAT_META_DATA_VALUE =                 meta_aux.FLOAT_META_DATA_VALUE'
%     '192.168.1.20                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    '
%     '00881600005210                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  '
%     '1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     'HRL1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            '
%     '30                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              '
%     '3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     '2;3;4;8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         '
%     '40                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              '
%     '4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     '50                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              '
%     '1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     '2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     '3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     '6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     '8988169234000799353                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             '
%     '1.00.024                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        '
%     'ACQ_NKE_00H,0,1.000,1,1,0,0,1,0,70,0,620,1.5,10,10,0,1000,0,40,marc.picheral@obs-vlfr.fr,0,0                                                                                                                                                                                                                                                                                                                                                                                                                                    '
%     'ACQ_NKE_00L,0,1.000,1,1,0,0,1,0,70,0,620,1.5,100,10,0,1000,0,40,marc.picheral@obs-vlfr.fr,0,0                                                                                                                                                                                                                                                                                                                                                                                                                                   '
%     'ACQ_NKE_01H,0,1.000,1,1,0,0,1,0,70,0,620,1.5,10,10,0,1000,0,40,marc.picheral@obs-vlfr.fr,0,0                                                                                                                                                                                                                                                                                                                                                                                                                                    '
%     'ACQ_NKE_01L,0,1.000,1,1,0,0,1,0,70,0,620,1.5,100,10,0,1000,0,40,marc.picheral@obs-vlfr.fr,0,0                                                                                                                                                                                                                                                                                                                                                                                                                                   '
%     'ACQ_NKE_20H,0,1.000,1,1,0,0,1,0,70,2,620,1.5,10,10,0,1000,0,40,marc.picheral@obs-vlfr.fr,0,0                                                                                                                                                                                                                                                                                                                                                                                                                                    '
%     'ACQ_NKE_20L,0,1.000,1,1,0,0,1,0,70,2,620,1.5,100,10,0,1000,0,40,marc.picheral@obs-vlfr.fr,0,0                                                                                                                                                                                                                                                                                                                                                                                                                                   '
%     'ACQ_NKE_21H,0,1.000,1,1,0,0,1,0,70,2,620,1.5,10,10,0,1000,0,40,marc.picheral@obs-vlfr.fr,0,0                                                                                                                                                                                                                                                                                                                                                                                                                                    '
%     'ACQ_NKE_21L,0,1.000,1,1,0,0,1,0,70,2,620,1.5,100,10,0,1000,0,40,marc.picheral@obs-vlfr.fr,0,0                                                                                                                                                                                                                                                                                                                                                                                                                                   '
%     'ACQ_NKE_CUST_1,0,1.000,1,1,0,0,1,0,70,2,620,1.5,15,10,0,1000,0,40,marc.picheral@obs-vlfr.fr,0,0                                                                                                                                                                                                                                                                                                                                                                                                                                 '
%     'ACQ_NKE_CUST_2,0,1.000,1,1,0,0,1,0,70,0,620,1.5,30,10,0,1000,0,40,marc.picheral@obs-vlfr.fr,0,0                                                                                                                                                                                                                                                                                                                                                                                                                                 '
%     '000110LP,0,UNDEFINED,0,000112VE,1,150,250,,0.600,393819,10000,2,192.168.0.128,0,275,6,21,2342.000,1.136,73,0.590,20200228,202005260924,marc.picheral@obs-vlfr.fr,40.3,50.8,64,80.6,102,128,161,203,256,323,406,512,645,813,1020,1290,1630,2050                                                                                                                                                                                                                                                                                  '
%     '0096A2C1A2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      '
FLOAT_META_DATA_DESCRIPTION =              meta_aux.FLOAT_META_DATA_DESCRIPTION'
%     'IP address of the float for a bluetooth connection.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             '
%     'DNIS number of the SIM card of the float.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       '
%     'Serial port number used by the Iridium device.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  '
%     'Reference of the hydraulic device.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              '
%     'Serial port number used by the EMAP (USEA controller board).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    '
%     'Power output port number used by the EMAP (USEA controller board).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              '
%     'List of sensors managed by the USEA card (2:DO, 3:OCR, 4:ECO, 5:SBEPH, 6:CROVER, 7:SUNA, 8:UVP6).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     'Serial port number used by the GPS device.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      '
%     'Power output port number used by the GPS device.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                '
%     'Serial port number used by the CTD sensor.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      '
%     'Serial port number used by the DO sensor.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       '
%     '.Serial port number used by the OCR sensor.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     '
%     'Serial port number used by the ECO sensor.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      '
%     'Serial port number used by the UVP sensor.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      '
%     'SIM card number of the float.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   '
%     'Firmware version of secondary controller board.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 '
%     'UVP ACQ_CONF_01 configuration parameters: Configuration_name, PT_mode, Acquisition_frequency, Frames_per_bloc, Blocs_per_PT, Pressure_for_auto_start, Pressure_difference_for_auto_stop, Result_sending, Save_synthetic_data_for_delayed_request, Limit_lpm_detection_size, Save_images, Vignetting_lower_limit_size, Appendices_ratio, Interval_for_mesuring_background_noise, Image_nb_for_smoothing, Analog_output_activation, Gain_for_analog_out, Minimum_object_number, Maximal_internal_temperature, Operator_email, 0, SD card remaining memory (Mbytes).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     'UVP ACQ_CONF_02 configuration parameters: Configuration_name, PT_mode, Acquisition_frequency, Frames_per_bloc, Blocs_per_PT, Pressure_for_auto_start, Pressure_difference_for_auto_stop, Result_sending, Save_synthetic_data_for_delayed_request, Limit_lpm_detection_size, Save_images, Vignetting_lower_limit_size, Appendices_ratio, Interval_for_mesuring_background_noise, Image_nb_for_smoothing, Analog_output_activation, Gain_for_analog_out, Minimum_object_number, Maximal_internal_temperature, Operator_email, 0, SD card remaining memory (Mbytes).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     'UVP ACQ_CONF_03 configuration parameters: Configuration_name, PT_mode, Acquisition_frequency, Frames_per_bloc, Blocs_per_PT, Pressure_for_auto_start, Pressure_difference_for_auto_stop, Result_sending, Save_synthetic_data_for_delayed_request, Limit_lpm_detection_size, Save_images, Vignetting_lower_limit_size, Appendices_ratio, Interval_for_mesuring_background_noise, Image_nb_for_smoothing, Analog_output_activation, Gain_for_analog_out, Minimum_object_number, Maximal_internal_temperature, Operator_email, 0, SD card remaining memory (Mbytes).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     'UVP ACQ_CONF_04 configuration parameters: Configuration_name, PT_mode, Acquisition_frequency, Frames_per_bloc, Blocs_per_PT, Pressure_for_auto_start, Pressure_difference_for_auto_stop, Result_sending, Save_synthetic_data_for_delayed_request, Limit_lpm_detection_size, Save_images, Vignetting_lower_limit_size, Appendices_ratio, Interval_for_mesuring_background_noise, Image_nb_for_smoothing, Analog_output_activation, Gain_for_analog_out, Minimum_object_number, Maximal_internal_temperature, Operator_email, 0, SD card remaining memory (Mbytes).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     'UVP ACQ_CONF_05 configuration parameters: Configuration_name, PT_mode, Acquisition_frequency, Frames_per_bloc, Blocs_per_PT, Pressure_for_auto_start, Pressure_difference_for_auto_stop, Result_sending, Save_synthetic_data_for_delayed_request, Limit_lpm_detection_size, Save_images, Vignetting_lower_limit_size, Appendices_ratio, Interval_for_mesuring_background_noise, Image_nb_for_smoothing, Analog_output_activation, Gain_for_analog_out, Minimum_object_number, Maximal_internal_temperature, Operator_email, 0, SD card remaining memory (Mbytes).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     'UVP ACQ_CONF_06 configuration parameters: Configuration_name, PT_mode, Acquisition_frequency, Frames_per_bloc, Blocs_per_PT, Pressure_for_auto_start, Pressure_difference_for_auto_stop, Result_sending, Save_synthetic_data_for_delayed_request, Limit_lpm_detection_size, Save_images, Vignetting_lower_limit_size, Appendices_ratio, Interval_for_mesuring_background_noise, Image_nb_for_smoothing, Analog_output_activation, Gain_for_analog_out, Minimum_object_number, Maximal_internal_temperature, Operator_email, 0, SD card remaining memory (Mbytes).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     'UVP ACQ_CONF_07 configuration parameters: Configuration_name, PT_mode, Acquisition_frequency, Frames_per_bloc, Blocs_per_PT, Pressure_for_auto_start, Pressure_difference_for_auto_stop, Result_sending, Save_synthetic_data_for_delayed_request, Limit_lpm_detection_size, Save_images, Vignetting_lower_limit_size, Appendices_ratio, Interval_for_mesuring_background_noise, Image_nb_for_smoothing, Analog_output_activation, Gain_for_analog_out, Minimum_object_number, Maximal_internal_temperature, Operator_email, 0, SD card remaining memory (Mbytes).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     'UVP ACQ_CONF_08 configuration parameters: Configuration_name, PT_mode, Acquisition_frequency, Frames_per_bloc, Blocs_per_PT, Pressure_for_auto_start, Pressure_difference_for_auto_stop, Result_sending, Save_synthetic_data_for_delayed_request, Limit_lpm_detection_size, Save_images, Vignetting_lower_limit_size, Appendices_ratio, Interval_for_mesuring_background_noise, Image_nb_for_smoothing, Analog_output_activation, Gain_for_analog_out, Minimum_object_number, Maximal_internal_temperature, Operator_email, 0, SD card remaining memory (Mbytes).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     'UVP ACQ_CONF_09 configuration parameters: Configuration_name, PT_mode, Acquisition_frequency, Frames_per_bloc, Blocs_per_PT, Pressure_for_auto_start, Pressure_difference_for_auto_stop, Result_sending, Save_synthetic_data_for_delayed_request, Limit_lpm_detection_size, Save_images, Vignetting_lower_limit_size, Appendices_ratio, Interval_for_mesuring_background_noise, Image_nb_for_smoothing, Analog_output_activation, Gain_for_analog_out, Minimum_object_number, Maximal_internal_temperature, Operator_email, 0, SD card remaining memory (Mbytes).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     'UVP ACQ_CONF_10 configuration parameters: Configuration_name, PT_mode, Acquisition_frequency, Frames_per_bloc, Blocs_per_PT, Pressure_for_auto_start, Pressure_difference_for_auto_stop, Result_sending, Save_synthetic_data_for_delayed_request, Limit_lpm_detection_size, Save_images, Vignetting_lower_limit_size, Appendices_ratio, Interval_for_mesuring_background_noise, Image_nb_for_smoothing, Analog_output_activation, Gain_for_analog_out, Minimum_object_number, Maximal_internal_temperature, Operator_email, 0, SD card remaining memory (Mbytes).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               '
%     'UVP HW_CONF configuration parameters: Camera_ref, Acquisition_mode, Default_acquisition_configuration, Delay_after_power_up_on_time_mode, Light_ref, Correction_table_activation, Time_between_lighting_power_up_and_trigger, Time_between_lighting_trigger_and_acquisition, Pressure_sensor_ref, Pressure offset, Storage_capacity, Minimum_remaining_memory_for_thumbnail_saving, Baud_Rate, IP_adress, Black_level, Shutter, Gain, Threshold, Aa, Exp, Pixel_Size, Image_volume, Calibration_date, Last_parameters_modification, Operator_email, 18 parameters defining the lower bounds (in �M ESD) of the 18 classes of particles sizes.                                                                                                                                                                                                                                                                                                                                                                                                                   '
%     'WC number of the float.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         '
SENSOR =                                    meta_aux.SENSOR'                     % PARTICLES_PLANKTON_CAMERA
SENSOR_MODEL =                              meta_aux.SENSOR_MODEL'               % UVP6-LP
SENSOR_SERIAL_NO =                          meta_aux.SENSOR_SERIAL_NO'           % 000110LP
PARAMETER =                                 meta_aux.PARAMETER'
%     'NB_SIZE_SPECTRA_PARTICLES                                       '
%     'GREY_SIZE_SPECTRA_PARTICLES                                     '
%     'TEMP_PARTICLES                                                  '
%     'IMAGE_NUMBER_PARTICLES                                          '
%     'BLACK_NB_SIZE_SPECTRA_PARTICLES                                 '
%     'BLACK_TEMP_PARTICLES                                            '
%     'NB_CAT_SPECTRA_PLANKTON                                         '
%     'SIZE_CAT_SPECTRA_PLANKTON                                       '
%     'GREY_LEVEL_CAT_SPECTRA_PLANKTON                                 '
%     'TEMP_PLANKTON                                                   '
%     'IMAGE_NUMBER_PLANKTON                                           '
%     'NB_REL_CAT_SPECTRA_PLANKTON                                     '
%     'SIZE_REL_CAT_SPECTRA_PLANKTON                                   '
%     'GREY_LEVEL_EST_REL_SPECTRA_PLANKTON                             '
PARAMETER_SENSOR =                          meta_aux.PARAMETER_SENSOR'
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
%     'PARTICLES_PLANKTON_CAMERA                                                                                                       '
PARAMETER_UNITS =                           meta_aux.PARAMETER_UNITS'
%     'number of particles per litre   '
%     'bit                             '
%     'degree_Celsius                  '
%     'count                           '
%     'count                           '
%     'degree_Celsius                  '
%     'count                           '
%     'ESD in micrometer               '
%     'bit                             '
%     'degree_Celsius                  '
%     'count                           '
%     'count                           '
%     'count                           '
%     'bit                             '

%% ---------------- Profiles ---------------------------
FILENAME = 'R6903069_006_aux.nc';           % Catalogue des fichiers du répertoire
Profile_aux = ncstruct(['C:\Dvlpt_projet_UVP6\Integration_vecteur\NKE\ARGO\Ressources_pour_ARGO_netcdf_ecotaxa\Tests-netcdf\6903069_aux\profiles\',FILENAME]);
% ---------------- Sample metadata ---------------------
PROFILE_ID =                        FILENAME(1:strfind(FILENAME, 'aux')-2);
INSTRUMENT_SN =                     strip(SENSOR_SERIAL_NO);
LATITUDE =                          Profile_aux.LATITUDE(1,:);
LONGITUDE =                         Profile_aux.LONGITUDE(1,:);
JULD_LOCATION =                     datestr(Profile_aux.JULD_LOCATION(1)+712224,31);
PROFILE_UTC_DATE_TIME =             JULD_LOCATION;

% ---------------- UVP settings ------------------------
HWCONF =                            strsplit(meta_aux.FLOAT_META_DATA_VALUE(:,27,1)',',');
Aa =                                str2num(char(HWCONF(18)));
Exp =                               str2num(char(HWCONF(19)));
IMAGE_VOL =                         str2num(char(HWCONF(21)));
PIXEL_SIZE =                        str2num(char(HWCONF(20)));
DEPTH_OFFSET =                      str2num(char(HWCONF(9)));
ACQ_SHUTTER_SPEED =                 str2num(char(HWCONF(15)));
ACQ_GAIN =                          str2num(char(HWCONF(16)));
ACQ_THRESHOLD =                     str2num(char(HWCONF(17)));

% --------------- Definition des bornes des classes ------
CLASS = [];
for i = 0:17
    CLASS(i+1) = str2num(char(HWCONF(25+i)));
end

% --------------- Sample data ---------------------------
aa =                                isfinite(Profile_aux.PRES(:,1));
PRES =                              Profile_aux.PRES(aa,1);
IMAGE_NUMBER_PARTICLES =            Profile_aux.IMAGE_NUMBER_PARTICLES(aa,1);
TEMP_PARTICLES =                    Profile_aux.TEMP_PARTICLES(aa,1);
NB_SIZE_SPECTRA_PARTICLES =         Profile_aux.NB_SIZE_SPECTRA_PARTICLES(:,aa,1)';
GREY_SIZE_SPECTRA_PARTICLES =       Profile_aux.GREY_SIZE_SPECTRA_PARTICLES(:,aa,1)';
DATA_LPM =      [PRES,TEMP_PARTICLES,IMAGE_NUMBER_PARTICLES,NB_SIZE_SPECTRA_PARTICLES,GREY_SIZE_SPECTRA_PARTICLES];

bb =                                isfinite(Profile_aux.PRES(:,2));
PRES_BLACK =                        Profile_aux.PRES(bb,2);
BLACK_NB_SIZE_SPECTRA_PARTICLES =   Profile_aux.BLACK_NB_SIZE_SPECTRA_PARTICLES(:,bb,2)';
DATA_BLACK =    [PRES_BLACK,BLACK_NB_SIZE_SPECTRA_PARTICLES];

% ---------- S/N ------------------
SN_lim = 5;
NOISE = sortrows(DATA_BLACK);
NOISE_U = NOISE(1,:);
k=2;
for i = 2 : size(NOISE,1)
    if NOISE(i,1) > NOISE(i-1,1)
        NOISE_U(k,:) = NOISE(i,:);
        k=k+1;
    end
end
DEPTH = [0:5:1000];
BLACK = interp1(NOISE_U(:,1),  NOISE_U(:,5)  ,DEPTH,'linear')';

SIGNAL = sortrows(DATA_LPM);
SIGNAL_U = SIGNAL(1,:);
k=2;
for i = 2 : size(SIGNAL,1)
    if SIGNAL(i,1) > SIGNAL(i-1,1)
        SIGNAL_U(k,:) = SIGNAL(i,:);
        k=k+1;
    end
end
LPM = interp1(SIGNAL_U(:,1),  SIGNAL_U(:,7)  ,DEPTH,'linear')';
DATA_SN = [DEPTH',LPM./BLACK];

%% ------------- détection de la couche utile (non impactée par le soleil ---------

% --------- stats sur couche surface -------------------
Zutile = 0;
Zlim = 100;
aa = find( NOISE_U(:,1) <= Zlim);
quantile_noise_surf = quantile(NOISE_U(aa,5),[0.25 .5 .75]);
mean_noise_surf = mean(NOISE_U(aa,5));
std_noise_surf = std(NOISE_U(aa,5));

% --------- Stats sur couche profonde -------------
aa = find( NOISE_U(:,1) > Zlim);
quantile_noise_deep = quantile(NOISE_U(aa,5),[0.25 .5 .75]);
mean_noise_deep = mean(NOISE_U(aa,5));
std_noise_deep = std(NOISE_U(aa,5));

% -------- Profil impacté ou pas  ----------------
if mean_noise_surf > mean_noise_deep + std_noise_deep / 2
    % ------- Recherche de la Zutile ------------
    movmean_noise = movmean(NOISE_U(:,5),10);
    diff_noise = diff(movmean_noise);
    aa = find(diff_noise == min(diff_noise));
    if NOISE_U(aa(1),1) < Zlim && min(diff_noise) < -3
        Zutile = NOISE_U(aa(1),1);
    end
end

aa= DATA_SN(:,1) > Zutile;
DATA_SN_utile = DATA_SN(aa,:);
aa= DATA_LPM(:,1) > Zutile;
DATA_LPM_utile = DATA_LPM(aa,:);

%% ------------- Graphs ---------------------------------
texte = [char(PROFILE_ID),'  ',char(INSTRUMENT_SN),'  ',char(PROFILE_UTC_DATE_TIME),'  ',num2str(LATITUDE),'°/',num2str(LONGITUDE),'°'];
texte = regexprep(texte, '_', '-');
% ---------- QC --------------------
figure1 = figure('name','Plot_CTRL','Position',[10 200 800 800]);
sgtitle(texte);

subplot(2,2,1)
plot(NOISE_U(:,5),-NOISE_U(:,1),'.')
hold on
plot(movmean_noise,-NOISE_U(:,1))
ylabel('Pressure [becibars]');
xlabel(['BLACK : ',num2str(CLASS(4)),'-',num2str(CLASS(5)),'µm'])
legend('Raw','Movmean,10','Location','southeast');

subplot(2,2,2)
plot(diff_noise,-NOISE_U(1:numel(diff_noise),1),'+')
hold on
if Zutilie > 0
    plot(min(diff_noise),-Zutile,'ro');
end
xlabel(['Zutile detection : ',num2str(Zutile),' [decibars]'])

subplot(2,2,3)
semilogx(DATA_SN(:,2),-DATA_SN(:,1),'r.')
hold on
aa = find(DATA_SN(:,2) < SN_lim);
semilogx(DATA_SN(aa,2),-DATA_SN(aa,1),'g.')
semilogx([SN_lim ,SN_lim],[-1000 0],'k--')
xlim([0.1 1000]);
ylabel('Pressure [becibars]');
xlabel(['S/N for ',num2str(CLASS(4)),'-',num2str(CLASS(5)),'µm'])

subplot(2,2,4)
plot (DATA_LPM(:,2),-DATA_LPM(:,1),'k.')
ylabel('Pressure [becibars]');
xlabel(['UVP6 T [°C]'])


% -------------- DATA -----------------------------------
figure2 = figure('name','Plot_DATA','Position',[10 200 1700 1000]);
% ----------- LPM AB ------------
for i = 1:14
    subplot(2,14,i)    
    semilogx (DATA_LPM(:,i+6),-DATA_LPM(:,1),'r.')
    hold on
    semilogx (DATA_LPM_utile(:,i+6),-DATA_LPM_utile(:,1),'g.')    
    xlabel([num2str(CLASS(i+3)),'-',num2str(CLASS(i+4)),'µm'])    
    title('LPM [#/L]');
end

% ----------- LPM GREY ------------
for i = 1:14
    subplot(2,14,i+14)
    semilogx(DATA_LPM(:,i+24),-DATA_LPM(:,1),'r.')
    hold on
    semilogx(DATA_LPM_utile(:,i+24),-DATA_LPM_utile(:,1),'g.')    
    title('LPM GREY');
    xlabel([num2str(CLASS(i+3)),'-',num2str(CLASS(i+4)),'µm'])
    xlim([10,200])
end
sgtitle(texte);

