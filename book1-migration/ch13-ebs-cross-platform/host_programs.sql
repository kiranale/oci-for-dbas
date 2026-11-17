-- Concurrent programs that run host (shell) scripts or spawned executables: run each once in UAT on Linux.
SELECT a.application_short_name app, p.concurrent_program_name prog, e.execution_file_name file_name,
       DECODE(e.execution_method_code,'H','Host','S','Immediate','P','Oracle Reports','I','PL/SQL',
              'L','SQL*Loader','Q','SQL*Plus','J','Java','K','Java Concurrent','E','Perl','B','Request Set Stage',
              'A','Spawned',e.execution_method_code) method
FROM   fnd_concurrent_programs p
JOIN   fnd_executables e ON e.executable_id = p.executable_id AND e.application_id = p.executable_application_id
JOIN   fnd_application a ON a.application_id = p.application_id
WHERE  p.enabled_flag = 'Y' AND e.execution_method_code IN ('H','A')
ORDER  BY 1, 2;
