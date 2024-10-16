prompt Creating database report.
prompt This script must be run as a user with SYSDBA privileges.
prompt This process can take several minutes to complete.
prompt 



-- +----------------------------------------------------------------------------+
-- |                           SCRIPT SETTINGS                                  |
-- +----------------------------------------------------------------------------+

set termout       off
set echo          off
set feedback      off
set heading       off
set verify        off
set wrap          on
set trimspool     on
set serveroutput  on
set escape        on

set pagesize 50000
set linesize 175
set long     2000000000

clear buffer computes columns breaks

define fileName=DB-Report
define versionNumber=5.3


-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT INFORMATION                       |
-- +----------------------------------------------------------------------------+

COLUMN tdate NEW_VALUE _date NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY') tdate FROM dual;

COLUMN time NEW_VALUE _time NOPRINT
SELECT TO_CHAR(SYSDATE,'HH24:MI:SS') time FROM dual;

COLUMN date_time NEW_VALUE _date_time NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS') date_time FROM dual;

COLUMN date_time_timezone NEW_VALUE _date_time_timezone NOPRINT
SELECT TO_CHAR(systimestamp, 'Mon DD, YYYY (') || TRIM(TO_CHAR(systimestamp, 'Day')) || TO_CHAR(systimestamp, ') "at" HH:MI:SS AM') || TO_CHAR(systimestamp, ' "in Timezone" TZR') date_time_timezone
FROM dual;

COLUMN spool_time NEW_VALUE _spool_time NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD') spool_time FROM dual;

COLUMN dbname NEW_VALUE _dbname NOPRINT
SELECT name dbname FROM v$database;

COLUMN dbid NEW_VALUE _dbid NOPRINT
SELECT dbid dbid FROM v$database;

COLUMN platform_id NEW_VALUE _platform_id NOPRINT
SELECT platform_id platform_id FROM v$database;

COLUMN platform_name NEW_VALUE _platform_name NOPRINT
SELECT platform_name platform_name FROM v$database;

COLUMN global_name NEW_VALUE _global_name NOPRINT
SELECT global_name global_name FROM global_name;

COLUMN blocksize NEW_VALUE _blocksize NOPRINT
SELECT value blocksize FROM v$parameter WHERE name='db_block_size';

COLUMN startup_time NEW_VALUE _startup_time NOPRINT
SELECT TO_CHAR(startup_time, 'MM/DD/YYYY HH24:MI:SS') startup_time FROM v$instance;

COLUMN host_name NEW_VALUE _host_name NOPRINT
SELECT host_name host_name FROM v$instance;

COLUMN instance_name NEW_VALUE _instance_name NOPRINT
SELECT instance_name instance_name FROM v$instance;

COLUMN instance_number NEW_VALUE _instance_number NOPRINT
SELECT instance_number instance_number FROM v$instance;

COLUMN thread_number NEW_VALUE _thread_number NOPRINT
SELECT thread# thread_number FROM v$instance;

COLUMN cluster_database NEW_VALUE _cluster_database NOPRINT
SELECT value cluster_database FROM v$parameter WHERE name='cluster_database';

COLUMN cluster_database_instances NEW_VALUE _cluster_database_instances NOPRINT
SELECT value cluster_database_instances FROM v$parameter WHERE name='cluster_database_instances';

COLUMN reportRunUser NEW_VALUE _reportRunUser NOPRINT
SELECT user reportRunUser FROM dual;



-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT INFORMATION                       |
-- +----------------------------------------------------------------------------+

set heading on

