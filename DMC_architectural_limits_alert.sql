create or replace variable alert_percentage integer constant ( 1 ) ;

insert into SESSION.admintabinfo select * from sysibmadm.admintabinfo;

-- 4TB LOB Object size limit
insert into SESSION.stuff (select  '-2','!!4TB LOB Object size limit!! '||trim(tabschema)||'.'||trim(tabname)||' is approaching the architectural LOB object size lmiit: '||LOB_OBJECT_P_SIZE||'KB / 4294967296KB' from SESSION.admintabinfo where INT((FLOAT(LOB_OBJECT_P_SIZE)/FLOAT(4294967296))*100) > alert_percentage);

-- Size limit for tables in SMS tablespaces
insert into SESSION.stuff (select '-2','!!Size limit for tables in SMS tablespaces!! '||trim(a.tabschema)||'.'||trim(a.tabname)||' Data size: '||DATA_OBJECT_P_SIZE||'KB / '||varchar(PAGESIZE*16384)
||'KB   Index size: '||INDEX_OBJECT_P_SIZE||'KB   Long data size: '||LONG_OBJECT_P_SIZE||'KB   Lob data size: '||LOB_OBJECT_P_SIZE||'KB' from SESSION.admintabinfo a, syscat.tables b, syscat.tablespaces c where (
        a.tabschema=b.tabschema AND
        a.tabname=b.tabname
        and b.tbspace = c.tbspace
        and c.TBSPACETYPE = 'S'
        AND (
                  INT((FLOAT(DATA_OBJECT_P_SIZE)/(PAGESIZE*16384))*100) > alert_percentage
            )
        )
);

-- Table row limit
insert into SESSION.stuff (select  '-2','!!Table row limit!! '||trim(tabschema)||'.'||trim(tabname)||' is approaching the architectural row limit: '||CARD||' / 1280000000000 rows'  from syscat.datapartitions where INT((FLOAT(CARD)/FLOAT(1280000000000))*100) > alert_percentage);

--Tablespace size limit
insert into SESSION.stuff (select  '-2','!!Tablespace limit!! '||trim(TBSP_NAME)||' is approaching its architectural size limit. Current size: '||TBSP_TOTAL_SIZE_KB||'KB / '||
                                CASE
                                        WHEN TBSP_TYPE='DMS' AND TBSP_CONTENT_TYPE='REGULAR' THEN varchar(TBSP_PAGE_SIZE*16384)
                                        WHEN TBSP_TYPE='DMS' AND TBSP_CONTENT_TYPE='LARGE' THEN varchar(TBSP_PAGE_SIZE*2097152)
                                END ||'KB'
 from sysibmadm.MON_TBSP_UTILIZATION where (

                                                ( TBSP_TYPE='DMS' AND TBSP_CONTENT_TYPE='REGULAR'
                                                        AND ( INT((FLOAT(TBSP_TOTAL_SIZE_KB)/(TBSP_PAGE_SIZE*16384))*100) > alert_percentage )
                                                )
                                                OR
                                                ( TBSP_TYPE='DMS' AND TBSP_CONTENT_TYPE='LARGE'
                                                        AND ( INT((FLOAT(TBSP_TOTAL_SIZE_KB)/(TBSP_PAGE_SIZE*2097152))*100) > alert_percentage )
                                                )
));


select * from SESSION.stuff;
