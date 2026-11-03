local lib = import 'lib.libsonnet';
local replicas = std.parseInt(std.extVar('replicas'));
local message = std.extVar('message');
[
  lib.deployment('scout', replicas, message),
  lib.service('scout'),
]
