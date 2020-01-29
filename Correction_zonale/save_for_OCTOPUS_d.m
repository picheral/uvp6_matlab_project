function save_for_OCTOPUS(M, ID, filename)
% save_for_OCTOPUS - creates a binary file in OCTOPUS format for light correction matrices
%   Usage : save_for_OCTOPUS(M, ID, filename);
%   Input arguments :     
%     M is the floating point coefficients matrix (dimensions must be [129 154])
%     ID is a char array (<= 25 characters), which will identify this coefficient set for traceability purposes
%     filename is a char array for the output generated file (without extension, .bin is added automatically)  
  
    % verify input arguments dimensions, and exit if errors
    narginchk(3, 3);
    assert(isequal(size(M), [129 154]), ['Wrong dimensions for input matrix. Dimensions must be [129 154].']);   
    assert((ischar(ID) && ischar(filename) && (size(ID,1)==1) && (size(filename,1)==1)), ['Wrong type for arguments 2 and/or 3. Must be single row character arrays.']);  
    assert((size(ID, 2) <= 25), ['Too much characters in ''' ID '''. Number of characters must be <= 25.']); 

    % keep only first 65 rows (matrix is symmetric), and add a top row and a right column filled with ones
    A = [ones(1,155) ; M(1:65, :) ones(65,1)];

    % convert data to 8 bits, 2.6 unsigned fixed point format
    B = uint8(64*A);

    % open file to save correction matrix into OCTOPUS format, exit if unable to open file
    fname = [filename '.bin'];
    fileID = fopen(fname, 'w', 'n');
    assert((fileID ~= -1), ['Unable to open file ' fname ' !']); 

    % write transposed matrix to file (convert to row-major order)
    fwrite(fileID, B', 'uint8');

    % write identifier to file, padded with zeroes to 26 bytes
    paddedID = [ID char(zeros(1, (26-size(ID,2))))];
    fwrite(fileID, paddedID, 'char');

    % close file and exit on success
    fclose(fileID);  
    disp(['File ' fname ' successfully created.']);  
end
