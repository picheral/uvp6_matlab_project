function Somme_images_results(drive_root,uvp5sn,date_vue,verrine01,verrine02,large,longmm,b,max_int,vol,vol_100,cor_int,level,img_cor,base1,base2,seuil_vol_fixe)

fid_uvp = fopen([drive_root,'\',date_vue,'_uvp5',num2str(uvp5sn),'_data_',num2str(longmm),'mm.txt'],'w');
fprintf(fid_uvp,'%s\r',['UVP : UVP',num2str(uvp5sn)]);
fprintf(fid_uvp,'%s\r',['Date_img= ',char(date_vue)]);
fprintf(fid_uvp,'%s\r',['light_1= ',char(verrine01)]);
fprintf(fid_uvp,'%s\r',['light_1 (I_mean) =  ',num2str(mean([base1(:).intensity]))]);
fprintf(fid_uvp,'%s\r',['light_1 (I_min) =  ',num2str(min([base1(:).intensity]))]);
fprintf(fid_uvp,'%s\r',['light_1 (I_max) =  ',num2str(max([base1(:).intensity]))]);
fprintf(fid_uvp,'%s\r',['light_2= ',char(verrine02)]);
fprintf(fid_uvp,'%s\r',['light_2 (I_mean) =  ',num2str(mean([base2(:).intensity]))]);
fprintf(fid_uvp,'%s\r',['light_2 (I_min) =  ',num2str(min([base2(:).intensity]))]);
fprintf(fid_uvp,'%s\r',['light_2 (I_max) =  ',num2str(max([base2(:).intensity]))]);

fprintf(fid_uvp,'%s\r',['Mean Intensity (light1 + Light2) =  ',num2str(mean(cor_int))]);

fprintf(fid_uvp,'%s\r',['X= ',num2str(large)]);
fprintf(fid_uvp,'%s\r',['Y= ',num2str(longmm)]);
% fprintf(fid_uvp,'%s\r',['Volume=  ',num2str(vol(b))]);
fprintf(fid_uvp,'%s\r',['Volume_s200=  ',num2str(vol_100)]);
fprintf(fid_uvp,'%s\r',['Z=  ',num2str(1000000*vol_100/(large*longmm))]);
fprintf(fid_uvp,'%s\r',['I_mean (mean int of all img) =  ',num2str(mean(max_int))]);
fprintf(fid_uvp,'%s\r',['I_min (min int of all img) =  ',num2str(min(max_int))]);
fprintf(fid_uvp,'%s\r',['I_max (max int of all img) =  ',num2str(max(max_int))]);
fprintf(fid_uvp,'%s\r',['I_cor=  ',num2str(img_cor)]);
range = level(end)-level(1);
step = level(end)-level(end-1);
fprintf(fid_uvp,'%s\r',['Img_range=  ',num2str(range)]);
fprintf(fid_uvp,'%s\r',['Img_step=  ',num2str(step)]);
fclose(fid_uvp);

disp(['UVP=       UVP5',num2str(uvp5sn)]);
disp(['Date_img=           ',char(date_vue)]);
disp(['light_1=            ',char(verrine01)]);
disp(['light_1 (I_mean) =  ',num2str(mean([base1(:).intensity]))]);
disp(['light_1 (I_min) =   ',num2str(min([base1(:).intensity]))]);
disp(['light_1 (I_max) =   ',num2str(max([base1(:).intensity]))]);
disp(['light_2=            ',char(verrine02)]);
disp(['light_2 (I_mean) =  ',num2str(mean([base2(:).intensity]))]);
disp(['light_2 (I_min) =   ',num2str(min([base2(:).intensity]))]);
disp(['light_2 (I_max) =   ',num2str(max([base2(:).intensity]))]);
disp(['Mean uncorrected Intensity (light1 + Light2) =  ',num2str(round(mean(cor_int)))]);
disp(['X=                  ',num2str(large)]);
disp(['Y=                  ',num2str(longmm)]);
% disp(['Volume_auto=        ',num2str(vol(b))]);
disp(['Volume_s',num2str(seuil_vol_fixe),'=        ',num2str(vol_100)]);
disp(['Z=                  ',num2str(1000000*vol_100/(large*longmm))]);
disp(['I_mean (mean int of all img) =            ',num2str(round(mean(max_int)))]);
disp(['I_min (min int of all img) =              ',num2str(min(max_int))]);
disp(['I_max (max int of all img) =              ',num2str(max(max_int))]);
disp(['I_cor=              ',num2str(img_cor)]);
disp(['Img_range=          ',num2str(range)]);
disp(['Img_step=           ',num2str(step)]);