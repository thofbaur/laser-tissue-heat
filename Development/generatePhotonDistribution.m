function generatePhotonDistribution(Setting)
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

fileID = fopen([Setting.pFilePath,filemci],'w');
fprintf(fileID,'%s\n','##########################################');
fprintf(fileID,'%s\n','# Sample.mci');
fprintf(fileID,'%s\n','# 	A template for input files for MCML.');
fprintf(fileID,'%s\n','#	Any characters following a # are ignored as comments');
fprintf(fileID,'%s\n','#	Space lines are also ignored.');
fprintf(fileID,'%s\n','#	Lengths are in cm, mua and mus are in 1/cm.');
fprintf(fileID,'%s\n','#');
fprintf(fileID,'%s\n','#	Multiple runs may be stipulated.');
fprintf(fileID,'%s\n','##########################################');
fprintf(fileID,'%s\n','');
fprintf(fileID,'%s\n','1.0                      	# file version');
fprintf(fileID,'%s\n','1	                      	# number of runs');
fprintf(fileID,'%s\n','');
fprintf(fileID,'%s\n','#### SPECIFY DATA FOR RUN');
fprintf(fileID,'%s\n','#InParm                    	# Input parameters. cm is used.');
fprintf(fileID,'%s  # Input parameters. cm is used.\n',filemco);
fprintf(fileID,'%u             		 	# No. of photons\n',temp.pNoPhotons);
fprintf(fileID,'%s %f   					# beamtype, beamradius [cm]\n',beamtype,temp.pBeamradius);
fprintf(fileID,'%f %f                	# dz, dr [cm]\n',temp.pdz,temp.pdr);
fprintf(fileID,'%u %u %u	           	# No. of dz, dr, da\n',temp.pnoz,temp.pnor,1);
fprintf(fileID,'%s\n','');
fprintf(fileID,'%u                        	# Number of layers\n',temp.pnolayers);
fprintf(fileID,'%s#n	mua	mus	g	d         	# One line for each layer\n','');
fprintf(fileID,'%f                        	# n for medium above\n',temp.pnlaser);
for ii  = 1:temp.pnolayers
    fprintf(fileID,'%f %f %f %f %f    	# layer %u\n',temp.pn(ii),temp.pmua(ii),temp.pmus(ii),temp.pg(ii),temp.pd(ii),ii);
end
fprintf(fileID,'%f                        	# n for medium below\n',temp.pnbehind);
fclose(fileID);
% oldFolder = cd('Utilities');
command = ['CUDAMCMLflex.exe ', Setting.pFilePath,filemci];
[status,cmdout] = system(command);
movefile(filemco,Setting.pFilePath);
% cd(oldFolder);
end
