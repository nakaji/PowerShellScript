#!/ust/bin

sqlplus test/test@test << EOF
select * from aaaa
where id = ${id}
and name = ${name}
;
EOF