set markup html on spool on preformat off entmap on -
head ' -
  <title>Database Report</title> -
  <style type="text/css"> -
    body              {font:9pt Tahoma,Arial,Helvetica,sans-serif; color:blue; background:White;} -
    p                 {font:9pt Tahoma,Arial,Helvetica,sans-serif; color:black; background:White;} -
    table,tr,td       {font:bold 9pt Tahoma,Arial,Helvetica,sans-serif; color:Black; background:White; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} -
    th                {font:bold 9pt Tahoma,Arial,Helvetica,sans-serif; color:#114C1C; background:#cccc99; padding:0px 0px 0px 0px;} -
    h1                {font:bold 12pt Tahoma,Arial,Helvetica,Geneva,sans-serif; color:#114C1C; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} -
    h2                {font:bold 9pt Tahoma,Arial,Helvetica,Geneva,sans-serif; color:#114C1C; background-color:White; margin-top:4pt; margin-bottom:0pt;} -
    a                 {font:9pt Tahoma,Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:bottom;} -
    a.link            {font:9pt Tahoma,Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLink          {font:9pt Tahoma,Arial,Helvetica,sans-serif; color:#663300; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkBlue      {font:9pt Tahoma,Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkBlue  {font:9pt Tahoma,Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkRed       {font:9pt Tahoma,Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkRed   {font:9pt Tahoma,Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkGreen     {font:9pt Tahoma,Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkGreen {font:9pt Tahoma,Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
  </style>' -
body   'BGCOLOR="#C0C0C0"' -
table  'WIDTH="90%" BORDER="1"' 

spool &FileName._&_dbname._&_spool_time..html

set markup html on entmap off


-- +----------------------------------------------------------------------------+
-- |                             - REPORT HEADER -                              |
-- +----------------------------------------------------------------------------+

prompt <a name=top></a>


-- +----------------------------------------------------------------------------+
-- |                             - REPORT INDEX -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="HTI Database Statistics"></a>


prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>HTI Database/s Statistics</b></font><hr align="center" width="250"></center> -
<table width="90%" border="1"> -
<tr><th colspan="4">Database and Instance Information</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#report_header">Report Header</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#version">Version</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#database_overview">Database Overview</a></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#control_files">Control Files</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#online_redo_logs">Online Redo Logs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#redo_log_switches">Redo Log Switches</a></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr> -

prompt -
<tr><th colspan="4">Scheduler / Jobs</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#jobs">Jobs</a></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr> -
<tr><th colspan="4">Storage</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#tablespaces">Tablespaces</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#database_growth">Database Growth</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#Total_Used_size_of_the_DB">Database Size Used</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#Total_Free_size_of_the_DB">Database Size Free</a></td> -
</tr> -

prompt -
<tr><th colspan="4">Backups</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_jobs">RMAN Backup Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_configuration">RMAN Configuration</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_sets">RMAN Backup Sets</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_pieces">RMAN Backup Pieces</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_control_files">RMAN Backup Control Files</a></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr> -

prompt -
<tr><th colspan="4">Objects</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_lob_segments">LOB Segments</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#segment_summary">Segment Summary</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#top_10_segments_by_size">Top Segments (by size)</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#Last_Analysis_Date">Table Analysis</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_directories">Directories</a></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr> -

prompt -
</table>

prompt <p>

prompt <p>






-- +============================================================================+
-- |                                                                            |
-- |        <<<<<     Database and Instance Information    >>>>>                |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Database and Instance Information</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                            - REPORT HEADER -                               |
-- +----------------------------------------------------------------------------+

prompt 
prompt <a name="report_header"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Report Header</b></font><hr align="left" width="460">

prompt <table width="90%" border="1"> -
<tr><th align="left" width="20%">Report Name</th><td width="80%"><tt>&FileName._&_dbname._&_spool_time..html</tt></td></tr> -
<tr><th align="left" width="20%">Snapshot Database Version</th><td width="80%"><tt>&versionNumber</tt></td></tr> -
<tr><th align="left" width="20%">Run Date / Time / Timezone</th><td width="80%"><tt>&_date_time_timezone</tt></td></tr> -
<tr><th align="left" width="20%">Host Name</th><td width="80%"><tt>&_host_name</tt></td></tr> -
<tr><th align="left" width="20%">Database Name</th><td width="80%"><tt>&_dbname</tt></td></tr> -
<tr><th align="left" width="20%">Database ID</th><td width="80%"><tt>&_dbid</tt></td></tr> -
<tr><th align="left" width="20%">Global Database Name</th><td width="80%"><tt>&_global_name</tt></td></tr> -
<tr><th align="left" width="20%">Platform Name / ID</th><td width="80%"><tt>&_platform_name / &_platform_id</tt></td></tr> -
<tr><th align="left" width="20%">Clustered Database?</th><td width="80%"><tt>&_cluster_database</tt></td></tr> -
<tr><th align="left" width="20%">Clustered Database Instances</th><td width="80%"><tt>&_cluster_database_instances</tt></td></tr> -
<tr><th align="left" width="20%">Instance Name</th><td width="80%"><tt>&_instance_name</tt></td></tr> -
<tr><th align="left" width="20%">Instance Number</th><td width="80%"><tt>&_instance_number</tt></td></tr> -
<tr><th align="left" width="20%">Thread Number</th><td width="80%"><tt>&_thread_number</tt></td></tr> -
<tr><th align="left" width="20%">Database Startup Time</th><td width="80%"><tt>&_startup_time</tt></td></tr> -
<tr><th align="left" width="20%">Database Block Size</th><td width="80%"><tt>&_blocksize</tt></td></tr> -
<tr><th align="left" width="20%">Report Run User</th><td width="80%"><tt>&_reportRunUser</tt></td></tr> -
</table>

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- SET TIMING ON




-- +----------------------------------------------------------------------------+
-- |                                 - VERSION -                                |
-- +----------------------------------------------------------------------------+

prompt <a name="version"></a>
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Versions</u></b></font></center>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN banner   FORMAT a120   HEADING 'Banner'
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Version of PaP</b></font><hr align="left" width="460">
SELECT banner as "version of PaP" FROM v$version ; 
prompt
prompt 
COLUMN banner   FORMAT a120   HEADING 'Banner'
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Version of WSH</b></font><hr align="left" width="460">
select banner as "version of WSH" from v$version@pps02;
prompt
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                           - DATABASE OVERVIEW -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="database_overview"></a>
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Database Overview</u></b></font></center>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Overview of PaP</b></font><hr align="left" width="460">
CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                            FORMAT a75     HEADING 'Database|Name'              ENTMAP off
COLUMN dbid                                           HEADING 'Database|ID'                ENTMAP off
COLUMN db_unique_name                                 HEADING 'Database|Unique Name'       ENTMAP off
COLUMN creation_date                                  HEADING 'Creation|Date'              ENTMAP off
COLUMN platform_name_print                            HEADING 'Platform|Name'              ENTMAP off
COLUMN current_scn                                    HEADING 'Current|SCN'                ENTMAP off
COLUMN log_mode                                       HEADING 'Log|Mode'                   ENTMAP off
COLUMN open_mode                                      HEADING 'Open|Mode'                  ENTMAP off
COLUMN force_logging                                  HEADING 'Force|Logging'              ENTMAP off
COLUMN flashback_on                                   HEADING 'Flashback|On?'              ENTMAP off
COLUMN controlfile_type                               HEADING 'Controlfile|Type'           ENTMAP off
COLUMN last_open_incarnation_number                   HEADING 'Last Open|Incarnation Num'  ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>'  || name  || '</b></font></div>'          name
  , '<div align="center">' || dbid                   || '</div>'                              dbid
  , '<div align="center">' || db_unique_name         || '</div>'                              db_unique_name
  , '<div align="center">' || TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') || '</div>'           creation_date
  , '<div align="center">' || platform_name          || '</div>'                              platform_name_print
  , '<div align="center">' || current_scn            || '</div>'                              current_scn
  , '<div align="center">' || log_mode               || '</div>'                              log_mode
  , '<div align="center">' || open_mode              || '</div>'                              open_mode
  , '<div align="center">' || force_logging          || '</div>'                              force_logging
  , '<div align="center">' || flashback_on           || '</div>'                              flashback_on
  , '<div align="center">' || controlfile_type       || '</div>'                              controlfile_type
  , '<div align="center">' || last_open_incarnation# || '</div>'                              last_open_incarnation_number
FROM v$database;

prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Overview of WSH</b></font><hr align="left" width="460">
CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                            FORMAT a75     HEADING 'Database|Name'              ENTMAP off
COLUMN dbid                                           HEADING 'Database|ID'                ENTMAP off
COLUMN db_unique_name                                 HEADING 'Database|Unique Name'       ENTMAP off
COLUMN creation_date                                  HEADING 'Creation|Date'              ENTMAP off
COLUMN platform_name_print                            HEADING 'Platform|Name'              ENTMAP off
COLUMN current_scn                                    HEADING 'Current|SCN'                ENTMAP off
COLUMN log_mode                                       HEADING 'Log|Mode'                   ENTMAP off
COLUMN open_mode                                      HEADING 'Open|Mode'                  ENTMAP off
COLUMN force_logging                                  HEADING 'Force|Logging'              ENTMAP off
COLUMN flashback_on                                   HEADING 'Flashback|On?'              ENTMAP off
COLUMN controlfile_type                               HEADING 'Controlfile|Type'           ENTMAP off
COLUMN last_open_incarnation_number                   HEADING 'Last Open|Incarnation Num'  ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>'  || name  || '</b></font></div>'          name
  , '<div align="center">' || dbid                   || '</div>'                              dbid
  , '<div align="center">' || db_unique_name         || '</div>'                              db_unique_name
  , '<div align="center">' || TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') || '</div>'           creation_date
  , '<div align="center">' || platform_name          || '</div>'                              platform_name_print
  , '<div align="center">' || current_scn            || '</div>'                              current_scn
  , '<div align="center">' || log_mode               || '</div>'                              log_mode
  , '<div align="center">' || open_mode              || '</div>'                              open_mode
  , '<div align="center">' || force_logging          || '</div>'                              force_logging
  , '<div align="center">' || flashback_on           || '</div>'                              flashback_on
  , '<div align="center">' || controlfile_type       || '</div>'                              controlfile_type
  , '<div align="center">' || last_open_incarnation# || '</div>'                              last_open_incarnation_number
FROM v$database@pps02;



-- +----------------------------------------------------------------------------+
-- |                            - CONTROL FILES -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="control_files"></a>
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Control Files</u></b></font></center>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Control Files in Pap</b></font><hr align="left" width="460">
CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                           HEADING 'Controlfile Name'  ENTMAP off
COLUMN status           FORMAT a75    HEADING 'Status'            ENTMAP off
COLUMN file_size        FORMAT a75    HEADING 'File Size'         ENTMAP off

SELECT
    '<tt>' || c.name || '</tt>'                                                                      name
  , DECODE(   c.status
            , NULL
            ,  '<div align="center"><b><font color="darkgreen">VALID</font></b></div>'
            ,  '<div align="center"><b><font color="#663300">'   || c.status || '</font></b></div>') status
  , '<div align="right">' || TO_CHAR(block_size *  file_size_blks, '999,999,999,999') || '</div>'    file_size
FROM 
    v$controlfile c
ORDER BY
    c.name;

prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Control Files in WSH</b></font><hr align="left" width="460">
CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                           HEADING 'Controlfile Name'  ENTMAP off
COLUMN status           FORMAT a75    HEADING 'Status'            ENTMAP off
COLUMN file_size        FORMAT a75    HEADING 'File Size'         ENTMAP off

SELECT
    '<tt>' || c.name || '</tt>'                                                                      name
  , DECODE(   c.status
            , NULL
            ,  '<div align="center"><b><font color="darkgreen">VALID</font></b></div>'
            ,  '<div align="center"><b><font color="#663300">'   || c.status || '</font></b></div>') status
  , '<div align="right">' || TO_CHAR(block_size *  file_size_blks, '999,999,999,999') || '</div>'    file_size
FROM 
    v$controlfile@pps02 c
ORDER BY
    c.name;



-- +----------------------------------------------------------------------------+
-- |                          - ONLINE REDO LOGS -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="online_redo_logs"></a>
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Online Redo Logs</u></b></font></center>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Online Redo Logs PaP</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a95                HEADING 'Instance Name'    ENTMAP off
COLUMN thread_number_print  FORMAT a95                HEADING 'Thread Number'    ENTMAP off
COLUMN groupno                                        HEADING 'Group Number'     ENTMAP off
COLUMN member                                         HEADING 'Member'           ENTMAP off
COLUMN redo_file_type       FORMAT a75                HEADING 'Redo Type'        ENTMAP off
COLUMN log_status           FORMAT a75                HEADING 'Log Status'       ENTMAP off
COLUMN bytes                FORMAT 999,999,999,999    HEADING 'Bytes'            ENTMAP off
COLUMN archived             FORMAT a75                HEADING 'Archived?'        ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'        instance_name_print
  , '<div align="center">' || i.thread# || '</div>'                                                  thread_number_print
  , f.group#                                                                                         groupno
  , '<tt>' || f.member || '</tt>'                                                                    member
  , f.type                                                                                           redo_file_type
  , DECODE(   l.status
            , 'CURRENT'
            , '<div align="center"><b><font color="darkgreen">' || l.status || '</font></b></div>'
            , '<div align="center"><b><font color="#990000">'   || l.status || '</font></b></div>')  log_status
  , l.bytes                                                                                          bytes
  , '<div align="center">'  || l.archived || '</div>'                                                archived
FROM
    gv$logfile  f
  , gv$log      l
  , gv$instance i
WHERE
      f.group#  = l.group#
  AND l.thread# = i.thread#
  AND i.inst_id = f.inst_id
  AND f.inst_id = l.inst_id
ORDER BY
    i.instance_name
  , f.group#
  , f.member;

prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Online Redo Logs WSH</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a95                HEADING 'Instance Name'    ENTMAP off
COLUMN thread_number_print  FORMAT a95                HEADING 'Thread Number'    ENTMAP off
COLUMN groupno                                        HEADING 'Group Number'     ENTMAP off
COLUMN member                                         HEADING 'Member'           ENTMAP off
COLUMN redo_file_type       FORMAT a75                HEADING 'Redo Type'        ENTMAP off
COLUMN log_status           FORMAT a75                HEADING 'Log Status'       ENTMAP off
COLUMN bytes                FORMAT 999,999,999,999    HEADING 'Bytes'            ENTMAP off
COLUMN archived             FORMAT a75                HEADING 'Archived?'        ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'        instance_name_print
  , '<div align="center">' || i.thread# || '</div>'                                                  thread_number_print
  , f.group#                                                                                         groupno
  , '<tt>' || f.member || '</tt>'                                                                    member
  , f.type                                                                                           redo_file_type
  , DECODE(   l.status
            , 'CURRENT'
            , '<div align="center"><b><font color="darkgreen">' || l.status || '</font></b></div>'
            , '<div align="center"><b><font color="#990000">'   || l.status || '</font></b></div>')  log_status
  , l.bytes                                                                                          bytes
  , '<div align="center">'  || l.archived || '</div>'                                                archived
FROM
    gv$logfile@pps02  f
  , gv$log@pps02      l
  , gv$instance@pps02 i
WHERE
      f.group#  = l.group#
  AND l.thread# = i.thread#
  AND i.inst_id = f.inst_id
  AND f.inst_id = l.inst_id
ORDER BY
    i.instance_name
  , f.group#
  , f.member;



-- +----------------------------------------------------------------------------+
-- |                         - REDO LOG SWITCHES -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="online_redo_logs"></a>
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Redo Log Switch</u></b></font></center>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Redo Log Switch PaP</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN DAY   FORMAT a75              HEADING 'Day / Time'  ENTMAP off
COLUMN H00   FORMAT 999,999B         HEADING '00'          ENTMAP off
COLUMN H01   FORMAT 999,999B         HEADING '01'          ENTMAP off
COLUMN H02   FORMAT 999,999B         HEADING '02'          ENTMAP off
COLUMN H03   FORMAT 999,999B         HEADING '03'          ENTMAP off
COLUMN H04   FORMAT 999,999B         HEADING '04'          ENTMAP off
COLUMN H05   FORMAT 999,999B         HEADING '05'          ENTMAP off
COLUMN H06   FORMAT 999,999B         HEADING '06'          ENTMAP off
COLUMN H07   FORMAT 999,999B         HEADING '07'          ENTMAP off
COLUMN H08   FORMAT 999,999B         HEADING '08'          ENTMAP off
COLUMN H09   FORMAT 999,999B         HEADING '09'          ENTMAP off
COLUMN H10   FORMAT 999,999B         HEADING '10'          ENTMAP off
COLUMN H11   FORMAT 999,999B         HEADING '11'          ENTMAP off
COLUMN H12   FORMAT 999,999B         HEADING '12'          ENTMAP off
COLUMN H13   FORMAT 999,999B         HEADING '13'          ENTMAP off
COLUMN H14   FORMAT 999,999B         HEADING '14'          ENTMAP off
COLUMN H15   FORMAT 999,999B         HEADING '15'          ENTMAP off
COLUMN H16   FORMAT 999,999B         HEADING '16'          ENTMAP off
COLUMN H17   FORMAT 999,999B         HEADING '17'          ENTMAP off
COLUMN H18   FORMAT 999,999B         HEADING '18'          ENTMAP off
COLUMN H19   FORMAT 999,999B         HEADING '19'          ENTMAP off
COLUMN H20   FORMAT 999,999B         HEADING '20'          ENTMAP off
COLUMN H21   FORMAT 999,999B         HEADING '21'          ENTMAP off
COLUMN H22   FORMAT 999,999B         HEADING '22'          ENTMAP off
COLUMN H23   FORMAT 999,999B         HEADING '23'          ENTMAP off
COLUMN TOTAL FORMAT 999,999,999      HEADING 'Total'       ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' avg label '<font color="#990000"><b>Average:</b></font>' OF total ON report

SELECT
    '<div align="center"><font color="#336699"><b>' || SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)  || '</b></font></div>'  DAY
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'00',1,0)) H00
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'01',1,0)) H01
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'02',1,0)) H02
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'03',1,0)) H03
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'04',1,0)) H04
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'05',1,0)) H05
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'06',1,0)) H06
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'07',1,0)) H07
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'08',1,0)) H08
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'09',1,0)) H09
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'10',1,0)) H10
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'11',1,0)) H11
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'12',1,0)) H12
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'13',1,0)) H13
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'14',1,0)) H14
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'15',1,0)) H15
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'16',1,0)) H16
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'17',1,0)) H17
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'18',1,0)) H18
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'19',1,0)) H19
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'20',1,0)) H20
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'21',1,0)) H21
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'22',1,0)) H22
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'23',1,0)) H23
  , COUNT(*)                                                                      TOTAL
