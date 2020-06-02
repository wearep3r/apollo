docker plugin install --grant-all-permissions  rexray/s3fs S3FS_ACCESSKEY=admin S3FS_SECRETKEY=insecure! S3FS_ENDPOINT=http://localhost:9091 S3FS_OPTIONS="allow_other,use_path_request_style,use_cache=/tmp/s3fs,mp_umask=000,nonempty,url=http://localhost:9091,default_acl=public-read-write"


libstorage.integration.volume.operations.mount.rootPath: /
libstorage.integration.volume.operations.remove.force = true

http://devopsblues.com/

~/.s3ql/authinfo2


mkfs.s3ql --plain --backend-options no-ssl s3c://localhost:9091/docker
mount.s3ql --backend-options no-ssl s3c://localhost:9091/docker /mnt