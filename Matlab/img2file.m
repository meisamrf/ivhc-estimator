function img2file(data,id1,id2)
fid = fopen(['imgdata_' id1 num2str(id2) '.bin'], 'w');
fwrite(fid,id1,'int32');
fwrite(fid,id2,'int32');
fwrite(fid,size(data,1),'int32');
fwrite(fid,size(data,2),'int32');
fwrite(fid,data(:),'single');
fclose(fid);