FROM
  v$log_history  a
GROUP BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)
ORDER BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5);

prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Redo Log Switch WSH</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN DAY   FORMAT a75              HEADING 'Day / Time'  ENTMAP off
COLUMN H00   FORMAT 999,999B         HEADING '00'          ENTMAP off
COLUMN H01   FORMAT 999,999B         HEADING '01'          ENTMAP off
COLUMN H02   FORMAT 999,999B         HEADING '02'          ENTMAP off
COLUMN H03   FORMAT 999,999B         HEADING '03'          ENTMAP off
COLUMN H04   FORMAT 999,999B         HEADING '04'          ENTMAP off
COLUMN H05   FORMAT 999,999B         HEADING '05'          ENTMAP off
COLUMN H06   FORMAT 999,999B         HEADING '06'          ENTMAP off
COLUMN H07   FORMAT 999,999B         HEADING '07'          ENTMAP off
COLUMN H08   FORMAT 999,999B         HEADING '08'          ENTMAP off
COLUMN H09   FORMAT 999,999B         HEADING '09'          ENTMAP off
COLUMN H10   FORMAT 999,999B         HEADING '10'          ENTMAP off
COLUMN H11   FORMAT 999,999B         HEADING '11'          ENTMAP off
COLUMN H12   FORMAT 999,999B         HEADING '12'          ENTMAP off
COLUMN H13   FORMAT 999,999B         HEADING '13'          ENTMAP off
COLUMN H14   FORMAT 999,999B         HEADING '14'          ENTMAP off
COLUMN H15   FORMAT 999,999B         HEADING '15'          ENTMAP off
COLUMN H16   FORMAT 999,999B         HEADING '16'          ENTMAP off
COLUMN H17   FORMAT 999,999B         HEADING '17'          ENTMAP off
COLUMN H18   FORMAT 999,999B         HEADING '18'          ENTMAP off
COLUMN H19   FORMAT 999,999B         HEADING '19'          ENTMAP off
COLUMN H20   FORMAT 999,999B         HEADING '20'          ENTMAP off
COLUMN H21   FORMAT 999,999B         HEADING '21'          ENTMAP off
COLUMN H22   FORMAT 999,999B         HEADING '22'          ENTMAP off
COLUMN H23   FORMAT 999,999B         HEADING '23'          ENTMAP off
COLUMN TOTAL FORMAT 999,999,999      HEADING 'Total'       ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' avg label '<font color="#990000"><b>Average:</b></font>' OF total ON report

SELECT
    '<div align="center"><font color="#336699"><b>' || SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)  || '</b></font></div>'  DAY
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'00',1,0)) H00
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'01',1,0)) H01
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'02',1,0)) H02
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'03',1,0)) H03
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'04',1,0)) H04
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'05',1,0)) H05
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'06',1,0)) H06
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'07',1,0)) H07
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'08',1,0)) H08
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'09',1,0)) H09
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'10',1,0)) H10
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'11',1,0)) H11
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'12',1,0)) H12
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'13',1,0)) H13
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'14',1,0)) H14
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'15',1,0)) H15
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'16',1,0)) H16
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'17',1,0)) H17
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'18',1,0)) H18
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'19',1,0)) H19
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'20',1,0)) H20
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'21',1,0)) H21
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'22',1,0)) H22
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'23',1,0)) H23
  , COUNT(*)                                                                      TOTAL
FROM
  v$log_history@pps02  a
GROUP BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)
ORDER BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5);



-- +----------------------------------------------------------------------------+
-- |                            - TABLESPACES -                                 |
-- +----------------------------------------------------------------------------+
prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Tablespaces</u></b></font></center>
prompt <a name="tablespaces"></a>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tablespaces in Pap</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

-- Formatting settings
COLUMN status                                  HEADING 'Status'            ENTMAP off
COLUMN name                                    HEADING 'Tablespace Name'   ENTMAP off
COLUMN type        FORMAT a12                  HEADING 'TS Type'           ENTMAP off
COLUMN extent_mgt  FORMAT a10                  HEADING 'Ext. Mgt.'         ENTMAP off
COLUMN segment_mgt FORMAT a9                   HEADING 'Seg. Mgt.'         ENTMAP off
COLUMN ts_size     FORMAT 999,999,999,999,999  HEADING 'Tablespace Size (GB)'   ENTMAP off
COLUMN free        FORMAT 999,999,999,999,999  HEADING 'Free (in GB)'      ENTMAP off
COLUMN used        FORMAT 999,999,999,999,999  HEADING 'Used (in GB)'      ENTMAP off
COLUMN pct_used                                HEADING 'Pct. Used'         ENTMAP off

-- Set up the break and compute for totals
BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>' OF ts_size used free ON report

-- Query for non-temporary tablespaces
SELECT
    DECODE(   
        d.status, 
        'OFFLINE', '<div align="center"><b><font color="#990000">' || d.status || '</font></b></div>',
        '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>'
    ) AS status,
    '<b><font color="#336699">' || d.tablespace_name || '</font></b>' AS name,
    d.contents AS type,
    d.extent_management AS extent_mgt,
    d.segment_space_management AS segment_mgt,
    ROUND(NVL(a.bytes, 0) / (1024 * 1024 ), 2) AS ts_size,   -- Tablespace size in GB
    ROUND(NVL(f.bytes, 0) / (1024 * 1024 ), 2) AS free,      -- Free space in GB
    ROUND(NVL(a.bytes - NVL(f.bytes, 0), 0) / (1024 * 1024 ), 2) AS used, -- Used space in GB
    '<div align="right"><b>' || 
        DECODE(
            (1-SIGN(1-SIGN(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0)) - 90))),
            1, '<font color="#990000">' || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>',
            '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>'
        ) || '</b> %</div>' AS pct_used
FROM 
    sys.dba_tablespaces d
    LEFT JOIN (SELECT tablespace_name, SUM(bytes) AS bytes FROM dba_data_files GROUP BY tablespace_name) a
        ON d.tablespace_name = a.tablespace_name
    LEFT JOIN (SELECT tablespace_name, SUM(bytes) AS bytes FROM dba_free_space GROUP BY tablespace_name) f
        ON d.tablespace_name = f.tablespace_name
WHERE
    NOT (d.extent_management LIKE 'LOCAL' AND d.contents LIKE 'TEMPORARY')
ORDER BY 2;

-- Query for temporary tablespaces
SELECT
    DECODE(   
        d.status, 
        'OFFLINE', '<div align="center"><b><font color="#990000">' || d.status || '</font></b></div>',
        '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>'
    ) AS status,
    '<b><font color="#336699">' || d.tablespace_name || '</font></b>' AS name,
    d.contents AS type,
    d.extent_management AS extent_mgt,
    d.segment_space_management AS segment_mgt,
    ROUND(NVL(a.bytes, 0) / (1024 * 1024 ), 2) AS ts_size,   -- Tablespace size in GB
    ROUND(NVL(t.bytes, 0) / (1024 * 1024 ), 2) AS free,      -- Free space in GB
    ROUND(NVL(a.bytes - NVL(t.bytes, 0), 0) / (1024 * 1024 ), 2) AS used, -- Used space in GB
    '<div align="right"><b>' || 
        DECODE(
            (1-SIGN(1-SIGN(TRUNC(NVL(t.bytes / a.bytes * 100, 0)) - 90))),
            1, '<font color="#990000">' || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>',
            '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>'
        ) || '</b> %</div>' AS pct_used
FROM
    sys.dba_tablespaces d
    LEFT JOIN (SELECT tablespace_name, SUM(bytes) AS bytes FROM dba_temp_files GROUP BY tablespace_name) a
        ON d.tablespace_name = a.tablespace_name
    LEFT JOIN (SELECT tablespace_name, SUM(bytes_cached) AS bytes FROM v$temp_extent_pool GROUP BY tablespace_name) t
        ON d.tablespace_name = t.tablespace_name
WHERE
    d.extent_management LIKE 'LOCAL'
    AND d.contents LIKE 'TEMPORARY'
ORDER BY 2;

prompt <a name="tablespaces"></a>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tablespaces in WSH</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

-- Formatting settings
COLUMN status                                  HEADING 'Status'            ENTMAP off
COLUMN name                                    HEADING 'Tablespace Name'   ENTMAP off
COLUMN type        FORMAT a12                  HEADING 'TS Type'           ENTMAP off
COLUMN extent_mgt  FORMAT a10                  HEADING 'Ext. Mgt.'         ENTMAP off
COLUMN segment_mgt FORMAT a9                   HEADING 'Seg. Mgt.'         ENTMAP off
COLUMN ts_size     FORMAT 999,999,999,999,999  HEADING 'Tablespace Size (GB)'   ENTMAP off
COLUMN free        FORMAT 999,999,999,999,999  HEADING 'Free (in GB)'      ENTMAP off
COLUMN used        FORMAT 999,999,999,999,999  HEADING 'Used (in GB)'      ENTMAP off
COLUMN pct_used                                HEADING 'Pct. Used'         ENTMAP off

-- Set up the break and compute for totals
BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>' OF ts_size used free ON report

-- Query for non-temporary tablespaces
SELECT
    DECODE(   
        d.status, 
        'OFFLINE', '<div align="center"><b><font color="#990000">' || d.status || '</font></b></div>',
        '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>'
    ) AS status,
    '<b><font color="#336699">' || d.tablespace_name || '</font></b>' AS name,
    d.contents AS type,
    d.extent_management AS extent_mgt,
    d.segment_space_management AS segment_mgt,
    ROUND(NVL(a.bytes, 0) / (1024 * 1024 ), 2) AS ts_size,   -- Tablespace size in GB
    ROUND(NVL(f.bytes, 0) / (1024 * 1024 ), 2) AS free,      -- Free space in GB
    ROUND(NVL(a.bytes - NVL(f.bytes, 0), 0) / (1024 * 1024 ), 2) AS used, -- Used space in GB
    '<div align="right"><b>' || 
        DECODE(
            (1-SIGN(1-SIGN(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0)) - 90))),
            1, '<font color="#990000">' || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>',
            '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>'
        ) || '</b> %</div>' AS pct_used
FROM 
    sys.dba_tablespaces@pps02 d
    LEFT JOIN (SELECT tablespace_name, SUM(bytes) AS bytes FROM dba_data_files@pps02 GROUP BY tablespace_name) a
        ON d.tablespace_name = a.tablespace_name
    LEFT JOIN (SELECT tablespace_name, SUM(bytes) AS bytes FROM dba_free_space@pps02 GROUP BY tablespace_name) f
        ON d.tablespace_name = f.tablespace_name
