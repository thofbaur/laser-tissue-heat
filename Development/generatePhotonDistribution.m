%codegen
function generatePhotonDistribution(Setting,path,app)
temp = Setting.sParams;
switch temp.pBeamtype
    case 'Gaussian'
        beamtype = 'g';
    case 'Flat'
        beamtype = 'f';
    case 'Delta'
        beamtype = 'd';
end

fileout = strsplit(Setting.pFileName,'.');
filemci = [fileout{1},'.mci'];
filemco = [fileout{1},'.mco'];

app.DirData.Text = [Setting.pFilePath,filemci];
fileID = fopen([Setting.pFilePath,filemci],'w');
fprintf(fileID,'%s\r\n','##########################################');
fprintf(fileID,'%s\r\n','# Sample.mci');
fprintf(fileID,'%s\r\n','# 	A template for input files for MCML.');
fprintf(fileID,'%s\r\n','#	Any characters following a # are ignored as comments');
fprintf(fileID,'%s\r\n','#	Space lines are also ignored.');
fprintf(fileID,'%s\r\n','#	Lengths are in cm, mua and mus are in 1/cm.');
fprintf(fileID,'%s\r\n','#');
fprintf(fileID,'%s\r\n','#	Multiple runs may be stipulated.');
fprintf(fileID,'%s\r\n','##########################################');
fprintf(fileID,'%s\r\n','');
fprintf(fileID,'%s\r\n','1.0                      	# file version');
fprintf(fileID,'%s\r\n','1	                      	# number of runs');
fprintf(fileID,'%s\r\n','');
fprintf(fileID,'%s\r\n','#### SPECIFY DATA FOR RUN 1');
fprintf(fileID,'%s\r\n','#InParm                    	# Input parameters. cm is used');
fprintf(fileID,'%s  A           # output file name, ASCII.\r\n',[Setting.pFilePath,filemco]);
fprintf(fileID,'%u             		 	# No. of photons\r\n',temp.pNoPhotons);
fprintf(fileID,'%s %f   					# beamtype, beamradius [cm]\r\n',beamtype,temp.pBeamradius);
fprintf(fileID,'%f %f                	# dz, dr [cm]\r\n',temp.pdz,temp.pdr);
fprintf(fileID,'%u %u %u	           	# No. of dz, dr, da\r\n',temp.pnoz,temp.pnor,1);
fprintf(fileID,'%s\r\n','');
fprintf(fileID,'%u                        	# Number of layers\r\n',temp.pnolayers);
fprintf(fileID,'%s#n	mua	mus	g	d         	# One line for each layer\r\n','');
fprintf(fileID,'%f                        	# n for medium above\r\n',temp.pnlaser);
for ii  = 1:temp.pnolayers
    fprintf(fileID,'%f %f %f %f %f    	# layer %u\r\n',temp.pn(ii),temp.pmua(ii),temp.pmus(ii),temp.pg(ii),temp.pd(ii),ii);
end
fprintf(fileID,'%f                        	# n for medium below\r\n',temp.pnbehind);
fclose(fileID);
% oldFolder = cd(path);
command = [path,'\CUDAMCMLflex.exe ', Setting.pFilePath,filemci];
[status,cmdout] = system(command);
% movefile(filemco,Setting.pFilePath);
% cd(oldFolder);
end
