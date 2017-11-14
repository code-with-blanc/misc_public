% ActiveFEMM (C)2006 David Meeker, dmeeker@ieee.org

function openfemm(fn)
    global ifile ofile HandleToFEMM

    rootdir='/home/blanc/.wine/drive_c/femm42/bin/';

	try
		pkg load windows
	catch
	end
	
    if (exist('actxserver'))
        HandleToFEMM=actxserver('femm.ActiveFEMM');
		callfemm([ 'setcurrentdirectory(' , quote(pwd) , ')' ]);
    else
		disp(sprintf('Octave-Forge Windows package is not installed.'));
		disp(sprintf('Installing this package will speed up the interface to FEMM.'));
        % define temporary file locations
        ifile=[rootdir,'ifile.txt'];
        ofile=[rootdir,'ofile.txt'];

        % test to see if there is already a femm process open
		try
	        [fid,msg]=fopen(ifile,'wt');
		catch
			[fid,msg]=fopen(ifile,'w');
		end
        fprintf(fid,'flput(0)');
        fclose(fid);
        pause(0.5);
		try
	        [fid,msg]=fopen(ofile,'rt');
		catch
			[fid,msg]=fopen(ofile,'r');
		end
        if (fid==-1)
            delete(ifile);
            system(['wine "',rootdir,'femm.exe" -filelink&']);
        else
            fclose(fid);
            delete(ofile);
            disp('FEMM is already open');
        end
    end

   % make sure that FEMM isn't in FEMM 4.0 compatibility mode,
   % otherwise some commands won't work right
   callfemm('setcompatibilitymode(0)');