WHERE
    NOT (d.extent_management LIKE 'LOCAL' AND d.contents LIKE 'TEMPORARY')
ORDER BY 2;

-- Query for temporary tablespaces
SELECT
    DECODE(   
        d.status, 
        'OFFLINE', '<div align="center"><b><font color="#990000">' || d.status || '</font></b></div>',
        '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>'
    ) AS status,
    '<b><font color="#336699">' || d.tablespace_name || '</font></b>' AS name,
    d.contents AS type,
    d.extent_management AS extent_mgt,
    d.segment_space_management AS segment_mgt,
    ROUND(NVL(a.bytes, 0) / (1024 * 1024 ), 2) AS ts_size,   -- Tablespace size in GB
    ROUND(NVL(t.bytes, 0) / (1024 * 1024 ), 2) AS free,      -- Free space in GB
    ROUND(NVL(a.bytes - NVL(t.bytes, 0), 0) / (1024 * 1024 ), 2) AS used, -- Used space in GB
    '<div align="right"><b>' || 
        DECODE(
            (1-SIGN(1-SIGN(TRUNC(NVL(t.bytes / a.bytes * 100, 0)) - 90))),
            1, '<font color="#990000">' || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>',
            '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>'
        ) || '</b> %</div>' AS pct_used
FROM
    sys.dba_tablespaces@pps02 d
    LEFT JOIN (SELECT tablespace_name, SUM(bytes) AS bytes FROM dba_temp_files@pps02 GROUP BY tablespace_name) a
        ON d.tablespace_name = a.tablespace_name
    LEFT JOIN (SELECT tablespace_name, SUM(bytes_cached) AS bytes FROM v$temp_extent_pool@pps02 GROUP BY tablespace_name) t
        ON d.tablespace_name = t.tablespace_name
WHERE
    d.extent_management LIKE 'LOCAL'
    AND d.contents LIKE 'TEMPORARY'
ORDER BY 2;
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                          - DATABASE GROWTH -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="database_growth"></a>
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Database Growth</u></b></font></center>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Growth in Pap</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES
COLUMN month        FORMAT a75                  HEADING 'Month'
COLUMN growth       FORMAT 999,999,999,999,999  HEADING 'Growth (GB)'
BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>' OF growth ON report
SELECT
    '<div align="left"><font color="#336699"><b>' || TO_CHAR(creation_time, 'RRRR-MM') || '</b></font></div>' month
  , SUM(bytes)/1024/1024/1024                        growth
FROM     sys.v_$datafile
GROUP BY TO_CHAR(creation_time, 'RRRR-MM')
ORDER BY TO_CHAR(creation_time, 'RRRR-MM');
prompt
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Growth in WSH</b></font><hr align="left" width="460">
CLEAR COLUMNS BREAKS COMPUTES
COLUMN month        FORMAT a75                  HEADING 'Month'
COLUMN growth       FORMAT 999,999,999,999,999  HEADING 'Growth (GB)'
BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>' OF growth ON report
SELECT
    '<div align="left"><font color="#336699"><b>' || TO_CHAR(creation_time, 'RRRR-MM') || '</b></font></div>' month
  , SUM(bytes)/1024/1024/1024                        growth
FROM     sys.v_$datafile@pps02
GROUP BY TO_CHAR(creation_time, 'RRRR-MM')
ORDER BY TO_CHAR(creation_time, 'RRRR-MM');
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +============================================================================+
-- |                                                                            |
-- |                  <<<<<     SCHEDULER / JOBS     >>>>>                      |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Scheduler / Jobs</u></b></font></center>
prompt <a name="jobs"></a>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Jobs in PaP</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN job_id     FORMAT a75             HEADING 'Job ID'           ENTMAP off
COLUMN username   FORMAT a75             HEADING 'User'             ENTMAP off
COLUMN what       FORMAT a175            HEADING 'What'             ENTMAP off
COLUMN next_date  FORMAT a110            HEADING 'Next Run Date'    ENTMAP off
COLUMN interval   FORMAT a75             HEADING 'Interval'         ENTMAP off
COLUMN last_date  FORMAT a110            HEADING 'Last Run Date'    ENTMAP off
COLUMN failures   FORMAT a75             HEADING 'Failures'         ENTMAP off
COLUMN broken     FORMAT a75             HEADING 'Broken?'          ENTMAP off

