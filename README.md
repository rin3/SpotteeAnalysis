# Spottee Analysis for Specific Contest Dates
- for post-contest use
- Analyzing spots and making a list of most spotted stations
  and its band breakdowns
- using DXSpider outputs

A Perl Snippet for command line use.

rin fukuda, jg1vgx@jarl.com, Nov 2004
ver 0.02

REQUIREMENTS
------------
This program works for ONLY DX Spider outputs(logs).

HOW TO USE
----------
1. Use your favorite telnet program, connect your favorite node. Collect logs using commands like:

    show/dx 50000 days 5-4

2. Edit the log obtained in (1) to remove unnecessary lines. Especially keep only spots for specific dates necessary for your analysis. Currently there are no function to specify dates in the perl snippet itself.
 You can leave unrelated command lines safely. You only have to remove spots for unnecessary dates.

3. Launch the perl snippet. It will ask log file name, then contest mode. The program currently only supports HF contests. It will automatically ignore WARC and VHF spots.

4. The outputs are produced as below:
    - "analyzed.txt" --- Spottee top list, in the descending order of total number of spots. Counts for each band are also shown.
    - "unanalyzed.txt" --- Contains lines of input file which was unanalyzed. If you find something which should be analyzed, fix any problem (in the original input file) and try again. Such problems include wrong freq (eg. 142255.0 instead of 14225.5 for 20m SSB spot), busted callsigns etc.

5. Band mode map for selection is defined at the top of perl file. You can edit it if you like, especially for low bands.

VERSION HISTORY
---------------
v0.02 Dec 2004
- Added contest mode for 10m (eg. ARRL) and 160m (eg. ARRL and CQ). In 10m, spots for each mode is separately counted while in 160m is not.
- Added output file of analyzed spots.

v0.01 Nov 2004
- Initial Release
