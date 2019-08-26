function []= eeg_interp_descriptives(output_file_name)
%% This function is designed to take an EEG data set formated through EEGlab
%and return a text file that displays the a frequency count of all channels
%that have been interpolated in the set.  
%The format is eeg_interp_descriptives(output_file)
%-output_file is the filename and path of the output file.  If you don't specify
%an output filepath, it will write to the current working directory
% **This file analyzes the interpolated channels via analysis of the
% EEG.history structure.  Failure to write the interpolated channels to the
% EEG.history structure will result in null output
%% Default input name
if ~exist('output_file_name');
    output_file_name = [pwd '/interpolated_descriptives.txt'];
end
%% The function
%The basic structure is:
% 1) Load eeg file
% 2) Extract the eeg.history into a variable(what variable type?)
% 3) Use regexp to break the eeg history up into individual lines?
[filename,filepath] = uigetfile('*.set', 'MultiSelect', 'on');
fid = fopen(output_file_name, 'w+t');
if fid < 0 
    fprintf('Error opening file, check your permissions\n');
    return;
end 
for i = 1:length(filename)
EEG = pop_loadset(filename{i},filepath);
interp_chans = extractBetween(EEG.history,'interp', ';');
    fprintf(fid, '\nThe %s : %s', EEG.setname, interp_chans{:} );
end
fclose(fid);
%% Take the text file and read it line by line
%This section will create two arrays, name array and code array.  The
%interpolated channel listings found in the names of the files and in the
%associated code will be put into these two arrays.  It will then be
%counted, organized, and 
name_array = [];
code_array = [];
fid = fopen(output_file_name);
%The way this loop is going to work, grab the first line outside of the
%loop.  Then, extract everything from the line, move to the get the next line, and do
%it all over again.  So long as the get the next line at the end of the
%loop turns up with a line, you can continue.
tline = fgetl(fid);
while ischar(tline);
    %Make sure that if the line is empty, you move to the next one
    if isempty(tline);
        tline = fgetl(fid);
        continue;
    end;
    %Extract the numbers that come after the subject but before the colon
    get_name_line = extractBetween(tline, 9,':');
    %Extract the numbers that were part of the interpolation code
    get_code_line = extractBetween(tline, '[', ']');
    %Turn those extracted numbers into cell arrays
    a=regexp(get_name_line,'\d+(\.)?(\d+)?','match');
    b=regexp(get_code_line,'\d+(\.)?(\d+)?','match');
    %Convert a & b to doubles and add them to the name & code arrays
    %Note: if either A or B turn up empty, skip they entry
    if isempty(a) == 0;
        name_array = [name_array str2double(a{:})];
    end
    if isempty(b) == 0;
        code_array = [code_array str2double(b{:})];
    end
    tline = fgetl(fid);
end
fclose(fid);
%% Take the two arrays (name_array and code_array) and sort them
%Count the unique numbers in each array
x = unique(name_array);
y = unique(code_array);
%Check the size of these unique counts
name_num = numel(x);
code_num = numel(y);
name_count = zeros(name_num,1);
n_count = [];
for k = 1:name_num
  n_count(k) = sum(name_array==x(k));
end
n_count = n_count';
% disp([ x(:) n_count ]);
code_count = zeros(code_num,1);
for l = 1:code_num
  c_count(l) = sum(code_array==y(l));
end
c_count = c_count';
% disp([ y(:) c_count ]);
%% Add these new variables to the interpolation text file
% Create a table that has these frequencies
% Get the length of the longest array
if length(n_count) > length(c_count);
    longest_count = length(n_count);
elseif length(n_count) == length(c_count);
    longest_count = length(n_count);
else
    longest_count = length(c_count);
end
freq_table = nan(longest_count, 4);
freq_table(1:length(x),1) = x;
freq_table(1:length(n_count),2) = n_count;
freq_table(1:length(y),3) = y;
freq_table(1:length(c_count),4) = c_count;
%% Now write the new table of frequencies to the top of the interpolation history
s = fileread(output_file_name);
%
fid = fopen(output_file_name, 'w+t');
if fid < 0 
    fprintf('Error opening file, check your permissions\n');
    return;
end 
fprintf(fid, 'Below are the');
fprintf(fid, '\nfrequencies of');
fprintf(fid, '\ninterpolated channels');
fprintf(fid, '\nextracted from the');
fprintf(fid, '\nfile names');
fprintf(fid, '\n-------------------------------------------------');
fprintf(fid, '\nChannel: \t# of Interpolations:');
for m = 1:length(freq_table);
    fprintf(fid, '\n  %.f\t%.f',freq_table(m,3),freq_table(m,4));
end
fprintf(fid, '\n-------------------------------------------------\n');
fwrite(fid, s, 'char');
fclose(fid);