SELECT
    DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || job || '</div></font></b>'
            , '<b><font color="#336699"><div align="center">' || job || '</div></font></b>')    job_id
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || log_user || '</font></b>'
            , log_user )    username
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || what || '</font></b>'
            , what )        what
  , DECODE(   broken
            , 'Y'
            , '<div nowrap align="right"><b><font color="#990000">' || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</font></b></div>'
            , '<div nowrap align="right">'                          || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>')      next_date  
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || interval || '</font></b>'
            , interval )    interval
  , DECODE(   broken
            , 'Y'
            , '<div nowrap align="right"><b><font color="#990000">' || NVL(TO_CHAR(last_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</font></b></div>'
            , '<div nowrap align="right">'                          || NVL(TO_CHAR(last_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>')    last_date  
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || NVL(failures, 0) || '</div></font></b>'
            , '<div align="center">'                          || NVL(failures, 0) || '</div>')    failures
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || broken || '</div></font></b>'
            , '<div align="center">'                          || broken || '</div>')      broken
FROM
    dba_jobs
ORDER BY job;
-- +----------------------------------------------------------------------------+
prompt
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Jobs in WSH</b></font><hr align="left" width="460">
CLEAR COLUMNS BREAKS COMPUTES
COLUMN job_id     FORMAT a75             HEADING 'Job ID'           ENTMAP off
COLUMN username   FORMAT a75             HEADING 'User'             ENTMAP off
COLUMN what       FORMAT a175            HEADING 'What'             ENTMAP off
COLUMN next_date  FORMAT a110            HEADING 'Next Run Date'    ENTMAP off
COLUMN interval   FORMAT a75             HEADING 'Interval'         ENTMAP off
COLUMN last_date  FORMAT a110            HEADING 'Last Run Date'    ENTMAP off
COLUMN failures   FORMAT a75             HEADING 'Failures'         ENTMAP off
COLUMN broken     FORMAT a75             HEADING 'Broken?'          ENTMAP off

SELECT
    DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || job || '</div></font></b>'
            , '<b><font color="#336699"><div align="center">' || job || '</div></font></b>')    job_id
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || log_user || '</font></b>'
            , log_user )    username
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || what || '</font></b>'
            , what )        what
  , DECODE(   broken
            , 'Y'
            , '<div nowrap align="right"><b><font color="#990000">' || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</font></b></div>'
            , '<div nowrap align="right">'                          || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>')      next_date  
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || interval || '</font></b>'
            , interval )    interval
  , DECODE(   broken
            , 'Y'
            , '<div nowrap align="right"><b><font color="#990000">' || NVL(TO_CHAR(last_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</font></b></div>'
            , '<div nowrap align="right">'                          || NVL(TO_CHAR(last_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>')    last_date  
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || NVL(failures, 0) || '</div></font></b>'
            , '<div align="center">'                          || NVL(failures, 0) || '</div>')    failures
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || broken || '</div></font></b>'
            , '<div align="center">'                          || broken || '</div>')      broken
FROM
    dba_jobs@pps02
ORDER BY job;



-- +----------------------------------------------------------------------------+
-- |                            - UNDO SEGMENTS -                               |
-- +----------------------------------------------------------------------------+

prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>UNDO SEGMENTS</u></b></font></center>
prompt <a name="undo_segments"></a>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO SEGMENTS in PaP</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name FORMAT a75              HEADING 'Instance Name'      ENTMAP off
COLUMN tablespace    FORMAT a85              HEADING 'Tablspace'          ENTMAP off
COLUMN roll_name                             HEADING 'UNDO Segment Name'  ENTMAP off
COLUMN in_extents                            HEADING 'Init/Next Extents'  ENTMAP off
COLUMN m_extents                             HEADING 'Min/Max Extents'    ENTMAP off
COLUMN status                                HEADING 'Status'             ENTMAP off
COLUMN wraps         FORMAT 999,999,999      HEADING 'Wraps'              ENTMAP off
COLUMN shrinks       FORMAT 999,999,999      HEADING 'Shrinks'            ENTMAP off
COLUMN opt           FORMAT 999,999,999,999  HEADING 'Opt. Size'          ENTMAP off
COLUMN bytes         FORMAT 999,999,999,999  HEADING 'Bytes'              ENTMAP off
COLUMN extents       FORMAT 999,999,999      HEADING 'Extents'            ENTMAP off

CLEAR COMPUTES BREAKS

BREAK ON report ON instance_name ON tablespace
-- COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF bytes extents shrinks wraps ON report

SELECT
    '<div nowrap><font color="#336699"><b>' ||  NVL(i.instance_name, '<br>')     || '</b></font></div>'  instance_name
  , '<div nowrap><font color="#336699"><b>' ||  a.tablespace_name                || '</b></font></div>'  tablespace
  , '<div nowrap>'                          ||  a.owner || '.' || a.segment_name || '</div>'             roll_name
  , '<div align="right">'     ||
    TO_CHAR(a.initial_extent) || ' / ' ||
    TO_CHAR(a.next_extent)    ||
    '</div>'                                                                in_extents
  , '<div align="right">'     ||
    TO_CHAR(a.min_extents)    || ' / ' ||
    TO_CHAR(a.max_extents)    ||
    '</div>'                                                                m_extents
  , DECODE(   a.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || a.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || a.status || '</font></b></div>') status
  , b.bytes                                   bytes
  , b.extents                                 extents
  , d.shrinks                                 shrinks
  , d.wraps                                   wraps
  , d.optsize                                 opt
FROM
    dba_rollback_segs a
  , dba_segments b
  , v$rollname c
  , v$rollstat d
  , gv$parameter p
  , gv$instance  i
WHERE
       a.segment_name  = b.segment_name
  AND  a.segment_name  = c.name (+)
  AND  c.usn           = d.usn (+)
  AND  p.name (+)      = 'undo_tablespace'
  AND  p.value (+)     = a.tablespace_name
  AND  p.inst_id       = i.inst_id (+)
ORDER BY
    a.tablespace_name
  , a.segment_name;

prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO SEGMENTS in WSH</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name FORMAT a75              HEADING 'Instance Name'      ENTMAP off
COLUMN tablespace    FORMAT a85              HEADING 'Tablspace'          ENTMAP off
COLUMN roll_name                             HEADING 'UNDO Segment Name'  ENTMAP off
COLUMN in_extents                            HEADING 'Init/Next Extents'  ENTMAP off
COLUMN m_extents                             HEADING 'Min/Max Extents'    ENTMAP off
COLUMN status                                HEADING 'Status'             ENTMAP off
COLUMN wraps         FORMAT 999,999,999      HEADING 'Wraps'              ENTMAP off
COLUMN shrinks       FORMAT 999,999,999      HEADING 'Shrinks'            ENTMAP off
COLUMN opt           FORMAT 999,999,999,999  HEADING 'Opt. Size'          ENTMAP off
COLUMN bytes         FORMAT 999,999,999,999  HEADING 'Bytes'              ENTMAP off
COLUMN extents       FORMAT 999,999,999      HEADING 'Extents'            ENTMAP off

CLEAR COMPUTES BREAKS

BREAK ON report ON instance_name ON tablespace
-- COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF bytes extents shrinks wraps ON report

SELECT
    '<div nowrap><font color="#336699"><b>' ||  NVL(i.instance_name, '<br>')     || '</b></font></div>'  instance_name
  , '<div nowrap><font color="#336699"><b>' ||  a.tablespace_name                || '</b></font></div>'  tablespace
  , '<div nowrap>'                          ||  a.owner || '.' || a.segment_name || '</div>'             roll_name
  , '<div align="right">'     ||
    TO_CHAR(a.initial_extent) || ' / ' ||
    TO_CHAR(a.next_extent)    ||
    '</div>'                                                                in_extents
  , '<div align="right">'     ||
    TO_CHAR(a.min_extents)    || ' / ' ||
    TO_CHAR(a.max_extents)    ||
    '</div>'                                                                m_extents
  , DECODE(   a.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || a.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || a.status || '</font></b></div>') status
  , b.bytes                                   bytes
  , b.extents                                 extents
  , d.shrinks                                 shrinks
  , d.wraps                                   wraps
  , d.optsize                                 opt
FROM
    dba_rollback_segs@pps02 a
  , dba_segments@pps02 b
  , v$rollname@pps02 c
  , v$rollstat@pps02 d
  , gv$parameter@pps02 p
  , gv$instance@pps02  i
WHERE
       a.segment_name  = b.segment_name
  AND  a.segment_name  = c.name (+)
  AND  c.usn           = d.usn (+)
  AND  p.name (+)      = 'undo_tablespace'
  AND  p.value (+)     = a.tablespace_name
  AND  p.inst_id       = i.inst_id (+)
ORDER BY
    a.tablespace_name
  , a.segment_name;
  
prompt
prompt


-- +----------------------------------------------------------------------------+
-- |                        - UNDO SEGMENT CONTENTION -                         |
-- +----------------------------------------------------------------------------+


prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>UNDO Segment Contention</u></b></font></center>
prompt <a name="undo_segment_contention"></a>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO SEGMENTS Contentionin PaP</b></font><hr align="left" width="460">
prompt <b>UNDO statistics from V$ROLLSTAT - (ordered by waits)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN roll_name                             HEADING 'UNDO Segment Name'   ENTMAP off
COLUMN gets             FORMAT 999,999,999   HEADING 'Gets'                ENTMAP off
COLUMN waits            FORMAT 999,999,999   HEADING 'Waits'               ENTMAP off
COLUMN immediate_misses FORMAT 999,999,999   HEADING 'Immediate Misses'    ENTMAP off
COLUMN hit_ratio                             HEADING 'Hit Ratio'           ENTMAP off

BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>' OF gets waits ON report

SELECT
    '<font color="#336699"><b>' || b.name || '</b></font>'  roll_name
  , gets                               gets
  , waits                              waits
  , '<div align="right">' || TO_CHAR(ROUND(((gets - waits)*100)/gets, 2)) || '%</div>' hit_ratio
FROM 
    sys.v_$rollstat a
  , sys.v_$rollname b
WHERE
    a.USN = b.USN
ORDER BY
    waits DESC;


prompt 
prompt <b>Wait statistics</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN class                  HEADING 'Class'    
COLUMN ratio                  HEADING 'Wait Ratio'       

SELECT
    '<font color="#336699"><b>' || w.class || '</b></font>'                            class
  , '<div align="right">' || TO_CHAR(ROUND(100*(w.count/SUM(s.value)),8)) || '%</div>' ratio
FROM
    v$waitstat  w
  , v$sysstat   s
WHERE
      w.class IN (  'system undo header'
                  , 'system undo block'
                  , 'undo header'
                  , 'undo block'
                 )
  AND s.name IN ('db block gets', 'consistent gets')
GROUP BY
    w.class
  , w.count;

  prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO SEGMENTS Contentionin WSH</b></font><hr align="left" width="460">
prompt <b>UNDO statistics from V$ROLLSTAT - (ordered by waits)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN roll_name                             HEADING 'UNDO Segment Name'   ENTMAP off
COLUMN gets             FORMAT 999,999,999   HEADING 'Gets'                ENTMAP off
COLUMN waits            FORMAT 999,999,999   HEADING 'Waits'               ENTMAP off
COLUMN immediate_misses FORMAT 999,999,999   HEADING 'Immediate Misses'    ENTMAP off
COLUMN hit_ratio                             HEADING 'Hit Ratio'           ENTMAP off

BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>' OF gets waits ON report

SELECT
    '<font color="#336699"><b>' || b.name || '</b></font>'  roll_name
  , gets                               gets
  , waits                              waits
  , '<div align="right">' || TO_CHAR(ROUND(((gets - waits)*100)/gets, 2)) || '%</div>' hit_ratio
FROM 
    sys.v_$rollstat@pps02 a
  , sys.v_$rollname@pps02 b
WHERE
    a.USN = b.USN
ORDER BY
    waits DESC;


prompt 
prompt <b>Wait statistics</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN class                  HEADING 'Class'    
COLUMN ratio                  HEADING 'Wait Ratio'       

SELECT
    '<font color="#336699"><b>' || w.class || '</b></font>'                            class
  , '<div align="right">' || TO_CHAR(ROUND(100*(w.count/SUM(s.value)),8)) || '%</div>' ratio
FROM
    v$waitstat@pps02  w
  , v$sysstat@pps02   s
WHERE
      w.class IN (  'system undo header'
                  , 'system undo block'
                  , 'undo header'
                  , 'undo block'
                 )
  AND s.name IN ('db block gets', 'consistent gets')
GROUP BY
    w.class
  , w.count;

  
  


-- +----------------------------------------------------------------------------+
-- |                       - UNDO RETENTION PARAMETERS -                        |
-- +----------------------------------------------------------------------------+

prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>UNDO Retention Parameters</u></b></font></center>
prompt <a name="undo_retention_parameters"></a>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO  Contentionin PaP</b></font><hr align="left" width="460">

prompt <b>undo_retention is specified in minutes</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print   FORMAT a95    HEADING 'Instance Name'     ENTMAP off
COLUMN thread_number_print   FORMAT a95    HEADING 'Thread Number'     ENTMAP off
COLUMN name                  FORMAT a125   HEADING 'Name'              ENTMAP off
COLUMN value                               HEADING 'Value'             ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'        instance_name_print
  , '<div align="center">'                          || i.thread#       || '</div>'                   thread_number_print
  , '<div nowrap>'                                  || p.name          || '</div>'                   name
  , (CASE p.name
         WHEN 'undo_retention' THEN '<div nowrap align="right">' || TO_CHAR(TO_NUMBER(p.value)/60, '999,999,999,999,999') || '</div>'
     ELSE
         '<div nowrap align="right">' || p.value || '</div>'
     END)                                                                                            value
FROM
    gv$parameter p
  , gv$instance  i
WHERE
      p.inst_id = i.inst_id
  AND p.name LIKE 'undo%'
ORDER BY
    i.instance_name
  , p.name;
  
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO  Contentionin WSH</b></font><hr align="left" width="460">

prompt <b>undo_retention is specified in minutes</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print   FORMAT a95    HEADING 'Instance Name'     ENTMAP off
COLUMN thread_number_print   FORMAT a95    HEADING 'Thread Number'     ENTMAP off
COLUMN name                  FORMAT a125   HEADING 'Name'              ENTMAP off
COLUMN value                               HEADING 'Value'             ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'        instance_name_print
  , '<div align="center">'                          || i.thread#       || '</div>'                   thread_number_print
  , '<div nowrap>'                                  || p.name          || '</div>'                   name
  , (CASE p.name
         WHEN 'undo_retention' THEN '<div nowrap align="right">' || TO_CHAR(TO_NUMBER(p.value)/60, '999,999,999,999,999') || '</div>'
     ELSE
         '<div nowrap align="right">' || p.value || '</div>'
     END)                                                                                            value
FROM
    gv$parameter@pps02 p
  , gv$instance@pps02  i
WHERE
      p.inst_id = i.inst_id
  AND p.name LIKE 'undo%'
ORDER BY
    i.instance_name
  , p.name;

  




-- +----------------------------------------------------------------------------+
-- |                           - RMAN BACKUP JOBS -                             |
-- +----------------------------------------------------------------------------+
prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Backups</u></b></font></center>
prompt <a name="rman_backup_jobs"></a>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Jobs PaP</b></font><hr align="left" width="460">

prompt <b>Last 10 RMAN backup jobs</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN backup_name           FORMAT a130   HEADING 'Backup Name'          ENTMAP off
COLUMN start_time            FORMAT a75    HEADING 'Start Time'           ENTMAP off
COLUMN elapsed_time          FORMAT a75    HEADING 'Elapsed Time'         ENTMAP off
COLUMN status                              HEADING 'Status'               ENTMAP off
COLUMN input_type                          HEADING 'Input Type'           ENTMAP off
COLUMN output_device_type                  HEADING 'Output Devices'       ENTMAP off
COLUMN input_size                          HEADING 'Input Size'           ENTMAP off
COLUMN output_size                         HEADING 'Output Size'          ENTMAP off
COLUMN output_rate_per_sec                 HEADING 'Output Rate Per Sec'  ENTMAP off

SELECT
    '<div nowrap><b><font color="#336699">' || r.command_id                                   || '</font></b></div>'  backup_name
  , '<div nowrap align="right">'            || TO_CHAR(r.start_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>'             start_time
  , '<div nowrap align="right">'            || r.time_taken_display                           || '</div>'             elapsed_time
  , DECODE(   r.status
            , 'COMPLETED'
            , '<div align="center"><b><font color="darkgreen">' || r.status || '</font></b></div>'
            , 'RUNNING'
            , '<div align="center"><b><font color="#000099">'   || r.status || '</font></b></div>'
            , 'FAILED'
            , '<div align="center"><b><font color="#990000">'   || r.status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || r.status || '</font></b></div>'
    )                                                                                       status
  , r.input_type                                                                            input_type
  , r.output_device_type                                                                    output_device_type
  , '<div nowrap align="right">' || r.input_bytes_display           || '</div>'  input_size
  , '<div nowrap align="right">' || r.output_bytes_display          || '</div>'  output_size
  , '<div nowrap align="right">' || r.output_bytes_per_sec_display  || '</div>'  output_rate_per_sec
FROM
    (select
         command_id
       , start_time
       , time_taken_display
       , status
       , input_type
       , output_device_type
       , input_bytes_display
       , output_bytes_display
       , output_bytes_per_sec_display
     from v$rman_backup_job_details
     order by start_time DESC
    ) r
WHERE
    rownum < 11; 
prompt
prompt
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Jobs WSH</b></font><hr align="left" width="460">

prompt <b>Last 10 RMAN backup jobs</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN backup_name           FORMAT a130   HEADING 'Backup Name'          ENTMAP off
COLUMN start_time            FORMAT a75    HEADING 'Start Time'           ENTMAP off
COLUMN elapsed_time          FORMAT a75    HEADING 'Elapsed Time'         ENTMAP off
COLUMN status                              HEADING 'Status'               ENTMAP off
COLUMN input_type                          HEADING 'Input Type'           ENTMAP off
COLUMN output_device_type                  HEADING 'Output Devices'       ENTMAP off
COLUMN input_size                          HEADING 'Input Size'           ENTMAP off
COLUMN output_size                         HEADING 'Output Size'          ENTMAP off
COLUMN output_rate_per_sec                 HEADING 'Output Rate Per Sec'  ENTMAP off

SELECT
    '<div nowrap><b><font color="#336699">' || r.command_id                                   || '</font></b></div>'  backup_name
  , '<div nowrap align="right">'            || TO_CHAR(r.start_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>'             start_time
  , '<div nowrap align="right">'            || r.time_taken_display                           || '</div>'             elapsed_time
  , DECODE(   r.status
            , 'COMPLETED'
            , '<div align="center"><b><font color="darkgreen">' || r.status || '</font></b></div>'
            , 'RUNNING'
            , '<div align="center"><b><font color="#000099">'   || r.status || '</font></b></div>'
            , 'FAILED'
            , '<div align="center"><b><font color="#990000">'   || r.status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || r.status || '</font></b></div>'
    )                                                                                       status
  , r.input_type                                                                            input_type
  , r.output_device_type                                                                    output_device_type
  , '<div nowrap align="right">' || r.input_bytes_display           || '</div>'  input_size
  , '<div nowrap align="right">' || r.output_bytes_display          || '</div>'  output_size
  , '<div nowrap align="right">' || r.output_bytes_per_sec_display  || '</div>'  output_rate_per_sec
FROM
    (select
         command_id
       , start_time
       , time_taken_display
       , status
       , input_type
       , output_device_type
       , input_bytes_display
       , output_bytes_display
       , output_bytes_per_sec_display
     from v$rman_backup_job_details@pps02
     order by start_time DESC
    ) r
WHERE
    rownum < 11; 
	
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>
prompt


-- +----------------------------------------------------------------------------+
-- |                           - RMAN BACKUP SPFILE -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_spfile"></a>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup SPFILE PaP</b></font><hr align="left" width="460">

prompt <b>Available automatic SPFILE backups within all available (and expired) backup sets</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key                 FORMAT a75                     HEADING 'BS Key'                 ENTMAP off
COLUMN piece#                                                HEADING 'Piece #'                ENTMAP off
COLUMN copy#                                                 HEADING 'Copy #'                 ENTMAP off
COLUMN bp_key                                                HEADING 'BP Key'                 ENTMAP off
COLUMN spfile_included        FORMAT a75                     HEADING 'SPFILE Included?'       ENTMAP off
COLUMN status                                                HEADING 'Status'                 ENTMAP off
COLUMN handle                                                HEADING 'Handle'                 ENTMAP off
COLUMN start_time             FORMAT a40                     HEADING 'Start Time'             ENTMAP off
COLUMN completion_time        FORMAT a40                     HEADING 'End Time'               ENTMAP off
COLUMN elapsed_seconds        FORMAT 999,999,999,999,999     HEADING 'Elapsed Seconds'        ENTMAP off
COLUMN deleted                FORMAT a10                     HEADING 'Deleted?'               ENTMAP off

BREAK ON bs_key

SELECT
    '<div align="center"><font color="#336699"><b>' || bs.recid  || '</b></font></div>'             bs_key
  , bp.piece#                                                                                       piece#
  , bp.copy#                                                                                        copy#
  , bp.recid                                                                                        bp_key
  , '<div align="center"><font color="#663300"><b>'  ||
    NVL(sp.spfile_included, '-')                     ||
    '</b></font></div>'                                                                             spfile_included
  , DECODE(   status
            , 'A', '<div nowrap align="center"><font color="darkgreen"><b>Available</b></font></div>'
            , 'D', '<div nowrap align="center"><font color="#000099"><b>Deleted</b></font></div>'
            , 'X', '<div nowrap align="center"><font color="#990000"><b>Expired</b></font></div>')  status
  , handle                                                                                          handle
FROM
    v$backup_set                            bs
  , v$backup_piece                          bp
  ,  (select distinct set_stamp, set_count, 'YES' spfile_included
      from v$backup_spfile)                 sp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
  AND bs.set_stamp = sp.set_stamp
  AND bs.set_count = sp.set_count
ORDER BY
    bs.recid
  , piece#;
prompt
prompt
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup SPFILE WSH</b></font><hr align="left" width="460">

prompt <b>Available automatic SPFILE backups within all available (and expired) backup sets</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key                 FORMAT a75                     HEADING 'BS Key'                 ENTMAP off
COLUMN piece#                                                HEADING 'Piece #'                ENTMAP off
COLUMN copy#                                                 HEADING 'Copy #'                 ENTMAP off
COLUMN bp_key                                                HEADING 'BP Key'                 ENTMAP off
COLUMN spfile_included        FORMAT a75                     HEADING 'SPFILE Included?'       ENTMAP off
COLUMN status                                                HEADING 'Status'                 ENTMAP off
COLUMN handle                                                HEADING 'Handle'                 ENTMAP off
COLUMN start_time             FORMAT a40                     HEADING 'Start Time'             ENTMAP off
COLUMN completion_time        FORMAT a40                     HEADING 'End Time'               ENTMAP off
COLUMN elapsed_seconds        FORMAT 999,999,999,999,999     HEADING 'Elapsed Seconds'        ENTMAP off
COLUMN deleted                FORMAT a10                     HEADING 'Deleted?'               ENTMAP off

BREAK ON bs_key

SELECT
    '<div align="center"><font color="#336699"><b>' || bs.recid  || '</b></font></div>'             bs_key
  , bp.piece#                                                                                       piece#
  , bp.copy#                                                                                        copy#
  , bp.recid                                                                                        bp_key
  , '<div align="center"><font color="#663300"><b>'  ||
    NVL(sp.spfile_included, '-')                     ||
    '</b></font></div>'                                                                             spfile_included
  , DECODE(   status
            , 'A', '<div nowrap align="center"><font color="darkgreen"><b>Available</b></font></div>'
            , 'D', '<div nowrap align="center"><font color="#000099"><b>Deleted</b></font></div>'
            , 'X', '<div nowrap align="center"><font color="#990000"><b>Expired</b></font></div>')  status
  , handle                                                                                          handle
FROM
    v$backup_set@pps02                            bs
  , v$backup_piece@pps02                          bp
  ,  (select distinct set_stamp, set_count, 'YES' spfile_included
      from v$backup_spfile@pps02)                 sp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
  AND bs.set_stamp = sp.set_stamp
  AND bs.set_count = sp.set_count
ORDER BY
    bs.recid
  , piece#;


-- +----------------------------------------------------------------------------+
-- |                           - RMAN CONFIGURATION -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_configuration"></a>
prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>RMAN Configuration</u></b></font></center>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Configuration PaP</b></font><hr align="left" width="460">

prompt <b>All non-default RMAN configuration settings</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name     FORMAT a130   HEADING 'Name'   ENTMAP off
COLUMN value                  HEADING 'Value'  ENTMAP off

SELECT
    '<div nowrap><b><font color="#336699">' || name || '</font></b></div>'   name
  , value
FROM
    v$rman_configuration
ORDER BY
    name;
prompt
prompt
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Configuration PaP</b></font><hr align="left" width="460">

prompt <b>All non-default RMAN configuration settings</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name     FORMAT a130   HEADING 'Name'   ENTMAP off
COLUMN value                  HEADING 'Value'  ENTMAP off

SELECT
    '<div nowrap><b><font color="#336699">' || name || '</font></b></div>'   name
  , value
FROM
    v$rman_configuration@pps02
ORDER BY
    name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +----------------------------------------------------------------------------+
-- |                           - RMAN BACKUP SETS -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_sets"></a>
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>RMAN Backup Sets</u></b></font></center>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Sets PaP</b></font><hr align="left" width="460">

prompt <b>Available backup sets contained in the control file including available and expired backup sets</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key                 FORMAT a75                    HEADING 'BS Key'                 ENTMAP off
COLUMN backup_type            FORMAT a70                    HEADING 'Backup Type'            ENTMAP off
COLUMN device_type                                          HEADING 'Device Type'            ENTMAP off
COLUMN controlfile_included   FORMAT a30                    HEADING 'Controlfile Included?'  ENTMAP off
COLUMN spfile_included        FORMAT a30                    HEADING 'SPFILE Included?'       ENTMAP off
COLUMN incremental_level                                    HEADING 'Incremental Level'      ENTMAP off
COLUMN pieces                 FORMAT 999,999,999,999        HEADING '# of Pieces'            ENTMAP off
COLUMN start_time             FORMAT a75                    HEADING 'Start Time'             ENTMAP off
COLUMN completion_time        FORMAT a75                    HEADING 'End Time'               ENTMAP off
COLUMN elapsed_seconds        FORMAT 999,999,999,999,999    HEADING 'Elapsed Seconds'        ENTMAP off
COLUMN tag                                                  HEADING 'Tag'                    ENTMAP off
COLUMN block_size             FORMAT 999,999,999,999,999    HEADING 'Block Size'             ENTMAP off
COLUMN keep                   FORMAT a40                    HEADING 'Keep?'                  ENTMAP off
COLUMN keep_until             FORMAT a75                    HEADING 'Keep Until'             ENTMAP off
COLUMN keep_options           FORMAT a15                    HEADING 'Keep Options'           ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF pieces elapsed_seconds ON report

SELECT
    '<div align="center"><font color="#336699"><b>' || bs.recid || '</b></font></div>'                        bs_key
  , DECODE(backup_type
           , 'L', '<div nowrap><font color="#990000">Archived Redo Logs</font></div>'
           , 'D', '<div nowrap><font color="#000099">Datafile Full Backup</font></div>'
           , 'I', '<div nowrap><font color="darkgreen">Incremental Backup</font></div>')                      backup_type
  , '<div nowrap align="right">' || device_type || '</div>'                                                   device_type
  , '<div align="center">' ||
    DECODE(bs.controlfile_included, 'NO', '-', bs.controlfile_included) || '</div>'                           controlfile_included
  , '<div align="center">' || NVL(sp.spfile_included, '-') || '</div>'                                        spfile_included
  , bs.incremental_level                                                                                      incremental_level
  , bs.pieces                                                                                                 pieces
  , '<div nowrap align="right">' || TO_CHAR(bs.start_time, 'mm/dd/yyyy HH24:MI:SS')      || '</div>'          start_time
  , '<div nowrap align="right">' || TO_CHAR(bs.completion_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>'          completion_time
  , bs.elapsed_seconds                                                                                        elapsed_seconds
  , bp.tag                                                                                                    tag
  , bs.block_size                                                                                             block_size
  , '<div align="center">' || bs.keep || '</div>'                                                             keep
  , '<div nowrap align="right">' || NVL(TO_CHAR(bs.keep_until, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'  keep_until
  , bs.keep_options                                                                                           keep_options
FROM
    v$backup_set                           bs
  , (select distinct
         set_stamp
       , set_count
       , tag
       , device_type
     from v$backup_piece
     where status in ('A', 'X'))           bp
 ,  (select distinct set_stamp, set_count, 'YES' spfile_included
     from v$backup_spfile)                 sp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bs.set_stamp = sp.set_stamp (+)
  AND bs.set_count = sp.set_count (+)
ORDER BY
    bs.recid;

	
prompt

prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Sets WSH</b></font><hr align="left" width="460">

prompt <b>Available backup sets contained in the control file including available and expired backup sets</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key                 FORMAT a75                    HEADING 'BS Key'                 ENTMAP off
COLUMN backup_type            FORMAT a70                    HEADING 'Backup Type'            ENTMAP off
COLUMN device_type                                          HEADING 'Device Type'            ENTMAP off
COLUMN controlfile_included   FORMAT a30                    HEADING 'Controlfile Included?'  ENTMAP off
COLUMN spfile_included        FORMAT a30                    HEADING 'SPFILE Included?'       ENTMAP off
COLUMN incremental_level                                    HEADING 'Incremental Level'      ENTMAP off
COLUMN pieces                 FORMAT 999,999,999,999        HEADING '# of Pieces'            ENTMAP off
COLUMN start_time             FORMAT a75                    HEADING 'Start Time'             ENTMAP off
COLUMN completion_time        FORMAT a75                    HEADING 'End Time'               ENTMAP off
COLUMN elapsed_seconds        FORMAT 999,999,999,999,999    HEADING 'Elapsed Seconds'        ENTMAP off
COLUMN tag                                                  HEADING 'Tag'                    ENTMAP off
COLUMN block_size             FORMAT 999,999,999,999,999    HEADING 'Block Size'             ENTMAP off
COLUMN keep                   FORMAT a40                    HEADING 'Keep?'                  ENTMAP off
COLUMN keep_until             FORMAT a75                    HEADING 'Keep Until'             ENTMAP off
COLUMN keep_options           FORMAT a15                    HEADING 'Keep Options'           ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF pieces elapsed_seconds ON report

SELECT
    '<div align="center"><font color="#336699"><b>' || bs.recid || '</b></font></div>'                        bs_key
  , DECODE(backup_type
           , 'L', '<div nowrap><font color="#990000">Archived Redo Logs</font></div>'
           , 'D', '<div nowrap><font color="#000099">Datafile Full Backup</font></div>'
           , 'I', '<div nowrap><font color="darkgreen">Incremental Backup</font></div>')                      backup_type
  , '<div nowrap align="right">' || device_type || '</div>'                                                   device_type
  , '<div align="center">' ||
    DECODE(bs.controlfile_included, 'NO', '-', bs.controlfile_included) || '</div>'                           controlfile_included
  , '<div align="center">' || NVL(sp.spfile_included, '-') || '</div>'                                        spfile_included
  , bs.incremental_level                                                                                      incremental_level
  , bs.pieces                                                                                                 pieces
  , '<div nowrap align="right">' || TO_CHAR(bs.start_time, 'mm/dd/yyyy HH24:MI:SS')      || '</div>'          start_time
  , '<div nowrap align="right">' || TO_CHAR(bs.completion_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>'          completion_time
  , bs.elapsed_seconds                                                                                        elapsed_seconds
  , bp.tag                                                                                                    tag
  , bs.block_size                                                                                             block_size
  , '<div align="center">' || bs.keep || '</div>'                                                             keep
  , '<div nowrap align="right">' || NVL(TO_CHAR(bs.keep_until, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'  keep_until
  , bs.keep_options                                                                                           keep_options
FROM
    v$backup_set@pps02                           bs
  , (select distinct
         set_stamp
       , set_count
       , tag
       , device_type
     from v$backup_piece@pps02
     where status in ('A', 'X'))           bp
 ,  (select distinct set_stamp, set_count, 'YES' spfile_included
     from v$backup_spfile@pps02)                 sp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bs.set_stamp = sp.set_stamp (+)
  AND bs.set_count = sp.set_count (+)
ORDER BY
    bs.recid;
	
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                       - RMAN BACKUP CONTROL FILES -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_control_files"></a>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Sets PaP</b></font><hr align="left" width="460">

prompt <b>Available automatic control files within all available (and expired) backup sets</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key                 FORMAT a75                     HEADING 'BS Key'                 ENTMAP off
COLUMN piece#                                                HEADING 'Piece #'                ENTMAP off
COLUMN copy#                                                 HEADING 'Copy #'                 ENTMAP off
COLUMN bp_key                                                HEADING 'BP Key'                 ENTMAP off
COLUMN controlfile_included   FORMAT a75                     HEADING 'Controlfile Included?'  ENTMAP off
COLUMN status                                                HEADING 'Status'                 ENTMAP off
COLUMN handle                                                HEADING 'Handle'                 ENTMAP off
COLUMN start_time             FORMAT a40                     HEADING 'Start Time'             ENTMAP off
COLUMN completion_time        FORMAT a40                     HEADING 'End Time'               ENTMAP off
COLUMN elapsed_seconds        FORMAT 999,999,999,999,999     HEADING 'Elapsed Seconds'        ENTMAP off
COLUMN deleted                FORMAT a10                     HEADING 'Deleted?'               ENTMAP off

BREAK ON bs_key

SELECT
    '<div align="center"><font color="#336699"><b>' || bs.recid  || '</b></font></div>'             bs_key
  , bp.piece#                                                                                       piece#
  , bp.copy#                                                                                        copy#
  , bp.recid                                                                                        bp_key
  , '<div align="center"><font color="#663300"><b>'                      ||
    DECODE(bs.controlfile_included, 'NO', '-', bs.controlfile_included)  ||
    '</b></font></div>'                                                                             controlfile_included
  , DECODE(   status
            , 'A', '<div nowrap align="center"><font color="darkgreen"><b>Available</b></font></div>'
            , 'D', '<div nowrap align="center"><font color="#000099"><b>Deleted</b></font></div>'
            , 'X', '<div nowrap align="center"><font color="#990000"><b>Expired</b></font></div>')  status
  , handle                                                                                          handle
FROM
    v$backup_set    bs
  , v$backup_piece  bp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
  AND bs.controlfile_included != 'NO'
ORDER BY
    bs.recid
  , piece#;

prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Sets WSH</b></font><hr align="left" width="460">

prompt <b>Available automatic control files within all available (and expired) backup sets</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key                 FORMAT a75                     HEADING 'BS Key'                 ENTMAP off
COLUMN piece#                                                HEADING 'Piece #'                ENTMAP off
COLUMN copy#                                                 HEADING 'Copy #'                 ENTMAP off
COLUMN bp_key                                                HEADING 'BP Key'                 ENTMAP off
COLUMN controlfile_included   FORMAT a75                     HEADING 'Controlfile Included?'  ENTMAP off
COLUMN status                                                HEADING 'Status'                 ENTMAP off
COLUMN handle                                                HEADING 'Handle'                 ENTMAP off
COLUMN start_time             FORMAT a40                     HEADING 'Start Time'             ENTMAP off
COLUMN completion_time        FORMAT a40                     HEADING 'End Time'               ENTMAP off
COLUMN elapsed_seconds        FORMAT 999,999,999,999,999     HEADING 'Elapsed Seconds'        ENTMAP off
COLUMN deleted                FORMAT a10                     HEADING 'Deleted?'               ENTMAP off

BREAK ON bs_key

SELECT
    '<div align="center"><font color="#336699"><b>' || bs.recid  || '</b></font></div>'             bs_key
  , bp.piece#                                                                                       piece#
  , bp.copy#                                                                                        copy#
  , bp.recid                                                                                        bp_key
  , '<div align="center"><font color="#663300"><b>'                      ||
    DECODE(bs.controlfile_included, 'NO', '-', bs.controlfile_included)  ||
    '</b></font></div>'                                                                             controlfile_included
  , DECODE(   status
            , 'A', '<div nowrap align="center"><font color="darkgreen"><b>Available</b></font></div>'
            , 'D', '<div nowrap align="center"><font color="#000099"><b>Deleted</b></font></div>'
            , 'X', '<div nowrap align="center"><font color="#990000"><b>Expired</b></font></div>')  status
  , handle                                                                                          handle
FROM
    v$backup_set@pps02    bs
  , v$backup_piece@pps02  bp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
  AND bs.controlfile_included != 'NO'
ORDER BY
    bs.recid
  , piece#;
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                    - TOP 10 SEGMENTS (BY SIZE) -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="top_10_segments_by_size"></a>
prompt
prompt <center><font size="+2" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#04034F"><b><u>Top Segments</u></b></font></center>
prompt <font size="+1" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Top 10 Segments(PaP)</b></font><hr align="left" width="10%">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                                               HEADING 'Owner'            ENTMAP off
COLUMN segment_name                                        HEADING 'Segment Name'     ENTMAP off
COLUMN partition_name                                      HEADING 'Partition Name'   ENTMAP off
COLUMN segment_type                                        HEADING 'Segment Type'     ENTMAP off
COLUMN tablespace_name                                     HEADING 'Tablespace Name'  ENTMAP off
COLUMN bytes               FORMAT 999,999,999,999,999,999  HEADING 'Size (in bytes)'  ENTMAP off
COLUMN extents             FORMAT 999,999,999,999,999,999  HEADING 'Extents'          ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF bytes extents ON report

SELECT
    a.owner
  , a.segment_name
  , a.partition_name
  , a.segment_type
  , a.tablespace_name
  , a.bytes
  , a.extents
FROM
    (select
         b.owner
       , b.segment_name
       , b.partition_name
       , b.segment_type
       , b.tablespace_name
       , b.bytes
       , b.extents
     from
         dba_segments b
     order by
         b.bytes desc
    ) a
WHERE
    rownum < 11;
prompt
prompt	
prompt <font size="+1" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Top 10 Segments(WSH)</b></font><hr align="left" width="10%">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                                               HEADING 'Owner'            ENTMAP off
COLUMN segment_name                                        HEADING 'Segment Name'     ENTMAP off
COLUMN partition_name                                      HEADING 'Partition Name'   ENTMAP off
COLUMN segment_type                                        HEADING 'Segment Type'     ENTMAP off
COLUMN tablespace_name                                     HEADING 'Tablespace Name'  ENTMAP off
COLUMN bytes               FORMAT 999,999,999,999,999,999  HEADING 'Size (in bytes)'  ENTMAP off
COLUMN extents             FORMAT 999,999,999,999,999,999  HEADING 'Extents'          ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF bytes extents ON report

SELECT
    a.owner
  , a.segment_name
  , a.partition_name
  , a.segment_type
  , a.tablespace_name
  , a.bytes
  , a.extents
FROM
    (select
         b.owner
       , b.segment_name
       , b.partition_name
       , b.segment_type
       , b.tablespace_name
       , b.bytes
       , b.extents
     from
         dba_segments@pps02 b
     order by
         b.bytes desc
    ) a
WHERE
    rownum < 11;	





-- +----------------------------------------------------------------------------+
-- |                            - Archive Log Space -                           |
-- +----------------------------------------------------------------------------+
prompt
prompt <center><font size="+2" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#04034F"><b><u>Archive Log Status</u></b></font></center>
prompt <a name="Archive_Log_Space_PaP"></a>
prompt <font size="large" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Archive Log Space(PaP)</b></font><hr align="left" width="10%">
CLEAR COLUMNS BREAKS COMPUTES
col FILE_TYPE 						format A30
col PERCENT_SPACE_USED 				format 9999999 
col PERCENT_SPACE_RECLAIMABLE 		format 999999999 
col NUMBER_OF_FILES 				format 999999999 
select FILE_TYPE , PERCENT_SPACE_USED , PERCENT_SPACE_RECLAIMABLE , NUMBER_OF_FILES from v$recovery_area_usage where FILE_TYPE in ('CONTROL FILE','ARCHIVED LOG');
prompt <a name="Archive_Log_Space_WSH"></a>
prompt <font size="large" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Archive Log Space(PaP)</b></font><hr align="left" width="10%">
CLEAR COLUMNS BREAKS COMPUTES
col FILE_TYPE 						format A30
col PERCENT_SPACE_USED 				format 9999999 
col PERCENT_SPACE_RECLAIMABLE 		format 999999999 
col NUMBER_OF_FILES 				format 999999999 
select FILE_TYPE , PERCENT_SPACE_USED , PERCENT_SPACE_RECLAIMABLE , NUMBER_OF_FILES from v$recovery_area_usage@PPs02 where FILE_TYPE in ('CONTROL FILE','ARCHIVED LOG');
prompt
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |     				- Total used size of the DB -                           |
-- +----------------------------------------------------------------------------+
prompt
prompt <center><font size="+2" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#04034F"><b><u>Database Size</u></b></font></center>
prompt <a name="Total_Used_size_of_the_DB"></a>
CLEAR COLUMNS BREAKS COMPUTES
select sum (bytes)/1024/1024/1024 as "Total SIZE IN GB for PaP"  from dba_data_files ;
CLEAR COLUMNS BREAKS COMPUTES
select sum (bytes)/1024/1024/1024 as "Total SIZE IN GB for WSH"  from dba_data_files@PPs02 ;

-- +----------------------------------------------------------------------------+
-- |     				- Total Free size of the DB -                           |
-- +----------------------------------------------------------------------------+
prompt <a name="Total_Free_size_of_the_DB"></a>
CLEAR COLUMNS BREAKS COMPUTES
select  sum (bytes)/1024/1024/1024 "Free Size in GB for PaP" from dba_free_space; 
CLEAR COLUMNS BREAKS COMPUTES
select  sum (bytes)/1024/1024/1024 "Free Size in GB for WSH" from dba_free_space@PPs02 ;
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - LOB SEGMENTS -                                 |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_lob_segments"></a>
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>LOB Segments</u></b></font></center>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>LOB Segments PaP</b></font><hr align="left" width="460">

prompt <b>Excluding all internal system schemas (i.e. CTXSYS, MDSYS, SYS, SYSTEM)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner              FORMAT a85        HEADING 'Owner'              ENTMAP off
COLUMN table_name         FORMAT a75        HEADING 'Table Name'         ENTMAP off
COLUMN column_name        FORMAT a75        HEADING 'Column Name'        ENTMAP off
COLUMN segment_name       FORMAT a125       HEADING 'LOB Segment Name'   ENTMAP off
COLUMN tablespace_name    FORMAT a75        HEADING 'Tablespace Name'    ENTMAP off
COLUMN lob_segment_bytes  FORMAT a75        HEADING 'Segment Size'       ENTMAP off
COLUMN index_name         FORMAT a125       HEADING 'LOB Index Name'     ENTMAP off
COLUMN in_row             FORMAT a75        HEADING 'In Row?'            ENTMAP off

BREAK ON report ON owner ON table_name

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || l.owner || '</b></font></div>'    owner
  , '<div nowrap>' || l.table_name        || '</div>'       table_name
  , '<div nowrap>' || l.column_name       || '</div>'       column_name
  , '<div nowrap>' || l.segment_name      || '</div>'       segment_name
  , '<div nowrap>' || s.tablespace_name   || '</div>'       tablespace_name
  , '<div nowrap align="right">' || TO_CHAR(s.bytes, '999,999,999,999,999') || '</div>'  lob_segment_bytes
  , '<div nowrap>' || l.index_name        || '</div>'       index_name
  , DECODE(   l.in_row
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || l.in_row || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || l.in_row || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || l.in_row || '</b></font></div>')   in_row
FROM
    dba_lobs     l
  , dba_segments s
WHERE
      l.owner = s.owner
  AND l.segment_name = s.segment_name
  AND l.owner NOT IN (    'CTXSYS'
                        , 'DBSNMP'
                        , 'DMSYS'
                        , 'EXFSYS'
                        , 'IX'
                        , 'LBACSYS'
                        , 'MDSYS'
                        , 'OLAPSYS'
                        , 'ORDSYS'
                        , 'OUTLN'
                        , 'SYS'
                        , 'SYSMAN'
                        , 'SYSTEM'
                        , 'WKSYS'
                        , 'WMSYS'
                        , 'XDB')
ORDER BY
    l.owner
  , l.table_name
  , l.column_name;
  
prompt
prompt
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>LOB Segments WSH</b></font><hr align="left" width="460">

prompt <b>Excluding all internal system schemas (i.e. CTXSYS, MDSYS, SYS, SYSTEM)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner              FORMAT a85        HEADING 'Owner'              ENTMAP off
COLUMN table_name         FORMAT a75        HEADING 'Table Name'         ENTMAP off
COLUMN column_name        FORMAT a75        HEADING 'Column Name'        ENTMAP off
COLUMN segment_name       FORMAT a125       HEADING 'LOB Segment Name'   ENTMAP off
COLUMN tablespace_name    FORMAT a75        HEADING 'Tablespace Name'    ENTMAP off
COLUMN lob_segment_bytes  FORMAT a75        HEADING 'Segment Size'       ENTMAP off
COLUMN index_name         FORMAT a125       HEADING 'LOB Index Name'     ENTMAP off
COLUMN in_row             FORMAT a75        HEADING 'In Row?'            ENTMAP off

BREAK ON report ON owner ON table_name

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || l.owner || '</b></font></div>'    owner
  , '<div nowrap>' || l.table_name        || '</div>'       table_name
  , '<div nowrap>' || l.column_name       || '</div>'       column_name
  , '<div nowrap>' || l.segment_name      || '</div>'       segment_name
  , '<div nowrap>' || s.tablespace_name   || '</div>'       tablespace_name
  , '<div nowrap align="right">' || TO_CHAR(s.bytes, '999,999,999,999,999') || '</div>'  lob_segment_bytes
  , '<div nowrap>' || l.index_name        || '</div>'       index_name
  , DECODE(   l.in_row
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || l.in_row || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || l.in_row || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || l.in_row || '</b></font></div>')   in_row
FROM
    dba_lobs@pps02     l
  , dba_segments@pps02 s
WHERE
      l.owner = s.owner
  AND l.segment_name = s.segment_name
  AND l.owner NOT IN (    'CTXSYS'
                        , 'DBSNMP'
                        , 'DMSYS'
                        , 'EXFSYS'
                        , 'IX'
                        , 'LBACSYS'
                        , 'MDSYS'
                        , 'OLAPSYS'
                        , 'ORDSYS'
                        , 'OUTLN'
                        , 'SYS'
                        , 'SYSMAN'
                        , 'SYSTEM'
                        , 'WKSYS'
                        , 'WMSYS'
                        , 'XDB')
ORDER BY
    l.owner
  , l.table_name
  , l.column_name;
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |     				- Tables Analysis -                           			|
-- +----------------------------------------------------------------------------+
prompt <a name="Last_Analysis_Date"></a>
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Table Analysis</u></b></font></center>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Table Analysis PaP</b></font><hr align="left" width="460">
CLEAR COLUMNS BREAKS COMPUTES
SET LINES 100
COL table_name FORMAT A30	
COL last_analyzed FORMAT A40
ALTER SESSION SET NLS_DATE_FORMAT=  'DD-MON-YYYY' ;
select  'Site' as Site, owner as "Owner" , table_name as "Table Name"  , last_analyzed from dba_tables where owner in ('SYSTEM') 
order by 1 ,2;

prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Table Analysis WSH</b></font><hr align="left" width="460">
CLEAR COLUMNS BREAKS COMPUTES
SET LINES 100
COL table_name FORMAT A30	
COL last_analyzed FORMAT A40
ALTER SESSION SET NLS_DATE_FORMAT=  'DD-MON-YYYY' ;
select  'Site' as Site, owner as "Owner" , table_name as "Table Name"  , last_analyzed from dba_tables@pps02 where owner in ('SYSTEM') 
order by 1 ,2;


-- +----------------------------------------------------------------------------+
-- |                           - DIRECTORIES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_directories"></a>
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Directories</u></b></font></center>
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Directories PaP</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner             FORMAT a75  HEADING 'Owner'             ENTMAP off
COLUMN directory_name    FORMAT a75  HEADING 'Directory Name'    ENTMAP off
COLUMN directory_path                HEADING 'Directory Path'    ENTMAP off

BREAK ON report ON owner

SELECT
    '<div align="left"><font color="#336699"><b>' || owner          || '</b></font></div>'  owner
  , '<b><font color="#663300">'                   || directory_name || '</font></b>'        directory_name
  , '<tt>' || directory_path || '</tt>' directory_path
FROM
    dba_directories
ORDER BY
    owner
  , directory_name;
prompt <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Directories WSH</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner             FORMAT a75  HEADING 'Owner'             ENTMAP off
COLUMN directory_name    FORMAT a75  HEADING 'Directory Name'    ENTMAP off
COLUMN directory_path                HEADING 'Directory Path'    ENTMAP off

BREAK ON report ON owner

SELECT
    '<div align="left"><font color="#336699"><b>' || owner          || '</b></font></div>'  owner
  , '<b><font color="#663300">'                   || directory_name || '</font></b>'        directory_name
  , '<tt>' || directory_path || '</tt>' directory_path
FROM
    dba_directories@pps02
ORDER BY
    owner
  , directory_name;  
prompt
prompt
prompt
prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b>End Of REPORT</b></font></center> 

-- +----------------------------------------------------------------------------+
-- |                            - END OF REPORT -                               |
-- +----------------------------------------------------------------------------+

SPOOL OFF

SET MARKUP HTML OFF

SET TERMOUT ON

prompt 
prompt Output written to: &FileName._&_dbname._&_spool_time..html

EXIT;