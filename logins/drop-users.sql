use [putdbname]
go

DECLARE @sSQL varchar(max) = ''

select @sSQL = @sSQL + 'DROP USER ['+name+'];' +char(10)
from sys.database_principals
where type <> 'R' and principal_id > 4
and name not in ('[user1]','[user2]','[user3]')

print @sSQL
-- exec(@sSQL)
