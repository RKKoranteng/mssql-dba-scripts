DECLARE @sql VARCHAR(MAX) = ''
, @crlf VARCHAR(2) = CHAR(13) + CHAR(10) ;
select @sql = @sql + 'drop table' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(t.name) +';' + @crlf
from sys.tables t
where schema_name(t.schema_id) = 'PUTSCHEMANAME' -- put schema name here
order by t.name;
PRINT @sql;
EXEC(@sql);
