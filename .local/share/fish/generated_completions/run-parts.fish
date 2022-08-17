# run-parts
# Autogenerated from man page /usr/share/man/man8/run-parts.8.gz
complete -c run-parts -l test -d 'print the names of the scripts which would be run, but don\'t actually run them'
complete -c run-parts -l list -d 'print the names of the all matching files (not limited to executables), but d…'
complete -c run-parts -s v -l verbose -d 'print the name of each script to stderr before running'
complete -c run-parts -l report -d 'similar to  --verbose , but only prints the name of scripts which produce out…'
complete -c run-parts -s d -l debug -d 'print to stderr which scripts get selected for running and which don\'t'
complete -c run-parts -l reverse -d 'reverse the scripts\' execution order'
complete -c run-parts -l exit-on-error -d 'exit as soon as a script returns with a non-zero exit code'
complete -c run-parts -l lsbsysinit -d 'use LSB namespaces instead of classical behavior'
complete -c run-parts -l new-session -d 'run each script in a separate process session'
complete -c run-parts -l regex -d 'validate filenames against custom extended regular expression R RE '
complete -c run-parts -s u -l umask -d 'sets the umask to  umask before running the scripts'
complete -c run-parts -s a -l arg -d 'pass  argument to the scripts'
complete -c run-parts -s h -l help -d 'display usage information and exit'
complete -c run-parts -s V -l version -d 'display version and copyright and exit'

